//
//  UIImage+UIImage_GaussianBlur.h
//  quadrangle
//
//  Created by Evan Buxton on 5/29/13.
//  Copyright (c) 2013 neoscape. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (UIImage_GaussianBlur)
- (UIImage*)gaussianBlur:(NSUInteger)radius from:(CIContext*)context;
@end