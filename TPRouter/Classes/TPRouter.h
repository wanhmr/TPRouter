//
//  TPRouter.h
//  TPMobileFramework
//
//  Created by Tpphha on 2019/8/3.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class TPRouter;
@class TPRouteIntent;

@protocol TPRoutable;
@protocol TPRouterProtocol;

typedef NS_ENUM(NSInteger, TPViewRoutableLaunchMode) {
    TPViewRoutableLaunchModeAuto,
    TPViewRoutableLaunchModePush,
    TPViewRoutableLaunchModePresent
};

@protocol TPRoutableLaunching <NSObject>

@required

- (BOOL)router:(TPRouter *)router launchRoutable:(id<TPRoutable>)routable forIntent:(TPRouteIntent *)intent;

@end

@interface TPRoutableLauncher : NSObject <TPRoutableLaunching>

@end

@interface TPViewRoutableLauncher : TPRoutableLauncher

@property (nonatomic, assign) TPViewRoutableLaunchMode mode;
@property (nonatomic, assign) BOOL animated;
@property (nullable, nonatomic, weak) UIViewController *sourceViewController;

- (instancetype)initWithMode:(TPViewRoutableLaunchMode)mode animated:(BOOL)animated;

@end

@interface TPRouteIntent : NSObject

@property (nullable, nonatomic, strong, readonly) NSURL *url;
@property (nullable, nonatomic, strong, readonly) Class clazz;
@property (nonatomic, strong) id<TPRoutableLaunching> routableLauncher;

@property (nonatomic, copy, readonly) NSDictionary *extras;

- (instancetype)initWithURL:(NSURL *)url routableLauncher:(id<TPRoutableLaunching>)routableLauncher;

- (instancetype)initWithClazz:(Class)clazz routableLauncher:(id<TPRoutableLaunching>)routableLauncher;

- (void)putExtraDatas:(NSDictionary *)extraDatas;

- (void)putExtraValue:(id)value forKey:(NSString *)key;

@end

@interface TPRouter : NSObject

@property (nullable, nonatomic, strong) UIWindow *window;
@property (nonatomic, strong, readonly) UIViewController *rootViewController;
@property (nonatomic, strong, readonly) UIViewController *topmostViewController;

@property (nullable, nonatomic, weak) id<TPRouterProtocol> delegate;

+ (instancetype)sharedRouter;

- (void)registerURL:(NSURL *)url routableClass:(Class)routableClass;

- (BOOL)hasRegisteredURL:(NSURL *)url;

- (BOOL)routeIntent:(TPRouteIntent *)intent;

@end

@protocol TPRouterProtocol <NSObject>

@optional

- (void)router:(TPRouter *)router willRouteIntent:(TPRouteIntent *)intent;
- (void)router:(TPRouter *)router didRouteIntent:(TPRouteIntent *)intent;

@end

@protocol TPRoutable <NSObject>

@required

- (instancetype)initWithExtras:(nullable NSDictionary *)extras;

@end

@protocol TPViewRoutable <TPRoutable>

@optional

- (UIViewController *)viewControllerForLaunching;

@end

NS_ASSUME_NONNULL_END
