//
//  xhSplitViewController.m
//  xhSplitViewController
//
//  Created by Xiaohe Hu on 8/29/14.
//  Copyright (c) 2014 Neoscape. All rights reserved.
//

#import "xhSplitViewController.h"

@interface xhSplitViewController ()

@end

@implementation xhSplitViewController
@synthesize  uiv_detail;
@synthesize uiv_master;
@synthesize uiv_separator;
@synthesize masterNavigationController;
@synthesize detailNavigationController;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)addMasterController:(UIViewController*)controller animated:(BOOL)anim
{
    if (masterNavigationController != nil)
        [masterNavigationController.view removeFromSuperview];
    masterNavigationController = nil;
    
    masterNavigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    masterNavigationController.delegate = self;

    masterNavigationController.navigationBar.translucent = NO;
    masterNavigationController.navigationBar.opaque = YES;
//    masterNavigationController.navigationBar.barTintColor = [UIColor colorWithRed:13.0/255.0 green:29.0/255.0 blue:55.0/255.0 alpha:1.0];
    [masterNavigationController setNavigationBarHidden:YES];
    
    masterNavigationController.view.frame = uiv_master.bounds;
    controller.view.frame = masterNavigationController.view.bounds;
    
    [uiv_master addSubview:masterNavigationController.view];
}

- (void)addDetailController:(UIViewController *)controller animated:(BOOL)anim
{
    if (detailNavigationController != nil)
        [detailNavigationController.view removeFromSuperview];
    detailNavigationController = nil;
    
    detailNavigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    detailNavigationController.delegate = self;
    
    detailNavigationController.navigationBar.translucent = NO;
    detailNavigationController.navigationBar.opaque = YES;
    detailNavigationController.navigationBar.tintColor = [UIColor blackColor];
    [detailNavigationController setNavigationBarHidden:YES];
    
    detailNavigationController.view.frame = uiv_detail.bounds;
    controller.view.frame = detailNavigationController.view.bounds;
    
    [uiv_detail addSubview:detailNavigationController.view];
}

-(void)hideMasterPanel
{
    //    uiv_masterContainer.frame = CGRectMake(-180, 0.0, 180, 768);
    [UIView animateWithDuration:0.33 animations:^{
        uiv_detail.frame = CGRectMake(0.0, 0.0, 1024, 768);
    }];
}

-(void)showPanel
{
    [UIView animateWithDuration:0.33 animations:^{
        uiv_detail.frame = CGRectMake(180.0, 0.0, 1024, 768);
    }];
}

- (void) viewDidAppear:(BOOL)animated
{
	[masterNavigationController viewDidAppear:animated];
	[detailNavigationController viewDidAppear:animated];
	[super viewDidAppear:animated];
}

- (void) viewWillAppear:(BOOL)animated
{
    [masterNavigationController viewWillAppear:animated];
    [detailNavigationController viewWillAppear:animated];
    [super viewWillAppear:animated];
}
- (void) viewWillDisappear:(BOOL)animated
{
    [masterNavigationController viewWillDisappear:animated];
    [detailNavigationController viewWillDisappear:animated];
    [super viewWillDisappear:animated];
}
- (void) viewDidDisappear:(BOOL)animated
{
    [masterNavigationController viewDidDisappear:animated];
    [detailNavigationController viewDidDisappear:animated];
    [super viewDidDisappear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
