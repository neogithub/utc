//
//  companies.h
//  utc
//
//  Created by Evan Buxton on 9/9/14.
//  Copyright (c) 2014 Neoscape. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Company : NSObject

@property (nonatomic, retain, readonly) NSString *coname, *cologo, *coinfoname;

@property (nonatomic, retain, readonly) NSArray *cocategories, *cohotspots, *cofacts, *coibt;

@property (nonatomic, retain, readonly) NSDictionary *codata;


- (id)initWithTitle:(NSString*)name logo:(NSString*)logo categories:(NSArray*)categories coibt:(NSArray*)coibt hotspots:(NSArray*)hotspots facts:(NSArray*)facts infoName:(NSString*)infoname;

@end
