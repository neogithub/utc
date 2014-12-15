//
//  embTitle.m
//  utc
//
//  Created by Evan Buxton on 12/15/14.
//  Copyright (c) 2014 Neoscape. All rights reserved.
//

#import "embTitle.h"

static CGFloat backButtonHeight = 51;
static CGFloat backButtonWidth	= 58;
static CGFloat backButtonX		= 36;
static CGFloat backButtonActualHeight = 44;

enum {
	LabelOnscreen,
	LabelOffscreen,
};
typedef NSInteger PlayerState;

@implementation embTitle

#pragma mark - Info Labels
#pragma mark init top left text box


-(id)initWithFrame:(CGRect)frame withText:(NSString*)text
{

	self = [super initWithFrame:frame];
	if (self) {
		_uiv_textBoxContainer = [[UIView alloc] initWithFrame:CGRectZero];
		[self addSubview:_uiv_textBoxContainer];
		_uiv_textBoxContainer.layer.zPosition = MAXFLOAT;
		[self setCompanyTitle:text];
	}
	return self;

}

-(void)setCompanyTitle:(NSString *)year
{
	[self removeCompanyTitle];
	
	// get width of uilabel
	UIFont *font = [UIFont fontWithName:@"Helvetica-Bold" size:19];
	CGFloat str_width = [self getWidthFromStringLength:year andFont:font];
	static CGFloat labelPad = 15;
	companyLabelWidth = str_width + (labelPad*2);
	
	_uil_Company = [[UILabel alloc] initWithFrame:CGRectMake(0.0, -backButtonActualHeight, companyLabelWidth, backButtonActualHeight)];
	[_uil_Company setText:year];
	[_uil_Company setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.8]];
	[_uil_Company setTextColor:[UIColor blackColor]];
	[_uil_Company setFont: font];
	[_uil_Company setTextAlignment:NSTextAlignmentCenter];
	[_uil_Company.layer setBorderColor:[UIColor lightGrayColor].CGColor];
	[_uil_Company.layer setBorderWidth:1.0];
	
	[_uiv_textBoxContainer addSubview: _uil_Company];
	
	// resize text container to fit
	_uiv_textBoxContainer.frame = CGRectMake(backButtonX+backButtonWidth-7, 0, companyLabelWidth, backButtonHeight);
	
	[self animate:_uil_Company direction:LabelOnscreen];
}

-(void)removeCompanyTitle
{
	[self animate:_uil_Company direction:LabelOffscreen];
}

-(void)setHotSpotTitle:(NSString *)string
{
	[self removeHotspotTitle];
	
	// get width of uilabel
	UIFont *font = [UIFont fontWithName:@"Helvetica" size:19];
	CGFloat str_width = [self getWidthFromStringLength:string andFont:font];
	static CGFloat labelPad = 20;
	hotspotLabelWidth = str_width + (labelPad);
	
	_uil_HotspotTitle = [[UILabel alloc] initWithFrame:CGRectMake(companyLabelWidth-backButtonWidth-15, -backButtonActualHeight, hotspotLabelWidth, backButtonActualHeight)];
	[_uil_HotspotTitle setText:string];
	_uil_HotspotTitle.backgroundColor = [UIColor colorWithRed:0.0000 green:0.4667 blue:0.7686 alpha:0.8];
	[_uil_HotspotTitle setTextColor:[UIColor whiteColor]];
	[_uil_HotspotTitle setTextAlignment:NSTextAlignmentCenter];
	[_uil_HotspotTitle setFont:font];
	[_uil_HotspotTitle.layer setBorderColor:[UIColor colorWithRed:0.7922 green:1.0000 blue:1.0000 alpha:1.0].CGColor];
	[_uil_HotspotTitle.layer setBorderWidth:1.0];
	
	[_uiv_textBoxContainer addSubview: _uil_HotspotTitle];
	
	// resize text container to fit
	_uiv_textBoxContainer.frame = CGRectMake(73, 0, hotspotLabelWidth+companyLabelWidth, backButtonHeight);
	
	[self animate:_uil_HotspotTitle direction:LabelOnscreen];
}

-(void)removeHotspotTitle
{
	[self animate:_uil_HotspotTitle direction:LabelOffscreen];
}

-(void)animate:(UIView*)viewmove direction:(NSInteger)d
{
	int f = 0;
	if (d == LabelOffscreen) {
		f = -backButtonActualHeight;
	} else {
		f = backButtonActualHeight;
	}
	
	[UIView animateWithDuration:0.3/1.5 animations:^{
		//viewmove.transform = CGAffineTransformTranslate(viewmove.transform, 0, 1*f);
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
	// NSLog(@"The string width is %f", str_width);
	return str_width;
}

@end
