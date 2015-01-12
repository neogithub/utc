//
//  embBezierPath.h
//  embAnimatedPath
//
//  Created by Evan Buxton on 2/19/14.
//  Copyright (c) 2014 neoscape. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface embBezierPathItem : NSObject

@property CGFloat		pathDelay;
@property CGFloat		pathSpeed;
@property UIColor		*pathColor;
@property CGFloat		pathWidth;
@property UIBezierPath	*embPath;

@end
