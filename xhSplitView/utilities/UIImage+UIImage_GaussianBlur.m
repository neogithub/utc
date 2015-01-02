//
//  UIImage+UIImage_GaussianBlur.m
//  quadrangle
//
//  Created by Evan Buxton on 5/29/13.
//  Copyright (c) 2013 neoscape. All rights reserved.
//

#import "UIImage+UIImage_GaussianBlur.h"

@implementation UIImage (UIImage_GaussianBlur)

- (UIImage*)gaussianBlur:(NSUInteger)radius from:(CIContext*)context
{
	CGImageRef inImage = self.CGImage;
	//Blur the UIImage
	CIImage *imageToBlur = [CIImage imageWithCGImage:inImage];
	CIFilter *gaussianBlurFilter = [CIFilter filterWithName: @"CIGaussianBlur"];
	[gaussianBlurFilter setValue:imageToBlur forKey: @"inputImage"];
	[gaussianBlurFilter setValue:[NSNumber numberWithFloat: radius] forKey: @"inputRadius"];
	CIImage *resultImage = [gaussianBlurFilter valueForKey:kCIOutputImageKey];
	CGImageRef cgImage = [context createCGImage:resultImage fromRect:[imageToBlur extent]];
	UIImage* endImage = [UIImage imageWithCGImage: cgImage];
	return endImage;
}


@end
