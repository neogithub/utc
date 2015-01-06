//
//  UIApplication+AppVersion.m
//  rxrnorthhills
//
//  Created by Evan Buxton on 11/24/14.
//  Copyright (c) 2014 neoscape. All rights reserved.
//

#import "UIApplication+AppVersion.h"

@implementation UIApplication (AppVersion)

+ (NSString *) appVersion
{
    return [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
}

+ (NSString *) build
{
    return [[NSBundle mainBundle] objectForInfoDictionaryKey: (NSString *)kCFBundleVersionKey];
}

+ (NSString *) versionBuild
{
    NSString * version = [self appVersion];
    NSString * build = [self build];
	
    NSString * versionBuild = [NSString stringWithFormat: @"v%@", version];
	
    if (![version isEqualToString: build]) {
        versionBuild = [NSString stringWithFormat: @"%@(%@)", versionBuild, build];
    }
	
    return versionBuild;
}

@end
