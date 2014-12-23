//
//  companies.m
//  utc
//
//  Created by Evan Buxton on 9/9/14.
//  Copyright (c) 2014 Neoscape. All rights reserved.
//

#import "Company.h"

@implementation Company

- (id)initWithTitle:(NSString*)name logo:(NSString*)logo categories:(NSArray*)categories hotspots:(NSArray*)hotspots facts:(NSArray*)facts infoName:(NSString*)infoname
{
	self = [super init];
	if (self)
	{
		_coname = name;
		_cologo = logo;
		
		_coinfoname = infoname;
		
		_cocategories = [[NSArray alloc] init];
		_cocategories = categories;
		_cohotspots = [[NSArray alloc] init];
		_cohotspots = hotspots;
		_cofacts = [[NSArray alloc] init];
		_cofacts = facts;
		
		//NSLog(@"co  %@",_coname);
		//NSLog(@"co  %@",_cologo);
		//NSLog(@"co  %@",_cocategories);
		//NSLog(@"co  %@",_cohotspots);
		//NSLog(@"co  %@",_cofacts);
		
	}
	return self;
}

-(id)init
{
	self = [super init];
	if (self)
	{
//		_coname = name;
//		_cologo = logo;
//		
//		_cocategories = [[NSArray alloc] init];
//		_cocategories = categories;
//		_cohotspots = [[NSArray alloc] init];
//		_cohotspots = hotspots;
//		_cofacts = [[NSArray alloc] init];
//		_cofacts = facts;
//		
//		NSLog(@"co  %@",_coname);
//		NSLog(@"co  %@",_cologo);
//		NSLog(@"co  %@",_cocategories);
//		NSLog(@"co  %@",_cohotspots);
//		NSLog(@"co  %@",_cofacts);
		
	}
	return self;
}

@end
