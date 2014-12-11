//
//  companies.m
//  utc
//
//  Created by Evan Buxton on 9/9/14.
//  Copyright (c) 2014 Neoscape. All rights reserved.
//

#import "Company.h"

@implementation Company

- (id)initWithTitle:(NSString*)name logo:(NSString*)logo categories:(NSArray*)categories hotspots:(NSArray*)hotspots facts:(NSArray*)facts
{
	self = [super init];
	if (self)
	{
		_name = name;
		_logo = logo;
		_categories = categories;
		_hotspots = hotspots;
		_facts = facts;
	}
	return self;
}

@end
