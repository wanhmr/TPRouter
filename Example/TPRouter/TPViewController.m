//
//  TPViewController.m
//  TPRouter
//
//  Created by wanhmr on 08/05/2019.
//  Copyright (c) 2019 wanhmr. All rights reserved.
//

#import "TPViewController.h"
@import TPRouter;

@interface TPViewController () <TPViewRoutable>

@end

@implementation TPViewController

- (instancetype)initWithParams:(NSDictionary *)params {
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)nextAction:(id)sender {
    TPViewRoutableLauncher *launcher = [[TPViewRoutableLauncher alloc] initWithMode:TPViewRoutableLaunchModeAuto animated:YES];
    TPRouteIntent *intent = [[TPRouteIntent alloc] initWithURL:[NSURL URLWithString:@"/user/12345"] routableLauncher:launcher];
    [[TPRouter sharedRouter] routeIntent:intent];
}

@end
