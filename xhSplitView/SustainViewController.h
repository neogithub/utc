//
//  IBTViewController.h
//  utc
//
//  Created by Evan Buxton on 12/27/14.
//  Copyright (c) 2014 Neoscape. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SustainViewControllerDelegate <NSObject>;
@end

@interface SustainViewController : UIViewController
@property (nonatomic, weak) id<SustainViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIImageView *uiiv_BG;


@property (weak, nonatomic) IBOutlet UIView *uiv_modalContainer;
- (IBAction)doDismiss: (id) sender;
-(IBAction)loadIBTDetail:(id)sender;
-(IBAction)loadIBTAtDetail:(NSNumber*)i;
@property (weak, nonatomic) IBOutlet UIView *uiv_header;
@property (weak, nonatomic) IBOutlet UIImageView *uiiv_header;
@property (strong, nonatomic) IBOutlet UIView *uiv_detail;
@property (strong, nonatomic) IBOutlet UIView *uiv_ibt;
@property (weak, nonatomic) IBOutlet UIView *uiv_ibtData;
@property (weak, nonatomic) IBOutlet UIButton *uib_learn;
@property (weak, nonatomic) IBOutlet UIView *uiv_logoBns;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *uibCollection;
@property (weak, nonatomic) IBOutlet UITextView *uitv_text;
@property (weak, nonatomic) IBOutlet UIImageView *uiiv_data;
@property (weak, nonatomic) IBOutlet UIView *uiv_buttons;
@property (strong, nonatomic) IBOutlet UIView *uiv_Text;
@property (weak, nonatomic) IBOutlet UITextView *uitv_sustain;
@property (weak, nonatomic) IBOutlet UIImageView *uiiv_arrow;
@property (weak, nonatomic) IBOutlet UILabel *uil_header;
@end
