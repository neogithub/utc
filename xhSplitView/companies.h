//
//  companies.h
//  utc
//
//  Created by Evan Buxton on 9/9/14.
//  Copyright (c) 2014 Neoscape. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface companies : NSObject

@property (nonatomic, copy) NSString *name;

@property (nonatomic, copy) NSString *logo;

@property (nonatomic, copy) NSString *category;

@property (nonatomic, copy) NSArray *hotspots;

@end
