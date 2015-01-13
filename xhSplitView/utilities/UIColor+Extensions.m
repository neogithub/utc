//
//  UIColor+Extensions.m
//  650mad
//
//  Created by Evan Buxton on 9/27/12.
//
//

#import "UIColor+Extensions.h"

@implementation UIColor (Extensions)

#pragma mark
#pragma mark description

+ (UIColor *)colorWithHueDegrees:(CGFloat)hue saturation:(CGFloat)saturation brightness:(CGFloat)brightness {
    return [UIColor colorWithHue:(hue/360) saturation:saturation brightness:brightness alpha:1.0];
}

+ (UIColor *)colorWithR:(CGFloat)red G:(CGFloat)green B:(CGFloat)blue A:(CGFloat)alpha {
    return [UIColor colorWithRed:(red/255.0) green:(green/255.0) blue:(blue/255.0) alpha:alpha];
}

+ (UIColor *)utcSmokeGray {
	return [UIColor colorWithRed: 91.0f/255.0f green: 91.0f/255.0f blue: 91.0f/255.0f alpha: 1];
}

+ (UIColor *)utcBlueA {
    return [UIColor colorWithRed: 68.0f/255.0f green: 145.0f/255.0f blue: 201.0f/255.0f alpha: 1];
}

+ (UIColor *)utcBlueAlight {
    return [UIColor colorWithRed: 100.0f/255.0f green: 167.0f/255.0f blue: 212.0f/255.0f alpha: 1];
}

+ (UIColor *)utcBlueDarkA {
    return [UIColor colorWithRed: 0.0f/255.0f green: 53.0f/255.0f blue: 137.0f/255.0f alpha: 1];
}

+ (UIColor *)vcLightBlueAlpha {
    return [UIColor colorWithRed: 0.0f/255.0f green: 98.0f/255.0f blue: 152.0f/255.0f alpha: 0.6];
}

+ (UIColor *)vclightbluemenu {
	return[UIColor colorWithRed:0.5216 green:0.6941 blue:0.8000 alpha:0.90];
}

+ (UIColor *)vccyanmenu {
	return[UIColor colorWithRed:0.3373 green:0.6 blue:0.7294 alpha:0.92];
}

+ (UIColor *)vcdarkmenu {
	return[UIColor colorWithRed:0.0863 green:0.4627 blue:0.6275 alpha:0.96];
}

+ (UIColor *)vcmediummenu {
	return[UIColor colorWithRed:0.0000 green:0.4392 blue:0.6235 alpha:1];
}

+ (UIColor *)vcDarkBlue {
	return [UIColor colorWithRed: 31.0f/255.0f green: 53.0f/255.0f blue: 94.0f/255.0f alpha: 1];
}

+ (UIColor *)vcButtonBorder {
    return [UIColor colorWithRed: 230.0f/255.0f green: 232.0f/255.0f blue: 237.0f/255.0f alpha: 1];
}

+ (UIColor *)vcTeamLogoBg {
    return [UIColor colorWithRed:204.0/255.0 green:194.0/255.0 blue:185.0/255.0 alpha:0.9];
}

+ (UIColor *)vcSiteRestaurant {
    return [UIColor colorWithRed:188.0/255.0 green:196.0/255.0 blue:185.0/255.0 alpha:0.9];
}
+ (UIColor *)vcSiteRetail {
    return [UIColor colorWithRed:225.0/255.0 green:188.0/255.0 blue:175.0/255.0 alpha:0.9];
}
+ (UIColor *)vcSiteResidentail {
    return [UIColor colorWithRed:184.0/255.0 green:206.0/255.0 blue:208.0/255.0 alpha:0.9];
}
+ (UIColor *)vcSiteRecreation {
    return [UIColor colorWithRed:200.0/255.0 green:176.0/255.0 blue:187.0/255.0 alpha:0.9];
}

+ (UIColor *)vcBldParking {
    return [UIColor colorWithRed:224.0/255.0 green:224.0/255.0 blue:224.0/255.0 alpha:1.0];
}

+ (UIColor *)vcBackGroundColor {
    return [UIColor colorWithRed:243.0/255.0 green:240.0/255.0 blue:242.0/255.0 alpha:1.0];
}

+ (UIColor *)vcPanelBackgroundColor {
    return [UIColor colorWithRed:222.0/255.0 green:234.0/255.0 blue:242.0/255.0 alpha:1.0];
}

+ (UIColor *)vpYellow {
	return [UIColor colorWithRed:235.0f/255.0f green:199.0f/255.0f blue:111.0f/255.0f alpha:1.0];
}

+ (UIColor *)vpShadowBlue {
	return [UIColor colorWithRed:93.0f/255.0f green:162.0f/255.0f blue:205.0f/255.0f alpha:1.0];
}

+ (UIColor *)vpTextBlue {
	return [UIColor colorWithRed:43.0f/255.0f green:55.0f/255.0f blue:86.0f/255.0f alpha:1.0];
}

+ (UIColor *)vpBGBlue {
	return [UIColor colorWithRed:52.0f/255.0f green:138.0f/255.0f blue:192.0f/255.0f alpha:1.0];
}

+ (UIColor *)vpDirectionBlue {
	return [UIColor colorWithRed:43.0f/255.0f green:56.0f/255.0f blue:140.0f/255.0f alpha:1.0];
}

+ (UIColor *)randomColor {
    return [self colorWithRed:((float)rand() / RAND_MAX)
                        green:((float)rand() / RAND_MAX)
                         blue:((float)rand() / RAND_MAX)
                        alpha:1.0f];
}

// use self.view.backgroundColor = highlight? [UIColor paleYellowColor] : [UIColor whitecolor];

@end
