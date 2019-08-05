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

- (BOOL)launchRoutable:(id<TPRoutable>)routable router:(TPRouter *)router params:(nullable NSDictionary *)params;

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

@property (nullable, strong, readonly) NSURL *url;
@property (nullable, assign, readonly) Class clazz;
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

- (void)unregisterURL:(NSURL *)url;

- (BOOL)hasRegisteredURL:(NSURL *)url;

- (Class)searchRoutableClassWithURL:(NSURL *)url params:(NSDictionary * _Nullable * _Nullable)params;

- (BOOL)routeIntent:(TPRouteIntent *)intent;

@end

@protocol TPRouterProtocol <NSObject>

@optional

- (BOOL)router:(TPRouter *)router shouldRouteIntent:(TPRouteIntent *)intent destinationRoutable:(id<TPRoutable>)destinationRoutable params:(nullable NSDictionary *)params;
- (void)router:(TPRouter *)router willRouteIntent:(TPRouteIntent *)intent destinationRoutable:(id<TPRoutable>)destinationRoutable params:(nullable NSDictionary *)params;
- (void)router:(TPRouter *)router didRouteIntent:(TPRouteIntent *)intent destinationRoutable:(id<TPRoutable>)destinationRoutable params:(nullable NSDictionary *)params;

@end

@protocol TPRoutable <NSObject>

@required

- (instancetype)initWithParams:(nullable NSDictionary *)params;

@end

@protocol TPViewRoutable <TPRoutable>

@optional

- (UIViewController *)viewControllerForLaunching;

@end

NS_ASSUME_NONNULL_END
