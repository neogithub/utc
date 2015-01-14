//
//  embTitle.m
//  utc
//
//  Created by Evan Buxton on 12/15/14.
//  Copyright (c) 2014 Neoscape. All rights reserved.
//

#define kshowNSLogBOOL NO

#import "embTitle.h"
#import "NSAttributedString+RegisteredTrademark.h"

static CGFloat backButtonHeight = 51;
static CGFloat backButtonActualHeight = 44;

enum {
	LabelOnscreen,
	LabelOffscreen,
};

@implementation embTitle

#pragma mark - Init Company and Hotspot Labels

-(id)initWithFrame:(CGRect)frame withText:(NSString*)text startX:(CGFloat)startx width:(CGFloat)widthx
{
	self = [super initWithFrame:frame];
	if (self) {
		_uiv_textBoxContainer = [[UIView alloc] initWithFrame:CGRectZero];
		[self addSubview:_uiv_textBoxContainer];
		_uiv_textBoxContainer.layer.zPosition = MAXFLOAT;
        _backButtonX = startx;
        _backButtonWidth = widthx;
        [self setCompanyTitle:text];

	}
	return self;
}

#pragma mark - add titles

-(void)setCompanyTitle:(NSString *)year
{
	if (kshowNSLogBOOL) NSLog(@"setCompanyTitle");

	[self removeCompanyTitle];
	
	// get width of uilabel
	UIFont *font = [UIFont fontWithName:@"Helvetica-Bold" size:19];
	CGFloat str_width = [self getWidthFromStringLength:year andFont:font];
	static CGFloat labelPad = 15;
	companyLabelWidth = str_width + (labelPad*2);
	
	_uil_Company = [[UILabel alloc] initWithFrame:CGRectMake(0.0, -backButtonActualHeight, companyLabelWidth, backButtonActualHeight)];
	//[_uil_Company setText:year];
    
    NSAttributedString *t = [[NSAttributedString alloc] initWithString: year ];
    NSAttributedString *g = [t addRegisteredTrademarkTo:year withColor:[UIColor blackColor] fnt:[UIFont fontWithName:@"Helvetica-Bold" size:19]];
    _uil_Company.attributedText = g;
    
	[_uil_Company setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.8]];
	[_uil_Company setTextColor:[UIColor blackColor]];
	//[_uil_Company setFont: font];
	[_uil_Company setTextAlignment:NSTextAlignmentCenter];
	[_uil_Company.layer setBorderColor:[UIColor lightGrayColor].CGColor];
	[_uil_Company.layer setBorderWidth:1.0];
	
	[_uiv_textBoxContainer addSubview: _uil_Company];

	// resize text container to fit
	_uiv_textBoxContainer.frame = CGRectMake(_backButtonX+_backButtonWidth-7, 0, companyLabelWidth, backButtonHeight);
	
	[self animateView:_uil_Company direction:LabelOnscreen];
}


-(void)setHotSpotTitle:(NSString *)string
{
	if (kshowNSLogBOOL) NSLog(@"setHotSpotTitle");

	[self removeHotspotTitle];
	
	// get width of uilabel
	UIFont *font = [UIFont fontWithName:@"Helvetica" size:19];
	CGFloat str_width = [self getWidthFromStringLength:string andFont:font];
	static CGFloat labelPad = 20;
	hotspotLabelWidth = str_width + (labelPad);
	
	_uil_HotspotTitle = [[UILabel alloc] initWithFrame:CGRectMake(companyLabelWidth, -backButtonActualHeight, hotspotLabelWidth, backButtonActualHeight)];
	[_uil_HotspotTitle setText:string];
    
    NSAttributedString *t = [[NSAttributedString alloc] initWithString: string ];
    NSAttributedString *g = [t addRegisteredTrademarkTo: string withColor:[UIColor whiteColor] fnt:[UIFont fontWithName:@"Helvetica" size:19]];
    _uil_HotspotTitle.attributedText = g;
    
	_uil_HotspotTitle.backgroundColor = [UIColor colorWithRed:0.0000 green:0.4667 blue:0.7686 alpha:0.8];
	[_uil_HotspotTitle setTextColor:[UIColor whiteColor]];
	[_uil_HotspotTitle setTextAlignment:NSTextAlignmentCenter];
	//[_uil_HotspotTitle setFont:font];
	[_uil_HotspotTitle.layer setBorderColor:[UIColor colorWithRed:0.7922 green:1.0000 blue:1.0000 alpha:1.0].CGColor];
	[_uil_HotspotTitle.layer setBorderWidth:1.0];
	
	[_uiv_textBoxContainer addSubview: _uil_HotspotTitle];
	
	[self animateView:_uil_HotspotTitle direction:LabelOnscreen];
}

#pragma mark - append hotspot title

-(void)appendHotSpotTitle:(NSString *)string
{
	if (kshowNSLogBOOL) NSLog(@"appendHotSpotTitle");
	_appendString = _uil_HotspotTitle.text;
	NSString *aappendString = [NSString stringWithFormat:@"   |   %@", string];
	
	NSString *newString = [_appendString stringByAppendingString:aappendString];
	
	UIFont *font = [UIFont fontWithName:@"Helvetica" size:17];
	CGFloat str_width = [self getWidthFromStringLength:newString andFont:font];
	static CGFloat labelPad = 20;
	hotspotLabelWidth = str_width + (labelPad);
	
	_uil_HotspotTitle.frame = CGRectMake(companyLabelWidth, 0, hotspotLabelWidth+companyLabelWidth, backButtonActualHeight);
	
	_uil_HotspotTitle.text = newString;
    
    NSAttributedString *t = [[NSAttributedString alloc] initWithString: newString ];
    NSAttributedString *g = [t addRegisteredTrademarkTo: newString withColor:[UIColor whiteColor] fnt:[UIFont fontWithName:@"Helvetica" size:19]];
    _uil_HotspotTitle.attributedText = g;
    
	if (kshowNSLogBOOL) NSLog(@"%@",_uil_HotspotTitle.text);
}

#pragma mark - remove titles

-(void)removeCompanyTitle
{
    [self animateView:_uil_Company direction:LabelOffscreen];
}

-(void)removeHotspotTitle
{
	[self animateView:_uil_HotspotTitle direction:LabelOffscreen];
}

#pragma mark - animate titles

-(void)animateView:(UIView*)viewmove direction:(NSInteger)d
{
	int f = 0;
	if (d == LabelOffscreen) {
		f = -backButtonActualHeight;
	} else {
		f = backButtonActualHeight;
	}
	
	[UIView animateWithDuration:0.3/1.5 animations:^{
		viewmove.frame = CGRectMake(viewmove.frame.origin.x, viewmove.frame.origin.y+f, viewmove.frame.size.width, viewmove.frame.size.height);
	} completion:^(BOOL completed){
		if (d == LabelOffscreen) {
			[viewmove removeFromSuperview];
		}
	}];
}

#pragma mark get width of string text
-(float)getWidthFromStringLength:(NSString*)string andFont:(UIFont*)stringfont
{
	UIFont *font = stringfont;
	NSDictionary *attributes1 = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil];
	CGFloat str_width = [[[NSAttributedString alloc] initWithString:string attributes:attributes1] size].width;
	if (kshowNSLogBOOL) NSLog(@"The string width is %f", str_width);
	return str_width;
}

@end
