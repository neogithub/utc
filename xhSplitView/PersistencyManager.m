//
//  PersistencyManager.m
//  utc
//
//  Created by Evan Buxton on 12/11/14.
//  Copyright (c) 2014 Neoscape. All rights reserved.
//

#import "PersistencyManager.h"

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
									   @"companyData" ofType:@"plist"];
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

- (NSArray*)getSelectedCompanyNamed:(NSString*)name
{
	NSArray *filtered = [companies filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(fileName == %@)", name]];
	
	NSDictionary *data = filtered[0];
	
	_selectedCompany = [[Company alloc] initWithTitle:[data objectForKey:@"fileName"]
												 logo:[data objectForKey:@"background"]
										   categories:[data objectForKey:@"categories"]
											 hotspots:[data objectForKey:@"hotspots"]
												facts:[data objectForKey:@"type"]];
	
	return filtered;
}

-(Company*)getSelectedCompanyData
{
	return _selectedCompany;
}

@end
