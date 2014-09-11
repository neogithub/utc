//
//  UIPopUpHelp.m
//  utc
//
//  Created by Evan Buxton on 9/11/14.
//  Copyright (c) 2014 Neoscape. All rights reserved.
//

#import "UIPopUpHelp.h"

@implementation UIPopUpHelp

- (id)initWithFrame:(CGRect)frame imgnamed:(NSString*)imgname toView:(UIView*)view
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		
		UIImageView *scrollHelpView = [[UIImageView alloc] initWithFrame:frame];
		scrollHelpView.image = [UIImage imageNamed:imgname];
		[view addSubview:scrollHelpView];
		
		[self pulse:scrollHelpView.layer];
		
		[UIView animateWithDuration:0.33
	 					 animations:^{
							 scrollHelpView.transform = CGAffineTransformMakeTranslation(0, -95);
						 }
	 					 completion:^(BOOL  completed){
							 [UIView animateWithDuration:0.3 delay:2.0 options:0
											  animations:^{
												  scrollHelpView.transform = CGAffineTransformIdentity;
											  }
											  completion:^(BOOL  completed){  }];}];
    }
    return self;
}

-(void)pulse:(CALayer*)incomingLayer
{
	CABasicAnimation *theAnimation;
	CALayer *pplayer = incomingLayer;
	theAnimation=[CABasicAnimation animationWithKeyPath:@"opacity"];
	theAnimation.duration=0.5;
	theAnimation.repeatCount=HUGE_VAL;
	theAnimation.autoreverses=YES;
	theAnimation.fromValue=[NSNumber numberWithFloat:1.0];
	theAnimation.toValue=[NSNumber numberWithFloat:0.5];
	[pplayer addAnimation:theAnimation forKey:@"animateOpacity"];
}


@end
