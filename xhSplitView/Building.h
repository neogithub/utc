//
//  Building.h
//  utc
//
//  Created by Evan Buxton on 9/9/14.
//  Copyright (c) 2014 Neoscape. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Building : NSObject

@property (nonatomic) NSInteger index;

@property (nonatomic, copy) NSString *address;

@property (nonatomic, copy) NSString *zoomingMovieName;

@property (nonatomic, copy) NSArray *categories;

@property (nonatomic, copy) NSArray *companies;

@property (nonatomic, copy) NSArray *hotspots;

@end
