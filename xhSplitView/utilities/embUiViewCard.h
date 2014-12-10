//
//  embUiViewCard.h
//  embUTCCardViews
//
//  Created by Evan Buxton on 11/25/14.
//  Copyright (c) 2014 neoscape. All rights reserved.
//

#import <UIKit/UIKit.h>

//----------------------------------------------------
#pragma mark - Delegate Protocol
//----------------------------------------------------

@class embUiViewCard;

@protocol embUiViewCardDelegate <NSObject>
@optional
- (void)inputFieldChangedText:(embUiViewCard *)field;

- (void)inputFieldBecameFirstResponder:(embUiViewCard *)field;

- (void)inputFieldResignedFirstResponder:(embUiViewCard *)field;

@end

//----------------------------------------------------
#pragma mark - Class
//----------------------------------------------------

@interface embUiViewCard : UIView

@property (nonatomic) NSString *text;
@property (nonatomic) int delay;
@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UITextView *textView;

@property (nonatomic, weak) id<embUiViewCardDelegate> delegate;

@end
