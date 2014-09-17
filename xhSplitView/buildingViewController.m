//
//  otisViewController.m
//  xhSplitViewController
//
//  Created by Xiaohe Hu on 9/3/14.
//  Copyright (c) 2014 Neoscape. All rights reserved.
//

#import "buildingViewController.h"
#import "ebZoomingScrollView.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "neoHotspotsView.h"

enum { kEnableSwiping = YES };
enum { kEnableDoubleTapToKillMovie = YES };

@interface buildingViewController () <ebZoomingScrollViewDelegate, neoHotspotsViewDelegate, UIGestureRecognizerDelegate>
{
	CGFloat companyLabelWidth;
	CGFloat hotspotLabelWidth;
}

@property (nonatomic, strong) UIView				*uiv_movieContainer;
@property (nonatomic, strong) UIImageView           *uiiv_bg;
@property (nonatomic, strong) NSMutableArray        *arr_hotspotsArray;
@property (nonatomic, strong) NSMutableArray		*arr_companyHotspotArray;

@property (nonatomic, strong) ebZoomingScrollView   *uis_zoomingImg;
@property (nonatomic, strong) ebZoomingScrollView   *uis_zoomingInfoImg;

@property (nonatomic, strong) AVPlayer              *avPlayer;
@property (nonatomic, strong) AVPlayerLayer         *avPlayerLayer;
@property (nonatomic, strong) UIButton              *uib_logoBtn;
@property (nonatomic, strong) UIButton              *uib_SplitOpenBtn;
@property (nonatomic, strong) UIButton              *uib_back;
@property (nonatomic, strong) UILabel				*uil_filmHint;

@property (nonatomic, strong) neoHotspotsView		*myHotspots;
@property (nonatomic, strong) NSMutableArray		*arr_hotspots;

@property (nonatomic, strong) UIView                        *uiv_textBoxContainer;
@property (nonatomic, strong) UILabel                       *uil_textYear;
@property (nonatomic, strong) UILabel                       *uil_textInfo;
@property (nonatomic, strong) UILabel                       *uil_textSection;

@end

@implementation buildingViewController

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
	
    _arr_hotspotsArray = [[NSMutableArray alloc] init];
	
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
    _uib_SplitOpenBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _uib_SplitOpenBtn.frame = CGRectMake(470, 710, 100, 30);
	[_uib_SplitOpenBtn setImage:[UIImage imageNamed:@"grfx_splitBtn.png"] forState:UIControlStateNormal];
    [self.view insertSubview:_uib_SplitOpenBtn belowSubview:_uiv_movieContainer];
	[_uib_SplitOpenBtn addTarget:self action:@selector(filmToSplitBuilding) forControlEvents:UIControlEventTouchUpInside];
	
	[self pulse:_uib_SplitOpenBtn.layer];
}

-(void)initLogoBtn
{
    /*_uib_logoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _uib_logoBtn.frame = CGRectMake(503, 109, 82, 44);
    _uib_logoBtn.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.5];
    [_uis_zoomingImg.blurView addSubview:_uib_logoBtn];
    [_uib_logoBtn addTarget:self action:@selector(filmTransitionToHotspots) forControlEvents:UIControlEventTouchUpInside];
	
	[self pulse:_uib_logoBtn.layer];
	*/
	
	[self loadCompaniesHotspots];
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
	[self loadCompaniesHotspots];

}

-(void)filmTransitionToHotspots
{
	//[[NSNotificationCenter defaultCenter] postNotificationName:@"goIntoBuilding" object:nil];
	 _uib_logoBtn.hidden = YES;
    [self loadMovieNamed:@"UTC_SCHEMATIC_ANIMATION_CLIP.mov" isTapToPauseEnabled:NO belowSubview:nil];
    [self updateStillFrameUnderFilm:@"otis_building_inside.png"];
	[self createHotspots];
	
	[self initTitleBox];

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

#pragma mark - Info Labels
#pragma mark - init top left text box
-(void)initTitleBox
{
    _uiv_textBoxContainer = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view insertSubview:_uiv_textBoxContainer aboveSubview:_uiv_movieContainer];
    _uiv_textBoxContainer.layer.zPosition = MAXFLOAT;
	[self setCompanyTitle:@"OTIS"];
}

-(void)setCompanyTitle:(NSString *)year
{
    if (_uil_textYear) {
        [_uil_textYear removeFromSuperview];
        _uil_textYear = nil;
    }
	
	// get width of uilabel
	UIFont *font = [UIFont fontWithName:@"Helvetica-Bold" size:15];
	CGFloat str_width = [self getWidthFromStringLength:year andFont:font];
	static CGFloat labelPad = 15;
	companyLabelWidth = str_width + (labelPad*2);
	
    _uil_textYear = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, companyLabelWidth, 36)];
    [_uil_textYear setText:year];
    [_uil_textYear setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.8]];
    [_uil_textYear setTextColor:[UIColor blackColor]];
    [_uil_textYear setFont: font];
    [_uil_textYear setTextAlignment:NSTextAlignmentCenter];
	[_uil_textYear.layer setBorderColor:[UIColor lightGrayColor].CGColor];
	[_uil_textYear.layer setBorderWidth:1.0];
	
	[_uiv_textBoxContainer addSubview: _uil_textYear];
	
	// resize text container to fit
	_uiv_textBoxContainer.frame = CGRectMake(75, 0, companyLabelWidth, 36);
}

-(void)setHotSpotTitle:(NSString *)string
{
    if (_uil_textInfo) {
        [_uil_textInfo removeFromSuperview];
        _uil_textInfo = nil;
    }
	
	// get width of uilabel
	UIFont *font = [UIFont fontWithName:@"Helvetica" size:15];
	CGFloat str_width = [self getWidthFromStringLength:string andFont:font];
	static CGFloat labelPad = 20;
	hotspotLabelWidth = str_width + (labelPad);
    
    _uil_textInfo = [[UILabel alloc] initWithFrame:CGRectMake(companyLabelWidth, 0, hotspotLabelWidth, 36)];
    [_uil_textInfo setText:string];
	_uil_textInfo.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.8];
    [_uil_textInfo setTextColor:[UIColor blackColor]];
	[_uil_textInfo setTextAlignment:NSTextAlignmentCenter];
    [_uil_textInfo setFont:font];
    [_uil_textInfo.layer setBorderColor:[UIColor lightGrayColor].CGColor];
	[_uil_textInfo.layer setBorderWidth:1.0];
	
	[_uiv_textBoxContainer addSubview: _uil_textInfo];
	
	// resize text container to fit
	_uiv_textBoxContainer.frame = CGRectMake(75, 0, hotspotLabelWidth+companyLabelWidth, 36);
}

#pragma mark - company hotspots
-(void)createHotspots
{
    for (UIView*hotspot in _arr_hotspotsArray) {
		[hotspot removeFromSuperview];
	}
	
	[_arr_hotspotsArray removeAllObjects];
    _arr_hotspotsArray = nil;
    _arr_hotspotsArray = [[NSMutableArray alloc] init];
	
	[self loadSingleCompanyHotspots];
}

// load the hotpots of the company selected
-(void)loadSingleCompanyHotspots
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
		
		// get the alignment
        int num_Alignment = [[hotspotItem objectForKey:@"alignment"] intValue];
        _myHotspots.labelAlignment = num_Alignment;
        
        //Get the type of hotspot
        NSString *str_type = [[NSString alloc] initWithString:[hotspotItem objectForKey:@"type"]];
        _myHotspots.str_typeOfHs = str_type;
		
        _myHotspots.tagOfHs = i;
        [_uis_zoomingImg.blurView addSubview:_myHotspots];
    }
}

// load all the companies onto the view
-(void)loadCompaniesHotspots
{
    NSString *path = [[NSBundle mainBundle] pathForResource:
					  @"companyHotspotsData" ofType:@"plist"];
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
        _myHotspots = [[neoHotspotsView alloc] initWithFrame:CGRectMake(hs_x, hs_y, 95, 72)];
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
		
		// get the alignment
        int num_Alignment = [[hotspotItem objectForKey:@"alignment"] intValue];
        _myHotspots.labelAlignment = num_Alignment;
        
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
	neoHotspotsView *tappedView;
	tappedView = _arr_hotspotsArray[i];
	
#warning more robust previously tapped method
	tappedView.alpha = 0.75;
	
	if ([tappedView.str_typeOfHs isEqualToString:@"company"]) {
		[self filmTransitionToHotspots];
	} else {
		NSLog(@"str_typeOfHs %@",tappedView.str_typeOfHs);
		
		if ([tappedView.str_typeOfHs isEqualToString:@"movie"]) {
			[self loadMovieNamed:@"HOT_SPOT_COATED_STEEL_BELTS.m4v" isTapToPauseEnabled:YES belowSubview:_uis_zoomingImg];
		} else {
			[self popUpImage];
		}
		
		[_uis_zoomingImg zoomToPoint:CGPointMake(tappedView.center.x, tappedView.center.y) withScale:1.5 animated:YES];
		[UIView animateWithDuration:0.5 animations:^{
			_uis_zoomingImg.alpha = 0.0;
		} completion:nil];
		
		[self setHotSpotTitle:tappedView.str_labelText];
	}
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

#pragma mark - ebzooming delegate
-(void)didRemove:(ebZoomingScrollView *)ebZoomingScrollView {

	[_uis_zoomingInfoImg bringSubviewToFront:_uis_zoomingImg];
	[_uis_zoomingImg.scrollView setZoomScale:1.0];
	
	// hotspot cleanup
	if (_uil_textInfo) {
        [_uil_textInfo removeFromSuperview];
        _uil_textInfo = nil;
    }

	[UIView animateWithDuration:0.5 animations:^{
		_uis_zoomingImg.alpha = 1.0;
	} completion:^(BOOL completed) {
		[_uis_zoomingInfoImg removeFromSuperview];
		_uis_zoomingInfoImg = nil;
	}];
}
#pragma mark - Utiltites
#pragma mark PulseAnim
-(void)pulse:(CALayer*)incomingLayer
{
	CABasicAnimation *theAnimation;
	CALayer *pplayer = incomingLayer;
	theAnimation=[CABasicAnimation animationWithKeyPath:@"opacity"];
	theAnimation.duration=0.5;
	theAnimation.repeatCount=HUGE_VAL;
	theAnimation.autoreverses=YES;
	theAnimation.fromValue=[NSNumber numberWithFloat:1.0];
	theAnimation.toValue=[NSNumber numberWithFloat:0.5];
	[pplayer addAnimation:theAnimation forKey:@"animateOpacity"];
}

#pragma mark get width of string text
-(float)getWidthFromStringLength:(NSString*)string andFont:(UIFont*)stringfont
{
	UIFont *font = stringfont;
    NSDictionary *attributes1 = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil];
    CGFloat str_width = [[[NSAttributedString alloc] initWithString:string attributes:attributes1] size].width;
    NSLog(@"The string width is %f", str_width);
	return str_width;
}

#pragma mark - play movie
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
		UIButton *uib_filmClose = [UIButton buttonWithType:UIButtonTypeSystem];
		uib_filmClose.frame = CGRectMake(800, 688, 200, 30);
		uib_filmClose.backgroundColor = [UIColor whiteColor];
		[uib_filmClose setTitle:@"Close" forState:UIControlStateNormal];
		[uib_filmClose addTarget:self action:@selector(closeMovie) forControlEvents:UIControlEventTouchUpInside];
		[_uiv_movieContainer addSubview:uib_filmClose];
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
