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
@property (weak, nonatomic) IBOutlet UIImageView *uiiv_BG;



-(IBAction)loadIBT:(id)sender;
-(IBAction)loadIBTAtDetail:(NSNumber*)i;

@property (weak, nonatomic) IBOutlet UIView *uiv_modalContainer;
- (IBAction)doDismiss: (id) sender;
@property (weak, nonatomic) IBOutlet UIView *uiv_header;
@property (weak, nonatomic) IBOutlet UIImageView *uiiv_header;
@property (strong, nonatomic) IBOutlet UIView *uiv_detail;
@property (strong, nonatomic) IBOutlet UIView *uiv_ibt;
@property (weak, nonatomic) IBOutlet UIView *uiv_ibtData;
@property (weak, nonatomic) IBOutlet UIView *uiv_logoBns;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *uibCollection;
@property (weak, nonatomic) IBOutlet UIImageView *uiiv_arrow;
@property (weak, nonatomic) IBOutlet UIButton *uib_top;
@property (weak, nonatomic) IBOutlet UIButton *uib_btm;
@property (weak, nonatomic) IBOutlet UIImageView *uiiv_logo;
@property (weak, nonatomic) IBOutlet UITextView *uitv_connectText;
@property (weak, nonatomic) IBOutlet UIView *uiv_summaryText;
@property (weak, nonatomic) IBOutlet UIButton *uib_learnTop;
@property (weak, nonatomic) IBOutlet UIButton *uib_learnBtm;
@property (weak, nonatomic) IBOutlet UIButton *uib_learnMid;
@property (weak, nonatomic) IBOutlet UILabel *uil_UIcue;
@property (weak, nonatomic) IBOutlet UIImageView *uiiv_pointer;
@property (weak, nonatomic) IBOutlet UILabel    *uil_title;
@property (weak, nonatomic) IBOutlet UILabel    *uil_about;

@property (weak, nonatomic) IBOutlet UILabel *uil_UTtitle;
@property (weak, nonatomic) IBOutlet UILabel *uil_UTSubTitle;
@property (weak, nonatomic) IBOutlet UILabel *uil_IBTTitle;
@property (weak, nonatomic) IBOutlet UILabel *uil_IBTContent1;
@property (weak, nonatomic) IBOutlet UILabel *uil_IBTContent2;
@property (weak, nonatomic) IBOutlet UILabel *uil_selectLogo;


@end
