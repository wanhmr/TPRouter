//
//  TPRouteInterruptionManager.m
//  TPRouter
//
//  Created by Tpphha on 2019/8/5.
//

#import "TPRouteInterruptionManager.h"

NSNotificationName TPRouteInterruptionNotification = @"TPRouteInterruptionNotification";
NSString const* TPRouteInterruptionTypeKey = @"TPRouteInterruptionTypeKey";

@interface TPRouteInterruptionManager ()

@property (nonatomic, assign) NSInteger count;

@end

@implementation TPRouteInterruptionManager

+ (instancetype)sharedManager {
    static TPRouteInterruptionManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [self new];
    });
    return manager;
}

- (void)increaseInterruption {
    BOOL shouldPostBegan = self.count == 0;
    self.count++;
    if (shouldPostBegan) {
        [self postInterruptionBegan];
    }
}

- (void)decreaseInterruption {
    if (self.count == 0) {
        NSAssert(NO, @"The increase and decrease mismatch.");
        return;
    }
    self.count--;
    if (self.count == 0) {
        [self postInterruptionEnded];
    }
}

- (void)postInterruptionBegan {
    [[NSNotificationCenter defaultCenter] postNotificationName:TPRouteInterruptionNotification
                                                        object:self
                                                      userInfo:@{TPRouteInterruptionTypeKey: @(TPRouteInterruptionTypeBegan)}];
}

- (void)postInterruptionEnded {
    [[NSNotificationCenter defaultCenter] postNotificationName:TPRouteInterruptionNotification
                                                        object:self
                                                      userInfo:@{TPRouteInterruptionTypeKey: @(TPRouteInterruptionTypeEnded)}];
}

- (BOOL)isInterrupted {
    return self.count != 0;
}

@end
