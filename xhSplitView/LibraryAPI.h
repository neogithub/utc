//
//  LibraryAPI.h
//  utc
//
//  Created by Evan Buxton on 12/11/14.
//  Copyright (c) 2014 Neoscape. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Company.h"

@interface LibraryAPI : NSObject

+ (LibraryAPI*)sharedInstance;
- (NSArray*)getCompanies;
- (NSMutableArray*)getCompanyNames;

@end
