//
//  PersistencyManager.m
//  utc
//
//  Created by Evan Buxton on 12/11/14.
//  Copyright (c) 2014 Neoscape. All rights reserved.
//

#import "PersistencyManager.h"
#import "Company.h"

@implementation PersistencyManager
{
	// an array of all albums
	NSMutableArray *companies;
}

- (id)init
{
	self = [super init];
	if (self) {
					 companies = [[NSMutableArray alloc] init];
					 
					 NSString *path = [[NSBundle mainBundle] pathForResource:
									   @"companyHotspotsData" ofType:@"plist"];
					 NSMutableArray *totalDataArray = [[NSMutableArray alloc] initWithContentsOfFile:path];
		
		companies = totalDataArray;
	}
	return self;
}

- (NSArray*)getCompanies
{
	return companies;
}

- (NSMutableArray*)getCompanyNames
{
	
	NSMutableArray *arr_names= [[NSMutableArray alloc] init];
	
	for (int i = 0; i < [companies count]; i++) {
		NSDictionary *hotspotItem = companies [i];
#ifdef NEODEMO
		[arr_names addObject:[hotspotItem objectForKey:@"demoName"]];
#else
		[arr_names addObject:[hotspotItem objectForKey:@"fileName"]];
#endif
	}
	return arr_names;
}


@end
