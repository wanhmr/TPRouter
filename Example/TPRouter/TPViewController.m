//
//  TPViewController.m
//  TPRouter
//
//  Created by wanhmr on 08/05/2019.
//  Copyright (c) 2019 wanhmr. All rights reserved.
//

#import "TPViewController.h"
#import "TPPanelViewController.h"
#import "TPTestViewController.h"
#import <objc/runtime.h>
@import TPRouter;

@class TPPresentationController;

@interface TPPanelPresentationController : UIPresentationController

@end

@implementation TPPanelPresentationController

- (instancetype)initWithPresentedViewController:(UIViewController *)presentedViewController presentingViewController:(UIViewController *)presentingViewController {
    self = [super initWithPresentedViewController:presentedViewController presentingViewController:presentingViewController];
    if (self) {
        NSLog(@"containerView %@", self.containerView);
    }
    return self;
}

- (CGRect)frameOfPresentedViewInContainerView {
    return self.containerView.bounds;
}

@end

@interface TPViewController () <TPViewRoutable, UIViewControllerTransitioningDelegate, UIAdaptivePresentationControllerDelegate, UIViewControllerAnimatedTransitioning>

@property (nonatomic, strong) UIViewController *testViewController;

@end

@implementation TPViewController

- (instancetype)initWithRouteParams:(NSDictionary *)params {
    NSLog(@"params data: %@", params);
    return
    [[UIStoryboard storyboardWithName:@"Main" bundle:nil]
     instantiateViewControllerWithIdentifier:@"first"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    NSURL *url1 = [NSURL URLWithString:@"app://user/12"];
    NSURL *url2 = [NSURL URLWithString:@"app://user/"];
    NSURL *url3 = [NSURL URLWithString:@"app://user"];
    NSURL *url4 = [NSURL URLWithString:@"/user/12"];
    NSLog(@"%@, %@, %@", url1, url2, url3);
//    self.testViewController = [TPTestViewController new];
//    [self.testViewController willMoveToParentViewController:self];
//    self.testViewController.view.frame = self.view.bounds;
//    self.testViewController.view.userInteractionEnabled = NO;
//    self.testViewController.definesPresentationContext = YES;
//    [self.view addSubview:self.testViewController.view];
//    [self addChildViewController:self.testViewController];
    
    self.definesPresentationContext = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)nextAction:(id)sender {
    TPPanelViewController *panelViewController = [TPPanelViewController new];
    panelViewController.preferredContentSize = CGSizeMake(100, 100);
//    panelViewController.modalPresentationStyle = UIModalPresentationCurrentContext;
//    panelViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    panelViewController.transitioningDelegate = self;
//    panelViewController.definesPresentationContext = YES;
//    [self.testViewController presentViewController:panelViewController animated:YES completion:nil];
    
    TPRouteIntent *intent = [[TPRouteIntent alloc] initWithURL:[NSURL URLWithString:@"/user/12345"]];
    [[TPRouter sharedRouter] startRoutableWithIntent:intent];
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return self;
}

- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext {
    return 5.0;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    UIView *containerView = [transitionContext containerView];
//    [self.view addSubview:containerView];
    UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    toView.frame = CGRectOffset(containerView.bounds, 0, -CGRectGetHeight(containerView.frame));
    [containerView addSubview:toView];
    CGRect finalFrame = [transitionContext finalFrameForViewController:[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey]];
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        toView.frame = CGRectMake(100, 100, 150, 150);
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    }];
}

@end
