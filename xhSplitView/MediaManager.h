//
//  MediaManager.h
//  utc
//
//  Created by Evan Buxton on 12/15/14.
//  Copyright (c) 2014 Neoscape. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVPlayer.h>
#import <AVFoundation/AVFoundation.h>

@interface MediaManager : NSObject <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIView						*uiv_movieContainer;
@property (nonatomic, strong) AVPlayer						*avPlayer;
@property (nonatomic, strong) AVPlayerLayer					*avPlayerLayer;
@property (nonatomic, strong) UILabel						*uil_filmHint;

+(MediaManager *)sharedInstance;
-(void)loadMovieNamed:(NSString*)moviename isTapToPauseEnabled:(BOOL)tapToPauseEnabled belowSubview:(UIView*)belowSubview;
-(void)playWithURL:(NSURL *)url;
-(float)currentPlaybackTime;

@end
