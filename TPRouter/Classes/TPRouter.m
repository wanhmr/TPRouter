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

- (BOOL)router:(TPRouter *)router launchRoutable:(id<TPRoutable>)routable forIntent:(TPRouteIntent *)intent {
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

- (BOOL)router:(TPRouter *)router launchRoutable:(id<TPViewRoutable>)routable forIntent:(TPRouteIntent *)intent {
    UIViewController *routableViewController = nil;
    if ([routable respondsToSelector:@selector(viewControllerForLaunching)]) {
        routableViewController = [routable viewControllerForLaunching];
    } else if ([routable isKindOfClass:UIViewController.class]) {
        routableViewController = (UIViewController *)routable;
    }
    NSAssert(routableViewController, @"The routable view controller can't be nil.");
    if (!routableViewController) {
        return NO;
    }
    
    UIViewController *sourceViewController = self.sourceViewController ? : router.topmostViewController;
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

@property (nonatomic, strong) NSMutableDictionary *params;

@end

@implementation TPRouteIntent

- (instancetype)init {
    self = [super init];
    if (self) {
        _params = [NSMutableDictionary new];
    }
    return self;
}

- (instancetype)initWithURL:(NSURL *)url routableLauncher:(id<TPRoutableLaunching>)routableLauncher {
    self = [self init];
    if (self) {
        _url = url;
        _routableLauncher = routableLauncher;
    }
    return self;
}

- (instancetype)initWithClazz:(Class)clazz routableLauncher:(id<TPRoutableLaunching>)routableLauncher {
    self = [self init];
    if (self) {
        _clazz = clazz;
        _routableLauncher = routableLauncher;
    }
    return self;
}

- (void)putExtraDatas:(NSDictionary *)extraDatas {
    if (!extraDatas) {
        return;
    }
    
    [self.params addEntriesFromDictionary:extraDatas];
}

- (void)putExtraValue:(id)value forKey:(NSString *)key {
    if (key.length == 0) {
        return;
    }
    
    self.params[key] = value;
}

#pragma mark - Custom Accessors

- (NSDictionary *)extras {
    return self.params.copy;
}

@end

@interface TPRouter ()

@property (nonatomic, strong) NSMutableDictionary<NSString *, TPRouteManager *> *routeManagers;

@end

@implementation TPRouter

- (instancetype)init {
    self = [super init];
    if (self) {
        _routeManagers = [NSMutableDictionary new];
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

- (void)registerURL:(NSURL *)url routableClass:(Class)routableClass; {
    NSAssert([routableClass conformsToProtocol:@protocol(TPRoutable)], @"The routableClass is't conforms to TPRoutable");
    [[self routeMangerForURL:url] registerURL:url clazz:routableClass];
}

- (void)unregisterURL:(NSURL *)url {
    [[self routeMangerForURL:url] unregisterURL:url];
}

- (BOOL)hasRegisteredURL:(NSURL *)url {
    return [[self routeMangerForURL:url] hasRegisteredURL:url];
}

- (BOOL)routeIntent:(TPRouteIntent *)intent {
    BOOL result = NO;
    
    if ([self.delegate respondsToSelector:@selector(router:willRouteIntent:)]) {
        [self.delegate router:self willRouteIntent:intent];
    }
    
    id<TPRoutable> routable = [self routableForIntent:intent];
    result = [intent.routableLauncher router:self launchRoutable:routable forIntent:intent];
    
    if ([self.delegate respondsToSelector:@selector(router:didRouteIntent:)]) {
        [self.delegate router:self didRouteIntent:intent];
    }
    
    return result;
}

#pragma mark - Private

- (id<TPRoutable>)routableForIntent:(TPRouteIntent *)intent {
    __block Class routableClass = NULL;
    if (intent.clazz) {
        routableClass = intent.clazz;
    } else if (intent.url) {
        [[self routeMangerForURL:intent.url] searchValueWithURL:intent.url completion:^(id  _Nonnull value, NSDictionary * _Nonnull params) {
            routableClass = value;
            [intent putExtraDatas:params];
        }];
    }
    
    return [(id<TPRoutable>)[routableClass alloc] initWithExtras:intent.params];
}

- (TPRouteManager *)routeMangerForURL:(NSURL *)url {
    NSString *scheme = url.scheme;
    if (scheme.length == 0) {
        scheme = @"tpphha";
    }
    TPRouteManager *routeManager = self.routeManagers[scheme];
    if (!routeManager) {
        routeManager = [TPRouteManager new];
        self.routeManagers[scheme] = routeManager;
    }
    return routeManager;
}

#pragma mark - Custom Accessors

- (UIViewController *)rootViewController {
    UIWindow *window = self.window;
    if (!window) {
        window = [UIApplication sharedApplication].delegate.window;
    }
    return window.rootViewController;
}

- (UIViewController *)topmostViewController {
    return TPTopmostViewControllerWithViewController(self.rootViewController);
}

@end
