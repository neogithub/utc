//
//  City.h
//  utc
//
//  Created by Evan Buxton on 9/9/14.
//  Copyright (c) 2014 Neoscape. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface City : NSObject

// a city with multiple buildings
@property (nonatomic) NSInteger index;
@property (nonatomic, copy) NSString *name;

@end
