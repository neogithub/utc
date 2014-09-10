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
#import "neoHotspotsView.h"

enum { kEnableSwiping = YES };
enum { kEnableDoubleTapToKillMovie = YES };

@interface otisViewController () <ebZoomingScrollViewDelegate, neoHotspotsViewDelegate, UIGestureRecognizerDelegate>

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
@property (nonatomic, strong) UIButton				*uib_filmClose;

@property (nonatomic, strong) neoHotspotsView *myHotspots;
@property (nonatomic, strong) NSMutableArray *arr_hotspots;

@end

@implementation otisViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.frame = CGRectMake(0.0, 0.0, 1024, 768);
	
	// load animation that leads to the hero
	// building tapped from previous screen
	[self loadMovieNamed:_transitionClipName isTapToPauseEnabled:NO belowSubview:nil];
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
    [self loadMovieNamed:@"UTC_SPLIT_ANIMATION.mp4" isTapToPauseEnabled:NO belowSubview:nil];
    [self updateStillFrameUnderFilm:@"otis_building.jpg"];
	[_uib_SplitOpenBtn removeFromSuperview];
	[self initLogoBtn];
}

-(void)filmTransitionToHotspots
{
	//[[NSNotificationCenter defaultCenter] postNotificationName:@"goIntoBuilding" object:nil];
	 _uib_logoBtn.hidden = YES;
    [self loadMovieNamed:@"UTC_SCHEMATIC_ANIMATION_CLIP.mov" isTapToPauseEnabled:NO belowSubview:nil];
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
	
    [self getDataFromPlist];
}

-(void)getDataFromPlist
{
    
    NSString *path = [[NSBundle mainBundle] pathForResource:
					  @"hotspotsData" ofType:@"plist"];
    NSMutableArray *totalDataArray = [[NSMutableArray alloc] initWithContentsOfFile:path];
    for (int i = 0; i < [totalDataArray count]; i++) {
        NSDictionary *hotspotItem = totalDataArray [i];
        
        //Get the position of Hs
        NSString *str_position = [[NSString alloc] initWithString:[hotspotItem objectForKey:@"xy"]];
        NSRange range = [str_position rangeOfString:@","];
        NSString *str_x = [str_position substringWithRange:NSMakeRange(0, range.location)];
        NSString *str_y = [str_position substringFromIndex:(range.location + 1)];
        float hs_x = [str_x floatValue];
        float hs_y = [str_y floatValue];
        _myHotspots = [[neoHotspotsView alloc] initWithFrame:CGRectMake(hs_x, hs_y, 41, 35)];
        _myHotspots.delegate=self;
		[_arr_hotspotsArray addObject:_myHotspots];
		
        //Get the angle of arrow
        NSString *str_angle = [[NSString alloc] initWithString:[hotspotItem objectForKey:@"angle"]];
        if ([str_angle isEqualToString:@""]) {
        }
        else
        {
            float hsAngle = [str_angle floatValue];
            _myHotspots.arwAngle = hsAngle;
        }
        
        //Get the name of BG img name
        NSString *str_bgName = [[NSString alloc] initWithString:[hotspotItem objectForKey:@"background"]];
        _myHotspots.hotspotBgName = str_bgName;
        
        //Get the caption of hotspot
        NSString *str_caption = [[NSString alloc] initWithString:[hotspotItem objectForKey:@"caption"]];
        _myHotspots.str_labelText = str_caption;
        _myHotspots.labelAlignment = CaptionAlignmentBottom;
        
        //Get the type of hotspot
        NSString *str_type = [[NSString alloc] initWithString:[hotspotItem objectForKey:@"type"]];
        _myHotspots.str_typeOfHs = str_type;
        
        _myHotspots.tagOfHs = i;
        [_uis_zoomingImg.blurView addSubview:_myHotspots];
    }
}

#pragma mark hotspot tapped
#pragma mark Delegate Method

-(void)neoHotspotsView:(neoHotspotsView *)hotspot withTag:(int)i
{
	neoHotspotsView *tappedView = _arr_hotspotsArray[i];
	if ([tappedView.str_typeOfHs isEqualToString:@"movie"]) {
		[self loadMovieNamed:@"UTC_SPIN_ANIMATION.mov" isTapToPauseEnabled:YES belowSubview:_uis_zoomingImg];
	} else {
		[self popUpImage];
	}
	
	[_uis_zoomingImg zoomToPoint:CGPointMake(tappedView.center.x, tappedView.center.y) withScale:1.5 animated:YES];
	[UIView animateWithDuration:0.5 animations:^{
		_uis_zoomingImg.alpha = 0.0;
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
    [self.view insertSubview:_uis_zoomingInfoImg belowSubview:_uis_zoomingImg];
}

-(void)didRemove:(ebZoomingScrollView *)ebZoomingScrollView {

	[_uis_zoomingInfoImg bringSubviewToFront:_uis_zoomingImg];
	[_uis_zoomingImg.scrollView setZoomScale:1.0];

	[UIView animateWithDuration:0.5 animations:^{
		_uis_zoomingImg.alpha = 1.0;
	} completion:^(BOOL completed) {
		[_uis_zoomingInfoImg removeFromSuperview];
		_uis_zoomingInfoImg = nil;
	}];
}

#pragma mark - play movie
#warning isTransitional below needs to be replaced
-(void)loadMovieNamed:(NSString*)moviename isTapToPauseEnabled:(BOOL)tapToPauseEnabled belowSubview:(UIView*)belowSubview
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
	
	if (belowSubview != nil) {
		[self.view insertSubview:_uiv_movieContainer belowSubview:belowSubview];
	} else {
		[self.view addSubview:_uiv_movieContainer];
	}
	
    _avPlayer = [AVPlayer playerWithURL:[NSURL fileURLWithPath:url]] ;
    _avPlayerLayer = [AVPlayerLayer playerLayerWithPlayer:_avPlayer];
    _avPlayerLayer.frame = CGRectMake(0.0, 0.0, 1024, 768);
	
    _avPlayerLayer.backgroundColor = [UIColor blackColor].CGColor;
    [_uiv_movieContainer.layer addSublayer: _avPlayerLayer];
    
    [_avPlayer play];
    
		[self updateStillFrameUnderFilm:@"otis_building_inside.png"];
	
	NSString *selectorAfterMovieFinished;
	
	if (tapToPauseEnabled == YES) {
		[self addMovieGestures];
		[self loadControlsLabels];
		selectorAfterMovieFinished = @"playerItemLoop:";
		_uib_filmClose = [UIButton buttonWithType:UIButtonTypeSystem];
		_uib_filmClose.frame = CGRectMake(800, 688, 200, 30);
		_uib_filmClose.backgroundColor = [UIColor whiteColor];
		[_uib_filmClose setTitle:@"Close" forState:UIControlStateNormal];
		[_uib_filmClose addTarget:self action:@selector(closeMovie) forControlEvents:UIControlEventTouchUpInside];
		[_uiv_movieContainer addSubview:_uib_filmClose];
	} else {
		selectorAfterMovieFinished = @"playerItemDidReachEnd:";
	}
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:NSSelectorFromString(selectorAfterMovieFinished)
												 name:AVPlayerItemDidPlayToEndTimeNotification
												   object:[_avPlayer currentItem]];
	
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

-(void)playerItemLoop:(NSNotification *)notification
{
	AVPlayerItem *p = [notification object];
	[p seekToTime:kCMTimeZero];
	[_avPlayer play];
}

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
		
	[_uis_zoomingImg bringSubviewToFront:_uis_zoomingInfoImg];
	[_uis_zoomingImg.scrollView setZoomScale:1.0];
	
	[UIView animateWithDuration:0.5 animations:^{
		_uis_zoomingImg.alpha = 1.0;
	} completion:^(BOOL completed) {
		[_uis_zoomingInfoImg removeFromSuperview];
		_uis_zoomingInfoImg = nil;
		
		[_avPlayerLayer removeFromSuperlayer];
		_avPlayerLayer = nil;
		[_uiv_movieContainer removeFromSuperview];
		_uiv_movieContainer=nil;

	}];

}

#pragma mark - boiler plate

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
