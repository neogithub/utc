//
//  FlipImage.m
//  utc
//
//  Created by Evan Buxton on 12/30/14.
//  Copyright (c) 2014 Neoscape. All rights reserved.
//

#import "UIImage+FlipImage.h"

@implementation UIImage (FlipImage)

+ (UIImage *)flipImage:(UIImage *)image
{
    UIGraphicsBeginImageContext(image.size);
    CGContextDrawImage(UIGraphicsGetCurrentContext(),CGRectMake(0.,0., image.size.width, image.size.height),image.CGImage);
    UIImage *i = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return i;
}

@end
