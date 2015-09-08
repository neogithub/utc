//
//  embBezierPathItems.m
//  embAnimatedPath
//
//  Created by Evan Buxton on 2/19/14.
//  Copyright (c) 2014 neoscape. All rights reserved.
//

#import "embBldgTypePaths.h"
@implementation embBldgTypePaths

- (id) init
{
    if (self = [super init]) {
		
		// setup
		_bezierPaths = [[NSMutableArray alloc] init];
		
		
		UIColor *pathBlue = [UIColor colorWithRed:235/255.0f
											green:199.0f/255.0f
											 blue:113.0f/255.0f
											alpha:1.0];
       // UIColor *pathFill = [UIColor colorWithWhite:1.0
       //                                       alpha:1.0];
        
		CGFloat pathWidth = 7.0;
		CGFloat pathSpeed = 3.5;
		

		// Bezier paths created in paintcode
		// COPY FROM PAINTCODE

        //// commercial Drawing
        UIBezierPath* commercialPath = UIBezierPath.bezierPath;
        [commercialPath moveToPoint: CGPointMake(502.5, 245.5)];
        [commercialPath addLineToPoint: CGPointMake(400.5, 314.5)];
        [commercialPath addLineToPoint: CGPointMake(405.5, 363.5)];
        [commercialPath addLineToPoint: CGPointMake(330.5, 417.5)];
        [commercialPath addLineToPoint: CGPointMake(540.5, 533.5)];
        [commercialPath addLineToPoint: CGPointMake(544.5, 533.5)];
        [commercialPath addLineToPoint: CGPointMake(693.5, 388.5)];
        [commercialPath addLineToPoint: CGPointMake(693.5, 384.5)];
        [commercialPath addLineToPoint: CGPointMake(623.5, 355.5)];
        [commercialPath addLineToPoint: CGPointMake(628.5, 311.5)];
        [commercialPath addLineToPoint: CGPointMake(537.5, 274.5)];
        [commercialPath addLineToPoint: CGPointMake(537.5, 261.5)];
        [commercialPath addLineToPoint: CGPointMake(502.5, 245.5)];
        [commercialPath closePath];
	
        UIBezierPath* hotelPath = UIBezierPath.bezierPath;
        [hotelPath moveToPoint: CGPointMake(761.6, 166.4)];
        [hotelPath addLineToPoint: CGPointMake(744.92, 239.13)];
        [hotelPath addLineToPoint: CGPointMake(734.94, 235.42)];
        [hotelPath addLineToPoint: CGPointMake(713.85, 250.41)];
        [hotelPath addLineToPoint: CGPointMake(714.02, 261.6)];
        [hotelPath addLineToPoint: CGPointMake(723.03, 272.66)];
        [hotelPath addLineToPoint: CGPointMake(777.18, 293.7)];
        [hotelPath addLineToPoint: CGPointMake(806.5, 265.5)];
        [hotelPath addLineToPoint: CGPointMake(833.5, 171.5)];
        [hotelPath addLineToPoint: CGPointMake(776.95, 154.17)];
        [hotelPath addLineToPoint: CGPointMake(761.6, 166.4)];
        [hotelPath closePath];

		// END COPY FROM PAINT CODE

		
		// copy new paths from paint code above into array
		pathItem = [[embBezierPathItem alloc] init];
		pathItem.pathDelay = 1.0;
		pathItem.pathColor = pathBlue;
		pathItem.pathSpeed = pathSpeed;
		pathItem.pathWidth = pathWidth;
		pathItem.embPath = commercialPath;
		[_bezierPaths addObject:pathItem];
        
        pathItem = [[embBezierPathItem alloc] init];
        pathItem.pathDelay = 1.0;
        pathItem.pathColor = pathBlue;
        pathItem.pathSpeed = pathSpeed;
        pathItem.pathWidth = pathWidth;
        pathItem.embPath = hotelPath;
        [_bezierPaths addObject:pathItem];
	}
	
	return self;
}

@end
