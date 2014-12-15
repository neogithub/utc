//
//  MediaManager.m
//  utc
//
//  Created by Evan Buxton on 12/15/14.
//  Copyright (c) 2014 Neoscape. All rights reserved.
//

#import "MediaManager.h"

@interface MediaManager (){
	AVAudioPlayer *audioPlayer;
}

@end

@implementation MediaManager

-(id)init{
	if(self = [super init]){
		
	}
	return self;
}

+(MediaManager *)sharedInstance{
 //create an instance if not already else return
	
	static MediaManager *sharedInstance = nil;

	if(!sharedInstance){
		sharedInstance = [[[self class] alloc] init];
	}
	return sharedInstance;
}

#pragma mark - play movie
-(void)loadMovieNamed:(NSString*)moviename isTapToPauseEnabled:(BOOL)tapToPauseEnabled belowSubview:(UIView*)belowSubview
{
	
	NSString* fileName = [moviename stringByDeletingPathExtension];
	NSString* extension = [moviename pathExtension];
	
	NSString *url = [[NSBundle mainBundle] pathForResource:fileName
													ofType:extension];
	
	
	if (tapToPauseEnabled == YES) {
		NSLog(@"tapToPauseEnabled == YES");
		//_isPauseable = YES;
	}
	
	
	if (_avPlayer) {
		[_avPlayerLayer removeFromSuperlayer];
		_avPlayerLayer = nil;
		_avPlayer = nil;
		//[_uiv_movieContainer removeFromSuperview];
		//_uiv_movieContainer=nil;
		//[[NSNotificationCenter defaultCenter] removeObserver:self];
		[[NSNotificationCenter defaultCenter] removeObserver:self name:@"playerItemLoop:" object:nil];
		[[NSNotificationCenter defaultCenter] removeObserver:self name:@"playerItemDidReachEnd:" object:nil];
	}
	
//	_uiv_movieContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
//	[_uiv_movieContainer setBackgroundColor:[UIColor clearColor]];
	
	//[_uiv_movieContainer setUserInteractionEnabled:YES];
	//[_uiv_movieContainer addGestureRecognizer:panGesture];
	
	
//	if (belowSubview != nil) {
//		[self.view insertSubview:_uiv_movieContainer belowSubview:belowSubview];
//	} else {
//		[self.view addSubview:_uiv_movieContainer];
//	}
	
	_avPlayer = [AVPlayer playerWithURL:[NSURL fileURLWithPath:url]] ;
	_avPlayerLayer = [AVPlayerLayer playerLayerWithPlayer:_avPlayer];
	_avPlayerLayer.frame = CGRectMake(0.0, 0.0, 1024, 768);
	
	if (!tapToPauseEnabled) {
		NSString *imageNameFromMovieName = [NSString stringWithFormat:@"%@.png",[fileName stringByDeletingPathExtension]];
		UIImage *image = [self flipImage:[UIImage imageNamed:imageNameFromMovieName]];
		
		_avPlayerLayer.backgroundColor = [UIColor colorWithPatternImage:image].CGColor;
	} else {
		_avPlayerLayer.backgroundColor = [UIColor blackColor].CGColor;
	}
	
//	[_uiv_movieContainer.layer addSublayer: _avPlayerLayer];
	
	// starts the player as well
	
	[_avPlayer play];
	
//	if (tapToPauseEnabled) {
//		[self beginSequence];
//	}
	
	
//	[self updateStillFrameUnderFilm:@"04_HOTSPOT_CROSS_SECTION.png"];
	
	NSString *selectorAfterMovieFinished;
	
	if (tapToPauseEnabled == YES) {
//		[self addMovieGestures];
		//[self loadControlsLabels];
		selectorAfterMovieFinished = @"playerItemLoop:";
		
//		UIButton *h = [UIButton buttonWithType:UIButtonTypeCustom];
//		h.frame = CGRectMake(1024-36, 0, 36, 36);
//		//[h setTitle:@"X" forState:UIControlStateNormal];
//		//h.titleLabel.font = [UIFont fontWithName:@"ArialMT" size:14];
//		[h setBackgroundImage:[UIImage imageNamed:@"close bttn.png"] forState:UIControlStateNormal];
//		[h setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//		//set their selector using add selector
//		[h addTarget:self action:@selector(closeMovie) forControlEvents:UIControlEventTouchUpInside];
//		[_uiv_movieContainer addSubview:h];
		
	} else {
		selectorAfterMovieFinished = @"playerItemDidReachEnd:";
	}
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:NSSelectorFromString(selectorAfterMovieFinished)
												 name:AVPlayerItemDidPlayToEndTimeNotification
											   object:[_avPlayer currentItem]];
	
//	if (kEnableDoubleTapToKillMovie) {
//		UITapGestureRecognizer *doubleTapMovie = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeMovie)];
//		doubleTapMovie.numberOfTapsRequired = 2;
//		[self.view addGestureRecognizer:doubleTapMovie];
//	}
}

- (UIImage *)flipImage:(UIImage *)image
{
	UIGraphicsBeginImageContext(image.size);
	CGContextDrawImage(UIGraphicsGetCurrentContext(),CGRectMake(0.,0., image.size.width, image.size.height),image.CGImage);
	UIImage *i = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return i;
}

//-(void)addMovieGestures
//{
//	UITapGestureRecognizer *tappedMovie = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedMovie:)];
//	[self.view addGestureRecognizer: tappedMovie];
//	
//	if (kEnableSwiping==YES) {
//		UISwipeGestureRecognizer *swipeUpRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeUpPlay:)];
//		[swipeUpRecognizer setDirection:(UISwipeGestureRecognizerDirectionUp)];
//		[swipeUpRecognizer setDelegate:self];
//		[self.view addGestureRecognizer:swipeUpRecognizer];
//		
//		UISwipeGestureRecognizer *swipeDownRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeDownPause:)];
//		[swipeDownRecognizer setDirection:(UISwipeGestureRecognizerDirectionDown)];
//		[swipeDownRecognizer setDelegate:self];
//		[self.view addGestureRecognizer:swipeDownRecognizer];
//	}
//}

- (void)playerItemDidReachEnd:(NSNotification *)notification {
//	[self closeMovie];
}

//-(void)playerItemLoop:(NSNotification *)notification
//{
//	AVPlayerItem *p = [notification object];
//	[p seekToTime:kCMTimeZero];
//	[_avPlayer play];
//	
//	// starts the player as well
//	[self beginSequence];
//}

#pragma mark - control(s) for movie

-(void)loadControlsLabels
{
	NSLog(@"load loadcontrollabel");
	_uil_filmHint = [[UILabel alloc] init];
	_uil_filmHint.textColor = [UIColor blackColor];
	[_uil_filmHint setFrame:CGRectMake(800, 718, 200, 30)];
	_uil_filmHint.backgroundColor=[UIColor lightGrayColor];
	[_uil_filmHint setTextAlignment:NSTextAlignmentCenter];
	_uil_filmHint.textColor=[UIColor whiteColor];
	_uil_filmHint.userInteractionEnabled=NO;
	[_uil_filmHint setAlpha:0.5];
	_uil_filmHint.text= @"Tap Screen to Pause";
	[_uiv_movieContainer addSubview:_uil_filmHint];
}

-(void)tappedMovie:(UIGestureRecognizer*)gesture
{
//	if ([_avPlayer rate] == 0.0) {
//		//[_avPlayer play];
//		[self resumeAnimation];
//	} else {
//		//[_avPlayer pause];
//		[self pauseAnimation];
//	}
//	[self updateFilmHint];
}

-(void)updateFilmHint
{
	if ([_avPlayer rate] != 0.0) {
		_uil_filmHint.text= @"Tap Screen to Pause";
	} else {
		_uil_filmHint.text= @"Tap Screen to Play";
	}
}

-(void)swipeUpPlay:(id)sender {
	//[_avPlayer play];
//	[self resumeAnimation];
//	[self updateFilmHint];
}

-(void)swipeDownPause:(id)sender {
	//[_avPlayer pause];
//	[self pauseAnimation];
//	[self updateFilmHint];
}

//-(void)closeMovie
//{
//	if (_myTimer) {
//		[self.myTimer invalidate];
//		self.myTimer = nil;
//	}
//	
//	[_uis_zoomingImg bringSubviewToFront:_uis_zoomingInfoImg];
//	[_uis_zoomingImg.scrollView setZoomScale:1.0];
//	[topTitle removeHotspotTitle];
//	
//	if (_isPauseable == YES) {
//		[self unhideChrome];
//	}
//	
//	[UIView animateWithDuration:0.3 animations:^{
//		_uis_zoomingImg.alpha = 1.0;
//		
//	} completion:^(BOOL completed) {
//		[_uis_zoomingInfoImg removeFromSuperview];
//		_uis_zoomingInfoImg = nil;
//		
//		[_avPlayerLayer removeFromSuperlayer];
//		_avPlayerLayer = nil;
//		[_uiv_movieContainer removeFromSuperview];
//		_uiv_movieContainer=nil;
//		
//	}];
//	
//	
//	
//	[self clearHotpsotData];
//}


@end
