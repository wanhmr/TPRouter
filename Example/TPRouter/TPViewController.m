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

- (instancetype)initWithExtras:(NSDictionary *)extras {
    NSLog(@"extras data: %@", extras);
    return
    [[UIStoryboard storyboardWithName:@"Main" bundle:nil]
     instantiateViewControllerWithIdentifier:@"first"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)nextAction:(id)sender {
    TPViewRoutableLauncher *launcher = [[TPViewRoutableLauncher alloc] initWithMode:TPViewRoutableLaunchModeAuto animated:YES];
    TPRouteIntent *intent = [[TPRouteIntent alloc] initWithURL:[NSURL URLWithString:@"app://user/12"] routableLauncher:launcher];
    [[TPRouter sharedRouter] routeIntent:intent];
}

@end
