//
//  TPRouteManager.m
//  TPRouter
//
//  Created by Tpphha on 2019/8/3.
//

#import "TPRouteManager.h"
#import "TPRouteTrie.h"

NSString const* TPRouteURLKey = @"RouteURL";

@interface TPRouteManager ()

@property (nonatomic, strong) TPRouteTrie *routesWithoutScheme;
@property (nonatomic, strong) NSMutableDictionary<NSString *, TPRouteTrie *> *schemesRoutes;

@end

@implementation TPRouteManager

- (instancetype)init {
    self = [super init];
    if (self) {
        _routesWithoutScheme = [TPRouteTrie new];
        _schemesRoutes = [NSMutableDictionary new];
    }
    return self;
}

- (BOOL)registerURL:(NSURL *)url clazz:(Class)clazz {
    TPRouteTrie *routes = [self routesForScheme:url.scheme];
    TPRouteTrieNode *node = [routes searchNodeWithoutMatchPlaceholderWithURL:url];
    if (node) {
        node.value = clazz;
        return YES;
    }
    
    // not find it, insert
    return [routes insertValue:clazz withURL:url];
}

- (void)unregisterURL:(NSURL *)url {
    TPRouteTrie *routes = [self routesForScheme:url.scheme];
    TPRouteTrieNode *node = [routes searchNodeWithoutMatchPlaceholderWithURL:url];
    node.value = nil;
    [routes removeNode:node];
}

- (BOOL)hasRegisteredURL:(NSURL *)url {
    TPRouteTrie *routes = [self routesForScheme:url.scheme];
    TPRouteTrieNode *node = [routes searchNodeWithoutMatchPlaceholderWithURL:url];
    return node.value != nil;
}

- (Class)searchClazzWithURL:(NSURL *)url params:(NSDictionary * _Nullable * _Nullable)params {
    TPRouteTrie *routes = [self routesForScheme:url.scheme];
    TPRouteTrieNode *node = [routes searchNodeWithURL:url];
    NSDictionary *tempParams = [routes extractMatchedPatternFromURL:url resultNode:node];
    if (params) {
        *params = [self extractParametersFromURL:url defaultParams:tempParams];
    }
    return node.value;
}

#pragma mark - Private

- (NSDictionary *)extractParametersFromURL:(NSURL *)url defaultParams:(NSDictionary *)defaultParams {
    // Extract placeholder parameters
    NSMutableDictionary *params = defaultParams.mutableCopy;
    
    // Add url to params
    params[TPRouteURLKey] = url;
    
    // Add queries to params
    NSArray<NSURLQueryItem *> *queryItems = [[NSURLComponents alloc] initWithURL:url resolvingAgainstBaseURL:NO].queryItems;
    for (NSURLQueryItem *queryItem in queryItems) {
        params[queryItem.name] = queryItem.value;
    }
    
    // Add fragment to params
    params[@"fragment"] = url.fragment;
    
    return params;
}

- (TPRouteTrie *)routesForScheme:(NSString *)scheme {
    if (scheme.length == 0) {
        return self.routesWithoutScheme;
    }
    
    TPRouteTrie *routes = self.schemesRoutes[scheme];
    if (!routes) {
        routes = [TPRouteTrie new];
        self.schemesRoutes[scheme] = routes;
    }
    return routes;
}

@end
