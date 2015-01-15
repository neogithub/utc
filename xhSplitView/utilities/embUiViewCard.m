//
//  embUiViewCard.m
//  embUTCCardViews
//
//  Created by Evan Buxton on 11/25/14.
//  Copyright (c) 2014 neoscape. All rights reserved.
//

#import "embUiViewCard.h"
#import "NSAttributedString+RegisteredTrademark.h"

@interface embUiViewCard () <UITextViewDelegate>

@property (nonatomic) CGFloat delayApperanceBy;

@end

@implementation embUiViewCard

@dynamic delay, text;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupAppearance];
    }
    return self;
}

- (void)awakeFromNib
{
    [self setupAppearance];
}

- (void)setupAppearance
{
    self.backgroundColor = [UIColor clearColor];
}

//----------------------------------------------------
#pragma mark - Elements
//----------------------------------------------------

+ (UIImage *)backgroundImage
{
    UIImage *ret = [[UIImage alloc] init];
	// top left bottom right
	ret = [[UIImage imageNamed:@"text_bg.png"]resizableImageWithCapInsets:UIEdgeInsetsMake(100,0,0,0)];
	
    return ret;
}

+ (UIFont *)defaultFont
{
    return [UIFont systemFontOfSize:17];
}

+ (UIEdgeInsets)textInsets
{
    UIEdgeInsets ret = {.left = 21, .right = 15, .top = 13, .bottom = 10};

    return ret;
}

//----------------------------------------------------
#pragma mark - Structural
//----------------------------------------------------

- (UIImageView *)backgroundImageView
{
    if (_backgroundImageView == nil) {
        _backgroundImageView = [[UIImageView alloc] initWithImage:[self.class backgroundImage]];
        _backgroundImageView.backgroundColor = [UIColor clearColor];
		
        [self addSubview:_backgroundImageView];
        [self sendSubviewToBack:_backgroundImageView];
    }
    return _backgroundImageView;
}

- (UITextView *)textView
{
    if (_textView == nil) {
        _textView = [[UITextView alloc] initWithFrame:CGRectZero];
        _textView.delegate = self;
        _textView.font = [self.class defaultFont];
		//_textView.textColor = [UIColor whiteColor];
        _textView.backgroundColor = [UIColor clearColor];
		_textView.contentSize = self.frame.size;
		_textView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
		_textView.textContainerInset = [self.class textInsets];
		
        [self addSubview:_textView];
    }
    return _textView;
}

//----------------------------------------------------
#pragma mark - Layout
//----------------------------------------------------

- (void)layoutSubviews
{
    [super layoutSubviews];
	
    self.backgroundImageView.frame = self.bounds;
    self.textView.frame = self.bounds;
}

//----------------------------------------------------
#pragma mark - Delegate Communication
//----------------------------------------------------

- (void)reportTextChanged
{
    if ([_delegate respondsToSelector:@selector(inputFieldChangedText:)]) {
        [_delegate inputFieldChangedText:self];
    }
}

- (void)reportResignedFirstResponder
{
    if ([_delegate respondsToSelector:@selector(inputFieldResignedFirstResponder:)]) {
        [_delegate inputFieldResignedFirstResponder:self];
    }
}

- (void)reportBecameFirstResponder
{
    if ([_delegate respondsToSelector:@selector(inputFieldBecameFirstResponder:)]) {
        [_delegate inputFieldBecameFirstResponder:self];
    }
}

//----------------------------------------------------
#pragma mark - Properties
//----------------------------------------------------
/*
 This is used for updating the layer
*/

- (NSString *)text
{
    return self.textView.text;
}

- (void)setText:(NSString *)text
{
   // [self.textView setText:text];
    NSAttributedString *t = [[NSAttributedString alloc] initWithString:text];
    NSAttributedString *g = [t addRegisteredTrademarkTo:text withColor:[UIColor whiteColor] fnt:[UIFont fontWithName:@"Helvetica" size:17]];
    self.textView.attributedText = g;
}

- (int )delay
{
    return self.delayApperanceBy;
}

- (void)setDelay:(int )delay
{
    self.delayApperanceBy = delay;
}

@end
