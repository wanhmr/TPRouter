//
//  TPRouteManager.h
//  FBSnapshotTestCase
//
//  Created by Tpphha on 2019/8/3.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString const* TPRouteURLKey;

@interface TPRouteManager : NSObject

- (BOOL)registerURL:(NSURL *)url clazz:(Class)clazz;

- (BOOL)unregisterURL:(NSURL *)url;

- (BOOL)hasRegisteredURL:(NSURL *)url;

- (void)searchValueWithURL:(NSURL *)url completion:(void(^ NS_NOESCAPE)(id value, NSDictionary *params))completion;

@end

NS_ASSUME_NONNULL_END
