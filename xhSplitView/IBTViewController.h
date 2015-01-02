//
//  IBTViewController.h
//  utc
//
//  Created by Evan Buxton on 12/27/14.
//  Copyright (c) 2014 Neoscape. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol IBTViewControllerDelegate <NSObject>;
@end

@interface IBTViewController : UIViewController
@property (nonatomic, weak) id<IBTViewControllerDelegate> delegate;

-(IBAction)loadIBT:(id)sender;
-(IBAction)loadIBTAtDetail:(NSNumber*)i;

@property (weak, nonatomic) IBOutlet UIView *uiv_modalContainer;
- (IBAction)doDismiss: (id) sender;
@property (weak, nonatomic) IBOutlet UIView *uiv_header;
@property (weak, nonatomic) IBOutlet UIImageView *uiiv_header;
@property (strong, nonatomic) IBOutlet UIView *uiv_detail;
@property (strong, nonatomic) IBOutlet UIView *uiv_ibt;
@property (weak, nonatomic) IBOutlet UIView *uiv_ibtData;
@property (weak, nonatomic) IBOutlet UILabel *uib_learn;
@property (weak, nonatomic) IBOutlet UIView *uiv_logoBns;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *uibCollection;
@end
