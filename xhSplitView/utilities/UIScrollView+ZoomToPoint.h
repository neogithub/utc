//
//  UIScrollView+ZoomToPoint.h
//  utc
//
//  Created by Evan Buxton on 9/10/14.
//  Copyright (c) 2014 Neoscape. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIScrollView (ZoomToPoint)
- (void)zoomToPoint:(CGPoint)zoomPoint withScale: (CGFloat)scale animated: (BOOL)animated;
@end
