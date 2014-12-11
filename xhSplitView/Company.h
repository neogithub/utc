//
//  companies.h
//  utc
//
//  Created by Evan Buxton on 9/9/14.
//  Copyright (c) 2014 Neoscape. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Company : NSObject

@property (nonatomic, copy, readonly) NSString *name, *logo;

@property (nonatomic, copy, readonly) NSArray *categories, *hotspots, *facts;

- (id)initWithTitle:(NSString*)name logo:(NSString*)logo categories:(NSArray*)categories hotspots:(NSArray*)hotspots facts:(NSArray*)facts;

@end
