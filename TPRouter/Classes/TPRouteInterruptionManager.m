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
@property (nonatomic, strong) NSLock *lock;

@end

@implementation TPRouteInterruptionManager

- (instancetype)init {
    self = [super init];
    if (self) {
        _lock = [NSLock new];
    }
    return self;
}

+ (instancetype)sharedManager {
    static TPRouteInterruptionManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [self new];
    });
    return manager;
}

- (void)increaseInterruption {
    [self.lock lock];
    if (self.count == 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:TPRouteInterruptionNotification
                                                            object:self
                                                          userInfo:@{TPRouteInterruptionTypeKey: @(TPRouteInterruptionTypeBegan)}];
    }
    self.count++;
    [self.lock unlock];
}

- (void)decreaseInterruption {
    if (self.count == 0) {
        NSAssert(NO, @"The increase and decrease mismatch.");
        return;
    }
    [self.lock lock];
    self.count--;
    if (self.count == 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:TPRouteInterruptionNotification
                                                            object:self
                                                          userInfo:@{TPRouteInterruptionTypeKey: @(TPRouteInterruptionTypeEnded)}];
    }
    [self.lock unlock];
}

- (BOOL)isInterrupted {
    return self.count == 0;
}

@end
