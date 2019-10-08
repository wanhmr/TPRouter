//
//  TPPanelViewController.m
//  TPRouter_Example
//
//  Created by Tpphha on 2019/8/7.
//  Copyright © 2019 wanhmr. All rights reserved.
//

#import "TPPanelViewController.h"

@interface TPPanelViewController ()

@end

@implementation TPPanelViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor redColor];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    [btn addTarget:self action:@selector(dismiss:) forControlEvents:UIControlEventTouchUpInside];
    [btn setTitle:@"dismiss" forState:UIControlStateNormal];
    [self.view addSubview:btn];
    
    btn.translatesAutoresizingMaskIntoConstraints = NO;
    [btn.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    [btn.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor].active = YES;
}

- (void)dismiss:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
