//
//  NSTimer+CVPausable.h
//  embUTCCardViews
//
//  Created by Evan Buxton on 12/1/14.
//  Copyright (c) 2014 neoscape. All rights reserved.
//  Adapted from http://stackoverflow.com/questions/347219/how-can-i-programmatically-pause-an-nstimer

#import <Foundation/Foundation.h>

//----------------------------------------------------
#pragma mark - Class
//----------------------------------------------------

@interface NSTimer (CVPausable)

- (void)pauseOrResume;
- (BOOL)isPaused;

@end
