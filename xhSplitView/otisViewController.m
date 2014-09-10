//
//  otisViewController.m
//  xhSplitViewController
//
//  Created by Xiaohe Hu on 9/3/14.
//  Copyright (c) 2014 Neoscape. All rights reserved.
//

#import "otisViewController.h"
#import "ebZoomingScrollView.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVPlayer.h>
#import <AVFoundation/AVFoundation.h>

enum { kEnableSwiping = YES };
enum { kEnableDoubleTapToKillMovie = YES };

@interface otisViewController () <ebZoomingScrollViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIView				*uiv_movieContainer;
@property (nonatomic, strong) UIImageView           *uiiv_bg;
@property (nonatomic, strong) NSMutableArray        *arr_hotspotsArray;
@property (nonatomic, strong) ebZoomingScrollView   *uis_zoomingImg;
@property (nonatomic, strong) ebZoomingScrollView   *uis_zoomingInfoImg;
@property (nonatomic, strong) AVPlayer              *avPlayer;
@property (nonatomic, strong) AVPlayerLayer         *avPlayerLayer;
@property (nonatomic, strong) UIButton              *uib_logoBtn;
@property (nonatomic, strong) UIButton              *uib_SplitOpenBtn;
@property (nonatomic, strong) UIButton              *uib_back;
@property (nonatomic, strong) UIButton              *uib_buildingBtn;
@property (nonatomic, strong) UILabel				*uil_filmHint;
@end

@implementation otisViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.frame = CGRectMake(0.0, 0.0, 1024, 768);
	
	// load animation that leads to the hero
	// building tapped from previous screen
	[self loadMovieNamed:_transitionClipName isTapToPauseEnabled:NO];
	// add in the bg image beneath the film
	[self createStillFrameUnderFilm];
	
	// DEBUG
#warning Debug for swiping or doubletapping
	if ((kEnableSwiping==YES) || (kEnableDoubleTapToKillMovie==YES)) {
		UILabel *uil_Debug = [[UILabel alloc] init];
		[uil_Debug setFrame:CGRectMake(824, 0, 200, 30)];
		uil_Debug.backgroundColor=[UIColor redColor];
		[uil_Debug setTextAlignment:NSTextAlignmentCenter];
		uil_Debug.textColor=[UIColor whiteColor];
		[uil_Debug setAlpha:0.5];
		uil_Debug.text= @"DEBUG MODE";
		[self.view insertSubview:uil_Debug atIndex:1000];
	}
}

#pragma mark - stills under movie
-(void)createStillFrameUnderFilm
{
    if (_uiiv_bg) {
        [_uiiv_bg removeFromSuperview];
        _uiiv_bg = nil;
		
		for (UIView*hotspot in _arr_hotspotsArray) {
			[hotspot removeFromSuperview];
		}
    }
	
	_uis_zoomingImg = [[ebZoomingScrollView alloc] initWithFrame:CGRectMake(0.0, 0.0, 1024, 768) image:[UIImage imageNamed:@"otis_building_hero.jpg"] shouldZoom:YES];
    _uis_zoomingImg.delegate = self;
	
	if (_uiv_movieContainer) {
		[self.view insertSubview: _uis_zoomingImg belowSubview:_uiv_movieContainer];
	} else {
		[self.view insertSubview: _uis_zoomingImg belowSubview:_uib_back];
	}
	[self initSplitOpenBtn];
}

-(void)updateStillFrameUnderFilm:(NSString*)imgName
{
	[_uis_zoomingImg.blurView setImage:[UIImage imageNamed:imgName]];
}

#pragma mark - buttons for splitting view and otis logo
-(void)initSplitOpenBtn
{
    _uib_SplitOpenBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    _uib_SplitOpenBtn.frame = CGRectMake(500, 610, 100, 50);
	[_uib_SplitOpenBtn setTitle:@"Expand" forState:UIControlStateNormal];
    _uib_SplitOpenBtn.backgroundColor = [UIColor redColor];
    [self.view insertSubview:_uib_SplitOpenBtn belowSubview:_uiv_movieContainer];
    //[_uib_SplitOpenBtn addTarget:self action:@selector(changeView) forControlEvents:UIControlEventTouchUpInside];
	[_uib_SplitOpenBtn addTarget:self action:@selector(filmToSplitBuilding) forControlEvents:UIControlEventTouchUpInside];
}

-(void)initLogoBtn
{
    _uib_logoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _uib_logoBtn.frame = CGRectMake(500, 110, 100, 50);
    _uib_logoBtn.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_uib_logoBtn];
    [_uib_logoBtn addTarget:self action:@selector(filmTransitionToHotspots) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - Actions to play path to hero and split hero
-(void)filmToSplitBuilding
{
	//[[NSNotificationCenter defaultCenter] postNotificationName:@"goIntoBuilding" object:nil];
    //_uib_logoBtn.hidden = YES;
    [self createBackButton];
    [self loadMovieNamed:@"UTC_SPLIT_ANIMATION.mp4" isTapToPauseEnabled:NO];
    [self updateStillFrameUnderFilm:@"otis_building.jpg"];
	[_uib_SplitOpenBtn removeFromSuperview];
	[self initLogoBtn];
}

-(void)filmTransitionToHotspots
{
	//[[NSNotificationCenter defaultCenter] postNotificationName:@"goIntoBuilding" object:nil];
	 _uib_logoBtn.hidden = YES;
    [self createBackButton];
    [self loadMovieNamed:@"UTC_SCHEMATIC_ANIMATION_CLIP.mov" isTapToPauseEnabled:NO];
    [self updateStillFrameUnderFilm:@"otis_building_inside.png"];
	[self createHotspots];
}

#pragma mark - menu buttons
-(void)createBackButton
{
    _uib_back = [UIButton buttonWithType:UIButtonTypeCustom];
    _uib_back.frame = CGRectMake(37, 0.0, 36, 36);
    [_uib_back setImage:[UIImage imageNamed:@"grfx_backBtn.png"] forState:UIControlStateNormal];
    [self.view insertSubview:_uib_back aboveSubview:_uiiv_bg];
    [_uib_back addTarget:self action:@selector(restartView) forControlEvents:UIControlEventTouchUpInside];
}

-(void)restartView
{
    if (_avPlayerLayer) {
        [self closeMovie];
    }

	[self createStillFrameUnderFilm];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"goToCity" object:nil];
}

#pragma mark - company hotspots
-(void)createHotspots
{
    [_arr_hotspotsArray removeAllObjects];
    _arr_hotspotsArray = nil;
    _arr_hotspotsArray = [[NSMutableArray alloc] init];
    
    UIView *hotspot1 = [[UIView alloc] initWithFrame:CGRectMake(560, 250, 131, 35)];
    UIImageView *hotspotMark1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Marker.png"]];
    hotspotMark1.frame = CGRectMake(90.0, 0.0, 41.0, 35.0);
    UILabel *hotsoptLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 90.0, 35.0)];
    [hotsoptLabel1 setText:@"Hotspot Label"];
    [hotsoptLabel1 setFont:[UIFont systemFontOfSize:13]];
    [hotsoptLabel1 setTextAlignment:NSTextAlignmentCenter];
    [hotspot1 addSubview: hotsoptLabel1];
    [hotspot1 addSubview: hotspotMark1];
    [_uis_zoomingImg.blurView addSubview:hotspot1];
    hotspot1.tag = 1;
    [_arr_hotspotsArray addObject: hotspot1];
    [self addGestureToHotspots:hotspot1];
    
    UIView *hotspot2 = [[UIView alloc] initWithFrame:CGRectMake(560, 460, 131, 35)];
    UIImageView *hotspotMark2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Marker.png"]];
    hotspotMark2.frame = CGRectMake(90.0, 0.0, 41.0, 35.0);
    UILabel *hotsoptLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 90.0, 35.0)];
    [hotsoptLabel2 setText:@"Hotspot Label"];
    [hotsoptLabel2 setFont:[UIFont systemFontOfSize:13]];
    [hotsoptLabel2 setTextAlignment:NSTextAlignmentCenter];
    [hotspot2 addSubview: hotsoptLabel2];
    [hotspot2 addSubview: hotspotMark2];
    [_uis_zoomingImg.blurView addSubview:hotspot2];
    hotspot2.tag = 2;
    [_arr_hotspotsArray addObject: hotspot2];
    [self addGestureToHotspots:hotspot2];
}

-(void)addGestureToHotspots:(UIView *)hotspot
{
    UITapGestureRecognizer *tapOnHotspot = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHotspot:)];
    tapOnHotspot.numberOfTapsRequired = 1;
    hotspot.userInteractionEnabled = YES;
    [hotspot addGestureRecognizer: tapOnHotspot];
}

#pragma mark hotspot tapped
-(void)tapHotspot:(UIGestureRecognizer *)gesture
{
    UIView *tappedView = gesture.view;
    NSLog(@"THe view is %i", (int)tappedView.tag);
	
	[_uis_zoomingImg zoomToPoint:CGPointMake(tappedView.center.x, tappedView.center.y) withScale:1.5 animated:YES];
	[UIView animateWithDuration:0.5 animations:^{
		_uis_zoomingImg.alpha = 0.0;
		
//#warning this needs to be fixed
//		if (tappedView.tag == 1) {
//			[self popUpImage];
//		}
//		if (tappedView.tag == 2) {
//			[self loadMovieNamed:@"UTC_SPIN_ANIMATION.mov" isTapToPauseEnabled:YES];
//		}
		
	} completion:nil];
}

#pragma mark - hotspot actions
-(void)popUpImage
{
    if (_uis_zoomingInfoImg) {
        [_uis_zoomingInfoImg removeFromSuperview];
        _uis_zoomingInfoImg = nil;
    }
    _uis_zoomingInfoImg = [[ebZoomingScrollView alloc] initWithFrame:CGRectMake(0.0, 0.0, 1024, 768) image:[UIImage imageNamed:@"otis-hotpost-still.png"] shouldZoom:YES];
    [_uis_zoomingInfoImg setCloseBtn:YES];
    _uis_zoomingInfoImg.delegate = self;
    [self.view addSubview:_uis_zoomingInfoImg];
}

-(void)didRemove:(ebZoomingScrollView *)ebZoomingScrollView {
    [_uis_zoomingInfoImg removeFromSuperview];
    _uis_zoomingInfoImg = nil;
}

#pragma mark - play movie
#warning isTransitional below needs to be replaced
-(void)loadMovieNamed:(NSString*)moviename isTapToPauseEnabled:(BOOL)tapToPauseEnabled
{
	NSString* fileName = [moviename stringByDeletingPathExtension];
	NSString* extension = [moviename pathExtension];
	
	NSString *url = [[NSBundle mainBundle] pathForResource:fileName
                                                    ofType:extension];
    
    if (_avPlayer) {
        [_avPlayerLayer removeFromSuperlayer];
        _avPlayerLayer = nil;
        _avPlayer = nil;
		[_uiv_movieContainer removeFromSuperview];
		_uiv_movieContainer=nil;
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
	
	_uiv_movieContainer = [[UIView alloc] initWithFrame:self.view.frame];
	[_uiv_movieContainer setBackgroundColor:[UIColor redColor]];
	[self.view addSubview:_uiv_movieContainer];
	
    _avPlayer = [AVPlayer playerWithURL:[NSURL fileURLWithPath:url]] ;
    _avPlayerLayer = [AVPlayerLayer playerLayerWithPlayer:_avPlayer];
    _avPlayerLayer.frame = CGRectMake(0.0, 0.0, 1024, 768);
	
	
    _avPlayerLayer.backgroundColor = [UIColor blackColor].CGColor;
    [_uiv_movieContainer.layer addSublayer: _avPlayerLayer];
    
    [_avPlayer play];
    
    _avPlayer.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:[_avPlayer currentItem]];
	
	[self updateStillFrameUnderFilm:@"otis_building_inside.png"];
	
	if (tapToPauseEnabled == YES) {
		[self addMovieGestures];
		[self loadControlsLabel];
		NSLog(@"loadControlsLabel");
	}
	
	if (kEnableDoubleTapToKillMovie) {
		UITapGestureRecognizer *doubleTapMovie = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeMovie)];
		doubleTapMovie.numberOfTapsRequired = 2;
		[self.view addGestureRecognizer:doubleTapMovie];
	}
}

-(void)addMovieGestures
{
	UITapGestureRecognizer *tappedMovie = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedMovie:)];
    [self.view addGestureRecognizer: tappedMovie];
	
	if (kEnableSwiping==YES) {
		UISwipeGestureRecognizer *swipeUpRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeUpPlay:)];
		[swipeUpRecognizer setDirection:(UISwipeGestureRecognizerDirectionUp)];
		[swipeUpRecognizer setDelegate:self];
		[self.view addGestureRecognizer:swipeUpRecognizer];
		
		UISwipeGestureRecognizer *swipeDownRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeDownPause:)];
		[swipeDownRecognizer setDirection:(UISwipeGestureRecognizerDirectionDown)];
		[swipeDownRecognizer setDelegate:self];
		[self.view addGestureRecognizer:swipeDownRecognizer];
	}
}

- (void)playerItemDidReachEnd:(NSNotification *)notification {
    [self closeMovie];
}

#pragma mark - control(s) for movie

-(void)loadControlsLabel
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
	if ([_avPlayer rate] == 0.0) {
		[_avPlayer play];
	} else {
		[_avPlayer pause];
	}
	[self updateFilmHint];
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
    [_avPlayer play];
	[self updateFilmHint];
}

-(void)swipeDownPause:(id)sender {
    [_avPlayer pause];
	[self updateFilmHint];
}

-(void)closeMovie
{
	[_avPlayerLayer removeFromSuperlayer];
    _avPlayerLayer = nil;
	[_uiv_movieContainer removeFromSuperview];
	_uiv_movieContainer=nil;
}

#pragma mark - boiler plate

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
