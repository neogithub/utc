//
//  PersistencyManager.h
//  utc
//
//  Created by Evan Buxton on 12/11/14.
//  Copyright (c) 2014 Neoscape. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Company.h"

@interface PersistencyManager : NSObject

@property (nonatomic, retain) Company *selectedCompany;

- (NSArray*)getCompanies;
- (NSMutableArray*)getCompanyNames;
- (NSArray*)getSelectedCompanyNamed:(NSString*)name;
- (Company*)getSelectedCompanyData;

@end
