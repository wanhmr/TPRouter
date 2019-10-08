//
//  TPRouter.h
//  TPRouter
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

- (BOOL)launchRoutable:(id<TPRoutable>)routable byRouter:(TPRouter *)router source:(nullable id)source params:(nullable NSDictionary *)params;

@end

@interface TPRoutableLauncher : NSObject <TPRoutableLaunching>

@end

@interface TPViewRoutableLauncher : TPRoutableLauncher

@property (nonatomic, assign) TPViewRoutableLaunchMode mode;
@property (nonatomic, assign) BOOL animated;

- (instancetype)initWithMode:(TPViewRoutableLaunchMode)mode animated:(BOOL)animated;

@end

@interface TPOperationRoutableLauncher : TPRoutableLauncher

@end

@interface TPRouteIntent : NSObject

@property (nullable, strong, readonly) NSURL *url;
@property (nullable, assign, readonly) Class clazz;
@property (nullable, nonatomic, strong) id<TPRoutableLaunching> routableLauncher;

@property (nonatomic, copy, readonly) NSDictionary *extras;

- (instancetype)initWithURL:(NSURL *)url;

- (instancetype)initWithClazz:(Class)clazz;

- (void)putExtraDatas:(NSDictionary *)extraDatas;

- (void)putExtraValue:(id)value forKey:(NSString *)key;

@end


@interface TPRouter : NSObject

@property (nullable, nonatomic, strong) UIWindow *window;
@property (nonatomic, strong, readonly) UIViewController *rootViewController;
@property (nonatomic, strong, readonly) UIViewController *topmostViewController;

@property (nullable, nonatomic, weak) id<TPRouterProtocol> delegate;

+ (instancetype)sharedRouter;

- (void)registerURL:(NSURL *)url routableClazz:(Class)routableClazz;

- (void)unregisterURL:(NSURL *)url;

- (BOOL)hasRegisteredURL:(NSURL *)url;

- (Class)searchRoutableClazzWithURL:(NSURL *)url params:(NSDictionary * _Nullable * _Nullable)params;

- (BOOL)routeIntent:(TPRouteIntent *)intent source:(nullable id)source;

- (BOOL)routeIntent:(TPRouteIntent *)intent;

@end

@protocol TPRouterProtocol <NSObject>

@optional

- (nullable id<TPRoutable>)router:(TPRouter *)router routableForIntent:(TPRouteIntent *)intent routableClazz:(Class)routableClazz params:(nullable NSDictionary *)params;
- (BOOL)router:(TPRouter *)router shouldRouteIntent:(TPRouteIntent *)intent destinationRoutable:(id<TPRoutable>)destinationRoutable params:(nullable NSDictionary *)params;
- (void)router:(TPRouter *)router willRouteIntent:(TPRouteIntent *)intent destinationRoutable:(id<TPRoutable>)destinationRoutable params:(nullable NSDictionary *)params;
- (void)router:(TPRouter *)router didRouteIntent:(TPRouteIntent *)intent destinationRoutable:(id<TPRoutable>)destinationRoutable params:(nullable NSDictionary *)params result:(BOOL)result;

@end

@protocol TPRoutable <NSObject>

@optional

- (instancetype)initWithParams:(nullable NSDictionary *)params;

- (id<TPRoutableLaunching>)routableLauncher;

@end

@protocol TPViewRoutable <TPRoutable>

@optional

- (UIViewController *)viewControllerForRoutableLaunching;

@end

@protocol TPOperationRoutable <TPRoutable>

- (BOOL)launchByRouter:(TPRouter *)router source:(nullable id)source params:(nullable NSDictionary *)params;

@end

NS_ASSUME_NONNULL_END
