//
//  TPRouter.m
//  TPMobileFramework
//
//  Created by Tpphha on 2019/8/3.
//

#import "TPRouter.h"
#import "TPRouteManager.h"

static UIViewController* TPTopmostViewControllerWithViewController(UIViewController *viewController) {
    if (viewController.presentedViewController) {
        return TPTopmostViewControllerWithViewController(viewController.presentedViewController);
    } else if ([viewController isKindOfClass:UITabBarController.class]) {
        return TPTopmostViewControllerWithViewController([(UITabBarController *)viewController selectedViewController]);
    } else if ([viewController isKindOfClass:UINavigationController.class]) {
        return TPTopmostViewControllerWithViewController([(UINavigationController *)viewController topViewController]);
    }
    return viewController;
}

@implementation TPRoutableLauncher

#pragma mark - TPRoutableLaunching

- (BOOL)launchRoutable:(id<TPRoutable>)routable router:(TPRouter *)router source:(nullable id)source params:(nullable NSDictionary *)params {
    return NO;
}

@end

@implementation TPViewRoutableLauncher

- (instancetype)initWithMode:(TPViewRoutableLaunchMode)mode animated:(BOOL)animated {
    self = [super init];
    if (self) {
        _mode = mode;
        _animated = animated;
    }
    return self;
}

#pragma mark - TPRoutableLaunching

- (BOOL)launchRoutable:(id<TPViewRoutable>)routable router:(TPRouter *)router source:(nullable id)source params:(nullable NSDictionary *)params {
    UIViewController *routableViewController = nil;
    if ([routable respondsToSelector:@selector(viewControllerForRoutableLaunching)]) {
        routableViewController = [routable viewControllerForRoutableLaunching];
    } else if ([routable isKindOfClass:UIViewController.class]) {
        routableViewController = (UIViewController *)routable;
    }
    NSAssert(routableViewController, @"The routable view controller can't be nil.");
    if (!routableViewController) {
        return NO;
    }
    
    UIViewController *sourceViewController = [source isKindOfClass:UIViewController.class] ? source : router.topmostViewController;
    BOOL result = YES;
    switch (self.mode) {
        case TPViewRoutableLaunchModeAuto: {
            if (sourceViewController.navigationController) {
                [sourceViewController.navigationController pushViewController:routableViewController animated:self.animated];
            } else {
                [sourceViewController presentViewController:routableViewController animated:self.animated completion:nil];
            }
        }
            break;
        case TPViewRoutableLaunchModePush: {
            [sourceViewController.navigationController pushViewController:routableViewController animated:self.animated];
        }
            break;
        case TPViewRoutableLaunchModePresent: {
            [sourceViewController presentViewController:routableViewController animated:self.animated completion:nil];
        }
            break;
        default:
            result = NO;
            break;
    }
    
    return result;
}

@end

@interface TPRouteIntent ()

@property (nonatomic, strong) NSMutableDictionary *internalExtras;

@end

@implementation TPRouteIntent

- (instancetype)init {
    self = [super init];
    if (self) {
        _internalExtras = [NSMutableDictionary new];
    }
    return self;
}

- (instancetype)initWithURL:(NSURL *)url {
    self = [self init];
    if (self) {
        _url = url;
    }
    return self;
}

- (instancetype)initWithClazz:(Class)clazz {
    NSAssert([clazz conformsToProtocol:@protocol(TPRoutable)], @"The clazz does't conforms to TPRoutable");
    self = [self init];
    if (self) {
        _clazz = clazz;
    }
    return self;
}

- (void)putExtraDatas:(NSDictionary *)extraDatas {
    if (!extraDatas) {
        return;
    }
    
    [self.internalExtras addEntriesFromDictionary:extraDatas];
}

- (void)putExtraValue:(id)value forKey:(NSString *)key {
    if (key.length == 0) {
        return;
    }
    
    self.internalExtras[key] = value;
}

#pragma mark - Custom Accessors

- (NSDictionary *)extras {
    return self.internalExtras.copy;
}

@end

@interface TPRouter ()

@property (nonatomic, strong) TPRouteManager *routeManager;

@end

@implementation TPRouter

- (instancetype)init {
    self = [super init];
    if (self) {
        _routeManager = [TPRouteManager new];
    }
    return self;
}

+ (instancetype)sharedRouter {
    static TPRouter *router;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        router = [self new];
    });
    return router;
}

- (void)registerURL:(NSURL *)url routableClazz:(Class)routableClazz; {
    NSAssert([routableClazz conformsToProtocol:@protocol(TPRoutable)], @"The routable class does't conforms to TPRoutable");
    [self.routeManager registerURL:url clazz:routableClazz];
}

- (void)unregisterURL:(NSURL *)url {
    [self.routeManager unregisterURL:url];
}

- (BOOL)hasRegisteredURL:(NSURL *)url {
    return [self.routeManager hasRegisteredURL:url];
}

- (Class)searchRoutableClazzWithURL:(NSURL *)url params:(NSDictionary *__autoreleasing  _Nullable * _Nullable)params {
    return [self.routeManager searchClazzWithURL:url params:params];
}

- (BOOL)routeIntent:(TPRouteIntent *)intent source:(id)source {
    NSDictionary *params = nil;
    id<TPRoutable> routable = [self routableForIntent:intent params:&params];
    if (!routable) {
        return NO;
    }
    
    if ([self.delegate respondsToSelector:@selector(router:shouldRouteIntent:destinationRoutable:params:)]) {
        BOOL shouldRoute = [self.delegate router:self shouldRouteIntent:intent destinationRoutable:routable params:params];
        if (!shouldRoute) {
            return NO;
        }
    }
    
    BOOL result = NO;
    
    if ([self.delegate respondsToSelector:@selector(router:willRouteIntent:destinationRoutable:params:)]) {
        [self.delegate router:self willRouteIntent:intent destinationRoutable:routable params:params];
    }
    
    id<TPRoutableLaunching> routableLauncher = nil;
    if (intent.routableLauncher) {
        routableLauncher = intent.routableLauncher;
    } else {
        routableLauncher = routable.routableLauncher;
    }
    result = [routableLauncher launchRoutable:routable router:self source:source params:params];
    
    if ([self.delegate respondsToSelector:@selector(router:didRouteIntent:destinationRoutable:params:)]) {
        [self.delegate router:self didRouteIntent:intent destinationRoutable:routable params:params];
    }
    
    return result;
}

- (BOOL)routeIntent:(TPRouteIntent *)intent {
    return [self routeIntent:intent source:nil];
}

#pragma mark - Private

- (id<TPRoutable>)routableForIntent:(TPRouteIntent *)intent params:(NSDictionary * _Nullable * _Nullable)params {
    Class routableClazz = NULL;
    NSMutableDictionary *totalPrams = [(intent.extras ? : @{}) mutableCopy];
    if (intent.clazz) {
        routableClazz = intent.clazz;
    } else if (intent.url) {
        NSDictionary *urlParams = nil;
        routableClazz = [self searchRoutableClazzWithURL:intent.url params:&urlParams];
        if (urlParams) {
            [totalPrams addEntriesFromDictionary:urlParams];
        }
    }
    
    if (params && totalPrams.allKeys.count > 0) {
        *params = totalPrams.copy;
    }
    
    if ([self.delegate respondsToSelector:@selector(router:routableForIntent:routableClazz:params:)]) {
        id<TPRoutable> routable = [self.delegate router:self routableForIntent:intent routableClazz:routableClazz params:totalPrams];
        if (routable) {
            return routable;
        }
    }
    
    return [(id<TPRoutable>)[routableClazz alloc] initWithParams:totalPrams.copy];
}

#pragma mark - Custom Accessors

- (UIViewController *)rootViewController {
    UIWindow *window = self.window;
    if (!window) {
        window = [UIApplication sharedApplication].keyWindow;
    }
    return window.rootViewController;
}

- (UIViewController *)topmostViewController {
    return TPTopmostViewControllerWithViewController(self.rootViewController);
}

@end
