//
//  xhSplitViewController.h
//  xhSplitViewController
//
//  Created by Xiaohe Hu on 8/29/14.
//  Copyright (c) 2014 Neoscape. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface xhSplitViewController : UIViewController <UINavigationControllerDelegate>
{
    UINavigationController* masterNavigationController;
    UINavigationController* detailNavigationController;
    
//    UIView* uiv_master;
//    UIView* uiv_detail;
//    UIView* uiv_separator;
}

@property (strong, nonatomic) IBOutlet UINavigationController *masterNavigationController;
@property (strong, nonatomic) IBOutlet UINavigationController *detailNavigationController;

@property (weak, nonatomic) IBOutlet UIView *uiv_master;
@property (weak, nonatomic) IBOutlet UIView *uiv_detail;
@property (weak, nonatomic) IBOutlet UIView *uiv_separator;
@property (weak, nonatomic) IBOutlet UIView *uiv_masterContainer;

- (void)addMasterController:(UIViewController*)controller animated:(BOOL)anim;
- (void)addDetailController:(UIViewController*)controller animated:(BOOL)anim;
- (void)hideMasterPanel;
- (void)showPanel;
@end
