//
//  detailViewController.h
//  xhSplitViewController
//
//  Created by Xiaohe Hu on 9/2/14.
//  Copyright (c) 2014 Neoscape. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "masterViewController.h"
@class detailViewController;

@protocol detailViewControllerDelegate <NSObject>
- (void)rowSelected:(detailViewController *)controller atIndex:(NSInteger *)index;
@end

@interface detailViewController : UIViewController
@property (weak,nonatomic) masterViewController <detailViewControllerDelegate> *delegate;
@end
