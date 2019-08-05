//
//  TPRouteInterruptionManager.h
//  TPRouter
//
//  Created by Tpphha on 2019/8/5.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSNotificationName TPRouteInterruptionNotification;
FOUNDATION_EXPORT NSString const* TPRouteInterruptionTypeKey;

typedef NS_ENUM(NSUInteger, TPRouteInterruptionType) {
    TPRouteInterruptionTypeBegan = 1,  /* the system has interrupted your route */
    TPRouteInterruptionTypeEnded = 0,  /* the interruption has ended */
};

@interface TPRouteInterruptionManager : NSObject

@property (nonatomic, readonly, getter=isInterrupted) BOOL interrupted;

+ (instancetype)sharedManager;

- (void)increaseInterruption;
- (void)decreaseInterruption;

@end

NS_ASSUME_NONNULL_END
