//
//  TPRouteTrie.h
//  TPRouter
//
//  Created by Tpphha on 2019/8/3.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSURL (TPRouteTrie)

/**
 The route components without slash.
 
 - returns: array of route components without slash.
 */
@property (nullable, nonatomic, copy, readonly) NSArray<NSString *> *routeComponentsWithoutSlash;

@end

@interface TPRouteTrieNode : NSObject

@property (nonatomic, copy, readonly) NSString *key;
@property (nullable, nonatomic, strong) id value;
@property (nonatomic, assign) NSInteger depth;
@property (nonatomic, strong, readonly) NSMutableDictionary<NSString *, TPRouteTrieNode *> *children;
@property (nullable, nonatomic, strong) TPRouteTrieNode *parent;

@end

@interface TPRouteTrie : NSObject

/**
 Insert the url into the trie.
 
 - parameter value: the value for inserting.
 - parameter url: the url.
 */
- (BOOL)insertValue:(id)value withURL:(NSURL *)url;

/**
 Remove node from Trie
 
 - parameter node: a node in the Trie
 */
- (void)removeNode:(TPRouteTrieNode *)node;

/**
 This search method's behavior is different with classical trie's search.
 When it can not find the node it will try to find the nearest parent node which is isTerminating.
 
 - parameter url: the url.
 
 - returns: the matched node. If trie has this paths, return this node.
 If trie has not this paths, return the nearest registered url parent.
 */
- (TPRouteTrieNode *)searchNodeWithURL:(NSURL *)url;

- (TPRouteTrieNode *)searchNodeWithRouteComponets:(NSArray<NSString *> *)routeComponents rootNode:(TPRouteTrieNode *)rootNode;

/**
 Find the node for given url, considering placeholder such as ":id".
 
 - parameter url: the url.
 - return the match node. Otherwise nil.
 */
- (TPRouteTrieNode *)searchNodeWithMatchPlaceholderWithURL:(NSURL *)url;

/**
 Find the node for given url without considering placeholder such as ":id".
 
 - parameter url: the url.
 - return the match node. Otherwise nil.
 */
- (TPRouteTrieNode *)searchNodeWithoutMatchPlaceholderWithURL:(NSURL *)url;

/**
 This trie support url pattern match. The url with prefix ":" is the url pattern, for example ":userId".
 This method extracts all the patterns in the url.
 
 - parameter url: the url for finding the pattern match.
 
 - parameter resultNode: the url search result node.
 
 - returns: dictionary for the pattern match result.
 */
- (NSDictionary<NSString *, id> *)extractMatchedPatternFromURL:(NSURL *)url resultNode:(TPRouteTrieNode *)resultNode;

@end

NS_ASSUME_NONNULL_END
