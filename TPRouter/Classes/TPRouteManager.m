//
//  TPRouteManager.m
//  FBSnapshotTestCase
//
//  Created by Tpphha on 2019/8/3.
//

#import "TPRouteManager.h"
#import "TPRouteTrie.h"

NSString const* TPRouteURLKey = @"RouteURL";

@interface TPRouteManager ()

@property (nonatomic, strong) TPRouteTrie *routes;

@end

@implementation TPRouteManager

- (instancetype)init {
    self = [super init];
    if (self) {
        _routes = [TPRouteTrie new];
    }
    return self;
}

- (BOOL)registerURL:(NSURL *)url clazz:(Class)clazz {
    TPRouteTrieNode *node = [self.routes searchNodeWithoutMatchPlaceholderWithURL:url];
    if (node) {
        node.value = clazz;
        return YES;
    }
    
    // not find it, insert
    return [self.routes insertValue:clazz withURL:url];
}

- (BOOL)unregisterURL:(NSURL *)url {
    TPRouteTrieNode *node = [self.routes searchNodeWithoutMatchPlaceholderWithURL:url];
    return node != nil;
}

- (BOOL)hasRegisteredURL:(NSURL *)url {
    TPRouteTrieNode *node = [self.routes searchNodeWithoutMatchPlaceholderWithURL:url];
    return node.value != nil;
}

- (void)searchValueWithURL:(NSURL *)url completion:(void(^ NS_NOESCAPE)(id value, NSDictionary *params))completion {
    TPRouteTrieNode *node = [self.routes searchNodeWithURL:url];
    NSDictionary *params = [self.routes extractMatchedPatternFromURL:url resultNode:node];
    completion(node.value, [self extractParametersFromURL:url defaultParams:params]);
}

#pragma mark - Private

- (NSDictionary *)extractParametersFromURL:(NSURL *)url defaultParams:(NSDictionary *)defaultParams {
    // Extract placeholder parameters
    NSMutableDictionary *params = defaultParams.mutableCopy;
    
    // Add url to params
    params[TPRouteURLKey] = url;
    
    // Add queries to params
    NSArray<NSURLQueryItem *> *queryItems = url.queryItems;
    for (NSURLQueryItem *queryItem in queryItems) {
        params[queryItem.name] = queryItem.value;
    }
    
    // Add fragment to params
    params[@"fragment"] = url.fragment;
    
    return params;
}

@end