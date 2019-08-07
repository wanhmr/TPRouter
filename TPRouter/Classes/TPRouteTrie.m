//
//  TPRouteTrie.m
//  TPRouter
//
//  Created by Tpphha on 2019/8/3.
//

#import "TPRouteTrie.h"

@implementation NSURL (TPRouteTrie)

- (NSArray<NSString *> *)routeComponentsWithoutSlash {
    NSArray *pathComponents = self.pathComponents;
    NSMutableArray<NSString *> *compoments = pathComponents.count > 0 ? pathComponents.mutableCopy : @[].mutableCopy;
    if ([compoments.firstObject isEqualToString:@"/"]) {
        [compoments removeObjectAtIndex:0];
    }
    
    if (self.host.length > 0) {
        [compoments insertObject:self.host atIndex:0];
    }
    
    return compoments.copy;
}

@end

@implementation TPRouteTrieNode

- (instancetype)initWithName:(NSString *)name
                       value:(id)value
                       depth:(NSInteger)depth {
    self = [super init];
    if (self) {
        _key = name.copy;
        _value = value;
        _depth = depth;
        _children = [NSMutableDictionary new];
    }
    return self;
}

- (instancetype)initWithName:(NSString *)name {
    return [self initWithName:name value:nil depth:0];
}

- (BOOL)isTerminating {
    return self.value != nil;
}

- (BOOL)isLeaf {
    return self.children.count == 0;
}

- (void)addChildWithValue:(id)value forName:(NSString *)name {
    if (self.children[name]) {
        return;
    }
    
    TPRouteTrieNode *node = [[[self class] alloc] initWithName:name value:value depth:self.depth + 1];
    node.parent = self;
    self.children[name] = node;
}

- (BOOL)isPlaceholder {
    return [self.key hasPrefix:@":"];
}

- (NSString *)placeholder {
    if (self.isPlaceholder) {
        return [self.key substringFromIndex:NSMaxRange([self.key rangeOfString:@":"])];
    }
    return nil;
}

- (NSArray<TPRouteTrieNode *> *)matchedChildrenForName:(NSString *)name {
    NSMutableArray<TPRouteTrieNode *> *matchedChildren = [NSMutableArray new];
    TPRouteTrieNode *child = self.children[name];
    if (child) {
        [matchedChildren addObject:child];
    }
    
    [self.children.allValues enumerateObjectsUsingBlock:^(TPRouteTrieNode * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isPlaceholder]) {
            [matchedChildren addObject:obj];
            *stop = YES;
        }
    }];
    return matchedChildren.copy;
}

@end

@interface TPRouteTrie ()

@property (nonatomic, strong) TPRouteTrieNode *root;

@end

@implementation TPRouteTrie

- (instancetype)init {
    self = [super init];
    if (self) {
        _root = [[TPRouteTrieNode alloc] initWithName:@""];
    }
    return self;
}

- (BOOL)insertValue:(id)value withURL:(NSURL *)url {
    NSArray<NSString *> *components = url.routeComponentsWithoutSlash;
    if (!components || components.count == 0) {
        return NO;
    }
    
    TPRouteTrieNode *currentNode = self.root;
    for (NSString *component in components) {
        TPRouteTrieNode *child = currentNode.children[component];
        if (child) {
            currentNode = child;
        } else {
            if ([component hasPrefix:@":"]) {
                // check if any child is placeholder.
                for (TPRouteTrieNode *node in currentNode.children.allValues) {
                    if ([node isPlaceholder]) {
                        NSAssert(NO, @"Already have placeholder %@, can't insert another placeholder %@.", node.key, component);
                        return NO;
                    }
                }
            }
            [currentNode addChildWithValue:nil forName:component];
            currentNode = currentNode.children[component];
        }
    }
    currentNode.value = value;
    return YES;
}

- (void)removeNode:(TPRouteTrieNode *)node {
    TPRouteTrieNode *currentNode = node;
    while (currentNode.parent) {
        if ([currentNode isLeaf] && ![currentNode isTerminating]) {
            currentNode.parent.children[currentNode.key] = nil;
        }
        currentNode = currentNode.parent;
    }
}

- (TPRouteTrieNode *)searchNodeWithURL:(NSURL *)url {
    NSArray<NSString *> *components = url.routeComponentsWithoutSlash;
    if (!components || components.count == 0) {
        return nil;
    }
    
    return [self searchNodeWithRouteComponets:components rootNode:self.root];
}

- (TPRouteTrieNode *)searchNodeWithRouteComponets:(NSArray<NSString *> *)routeComponents rootNode:(TPRouteTrieNode *)rootNode {
    TPRouteTrieNode *resultNode = rootNode;
    
    NSString *first = routeComponents.firstObject;
    if (first.length > 0) {
        NSMutableArray<NSString *> *childrenRouteComponents = routeComponents.mutableCopy;
        [childrenRouteComponents removeObjectAtIndex:0];
        NSArray<TPRouteTrieNode *> *children = [rootNode matchedChildrenForName:first];
        for (TPRouteTrieNode *childNode in children) {
            TPRouteTrieNode *node = [self searchNodeWithRouteComponets:childrenRouteComponents rootNode:childNode];
            if (node.depth > resultNode.depth) {
                resultNode = node;
            }
            if (resultNode.depth - rootNode.depth == routeComponents.count) {
                break;
            }
        }
    }
    
    if ([resultNode isTerminating]) {
        return resultNode;
    }
    
    return nil;
}

- (TPRouteTrieNode *)searchNodeWithMatchPlaceholderWithURL:(NSURL *)url {
    NSArray<NSString *> *components = url.routeComponentsWithoutSlash;
    if (!components || components.count == 0) {
        return nil;
    }
    
    TPRouteTrieNode *node = [self searchNodeWithRouteComponets:components rootNode:self.root];
    if (node.depth == components.count) {
        return node;
    }
    
    return nil;
}

- (TPRouteTrieNode *)searchNodeWithoutMatchPlaceholderWithURL:(NSURL *)url {
    NSArray<NSString *> *components = url.routeComponentsWithoutSlash;
    if (!components || components.count == 0) {
        return nil;
    }
    
    TPRouteTrieNode *currentNode = self.root;
    for (NSString *component in components) {
        TPRouteTrieNode *child = currentNode.children[component];
        if (child) {
            currentNode = child;
        } else {
            return nil;
        }
    }
    
    if ([currentNode isTerminating]) {
        return currentNode;
    }
    
    return nil;
}

- (NSDictionary<NSString *, id> *)extractMatchedPatternFromURL:(NSURL *)url resultNode:(TPRouteTrieNode *)resultNode {
    NSArray<NSString *> *components = url.routeComponentsWithoutSlash;
    if (!components || components.count == 0) {
        return @{};
    }
    
    NSMutableDictionary *params = [NSMutableDictionary new];
    NSMutableArray<TPRouteTrieNode *> *nodes = [NSMutableArray new];
    TPRouteTrieNode *currentNode = resultNode;
    while (currentNode.parent) {
        [nodes addObject:currentNode];
        currentNode = currentNode.parent;
    }
    for (NSString *component in components) {
        TPRouteTrieNode *matchNode = [nodes lastObject];
        if (matchNode) {
            [nodes removeLastObject];
            if ([matchNode isPlaceholder] &&
                ![matchNode.key isEqualToString:component]) {
                params[matchNode.placeholder] = component;
            }
        } else {
            break;
        }
    }
    
    return params.copy;
}

@end
