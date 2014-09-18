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

enum {
    LabelOnscreen,
    LabelOffscreen,
};
typedef NSInteger PlayerState;


@interface buildingViewController () <ebZoomingScrollViewDelegate, neoHotspotsViewDelegate, UIGestureRecognizerDelegate>
{
	CGFloat companyLabelWidth;
	CGFloat hotspotLabelWidth;
}

@property (nonatomic, strong) UIView						*uiv_movieContainer;
@property (nonatomic, strong) UIImageView					*uiiv_bg;
@property (nonatomic, strong) NSMutableArray				*arr_hotspotsArray;
@property (nonatomic, strong) NSMutableArray				*arr_companyHotspotArray;

@property (nonatomic, strong) NSMutableArray				*arr_BreadCrumbOfImages;

@property (nonatomic, strong) ebZoomingScrollView			*uis_zoomingImg;
@property (nonatomic, strong) ebZoomingScrollView			*uis_zoomingInfoImg;

@property (nonatomic, strong) AVPlayer						*avPlayer;
@property (nonatomic, strong) AVPlayerLayer					*avPlayerLayer;
@property (nonatomic, strong) UIButton						*uib_logoBtn;
@property (nonatomic, strong) UIButton						*uib_SplitOpenBtn;
@property (nonatomic, strong) UIButton						*uib_back;
@property (nonatomic, strong) UILabel						*uil_filmHint;

@property (nonatomic, strong) neoHotspotsView				*myHotspots;
@property (nonatomic, strong) NSMutableArray				*arr_hotspots;

@property (nonatomic, strong) UIView                        *uiv_textBoxContainer;
@property (nonatomic, strong) UILabel                       *uil_Company;
@property (nonatomic, strong) UILabel                       *uil_HotspotTitle;
@property (nonatomic, strong) UILabel                       *uil_textSection;

@property (nonatomic) BOOL isPauseable;

@end

@implementation buildingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.frame = CGRectMake(0.0, 0.0, 1024, 768);
		
	_arr_hotspotsArray		= [[NSMutableArray alloc] init];
	_arr_BreadCrumbOfImages = [[NSMutableArray alloc] init];
	
	// load animation that leads to the hero
	// building tapped from previous screen
	[self loadMovieNamed:_transitionClipName isTapToPauseEnabled:NO belowSubview:nil];
	// add in the bg image beneath the film
	[self createStillFrameUnderFilm];
		
	// DEBUG
#warning Debug for swiping or doubletapping
	if ((kEnableSwiping==YES) || (kEnableDoubleTapToKillMovie==YES)) {
//		UILabel *uil_Debug = [[UILabel alloc] init];
//		[uil_Debug setFrame:CGRectMake(824, 0, 200, 30)];
//		uil_Debug.backgroundColor=[UIColor redColor];
//		[uil_Debug setTextAlignment:NSTextAlignmentCenter];
//		uil_Debug.textColor=[UIColor whiteColor];
//		[uil_Debug setAlpha:0.5];
//		uil_Debug.text= @"DEBUG MODE";
//		[self.view insertSubview:uil_Debug atIndex:1000];
	}
	
	[self createBackButton];
	
	NSValue* selCommandA = [NSValue valueWithPointer:@selector(reloadBuildingVC)];
	NSValue* selCommandB = [NSValue valueWithPointer:@selector(reloadHero)];
	NSValue* selCommandC = [NSValue valueWithPointer:@selector(loadSplitAssets)];
	
	_arr_BreadCrumbOfImages = [NSMutableArray arrayWithObjects:selCommandA, selCommandB, selCommandC, nil ];
}

#pragma mark - stills under movie
-(void)createStillFrameUnderFilm
{
    if (_uiiv_bg) {
        [_uiiv_bg removeFromSuperview];
        _uiiv_bg = nil;
		
		[self removeHotspots];
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
	[self loadCompaniesHotspots];
}

#pragma mark - Actions to play path to hero and split hero
-(void)filmToSplitBuilding
{
    [self loadMovieNamed:@"UTC_SPLIT_ANIMATION.mp4" isTapToPauseEnabled:NO belowSubview:nil];
	[_uib_SplitOpenBtn removeFromSuperview];

	[self loadSplitAssets];
}

-(void)filmTransitionToHotspots
{
	 _uib_logoBtn.hidden = YES;
    [self loadMovieNamed:@"UTC_SCHEMATIC_ANIMATION_CLIP.mov" isTapToPauseEnabled:NO belowSubview:nil];
    [self updateStillFrameUnderFilm:@"otis_building_end.png"];
	
	[self createHotspots];
	
	[self initTitleBox];
}

-(void)loadSplitAssets
{
	[self removeHotspotTitle];
	[self removeCompanyTitle];
	
	[self updateStillFrameUnderFilm:@"otis_building_split.jpg"];

	[self initLogoBtn];
	//[self loadCompaniesHotspots];
	
	[self removeHotspots];
	[_arr_hotspotsArray removeAllObjects];
	
	[self performSelector:@selector(loadCompaniesHotspots) withObject:nil afterDelay:3.33];
	
	[_uib_back setTag:1];
	NSLog(@"_uib_back %i",_uib_back.tag);
}

#pragma mark - menu buttons
-(void)createBackButton
{
	NSLog(@"createBackButton AGAIN");

    _uib_back = [UIButton buttonWithType:UIButtonTypeCustom];
    _uib_back.frame = CGRectMake(37, 0.0, 36, 36);
    [_uib_back setImage:[UIImage imageNamed:@"grfx_backBtn.png"] forState:UIControlStateNormal];
    [self.view addSubview:_uib_back];
    [_uib_back addTarget:self action:@selector(performSelectorFromArray) forControlEvents:UIControlEventTouchUpInside];
    _uib_back.layer.zPosition = MAXFLOAT;
	[_uib_back setTag:0];
	NSLog(@"_uib_back %i",_uib_back.tag);
}

-(void)performSelectorFromArray
{
	NSValue *val = _arr_BreadCrumbOfImages[_uib_back.tag];
	
	SEL mySelector = [val pointerValue];
	//	[self performSelector:mySelector];
	IMP imp = [self methodForSelector:mySelector];
	void (*func)(id, SEL) = (void *)imp;
	func(self, mySelector);
	
	NSLog(@"_uib_back %i",_uib_back.tag);
}

-(void)reloadBuildingVC
{
	NSLog(@"should be tag 0");
	[[NSNotificationCenter defaultCenter] postNotificationName:@"loadOtis" object:nil];
	[_uib_back setTag:0];
	NSLog(@"_uib_back %i",_uib_back.tag);
}


-(void)reloadHero
{
	NSLog(@"should be tag 1");

	[self removeHotspots];

	if (_avPlayerLayer) {
        [self closeMovie];
    }
	
	[self updateStillFrameUnderFilm:@"otis_building_hero.jpg"];
	[_uib_back setTag:0];
	NSLog(@"_uib_back %i",_uib_back.tag);
}


#pragma mark - Info Labels
#pragma mark init top left text box
-(void)initTitleBox
{
    _uiv_textBoxContainer = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view insertSubview:_uiv_textBoxContainer aboveSubview:_uiv_movieContainer];
    _uiv_textBoxContainer.layer.zPosition = MAXFLOAT;
	[self setCompanyTitle:@"OTIS"];
}

-(void)setCompanyTitle:(NSString *)year
{
    [self removeCompanyTitle];
	
	// get width of uilabel
	UIFont *font = [UIFont fontWithName:@"Helvetica-Bold" size:15];
	CGFloat str_width = [self getWidthFromStringLength:year andFont:font];
	static CGFloat labelPad = 15;
	companyLabelWidth = str_width + (labelPad*2);
	
    _uil_Company = [[UILabel alloc] initWithFrame:CGRectMake(0.0, -36.0, companyLabelWidth, 36)];
    [_uil_Company setText:year];
    [_uil_Company setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.8]];
    [_uil_Company setTextColor:[UIColor blackColor]];
    [_uil_Company setFont: font];
    [_uil_Company setTextAlignment:NSTextAlignmentCenter];
	[_uil_Company.layer setBorderColor:[UIColor lightGrayColor].CGColor];
	[_uil_Company.layer setBorderWidth:1.0];
	
	[_uiv_textBoxContainer addSubview: _uil_Company];
	
	// resize text container to fit
	_uiv_textBoxContainer.frame = CGRectMake(75, 0, companyLabelWidth, 36);
	
	[self animate:_uil_Company direction:LabelOnscreen];
}

-(void)removeCompanyTitle
{
	[self animate:_uil_Company direction:LabelOffscreen];
}

-(void)setHotSpotTitle:(NSString *)string
{
	[self removeHotspotTitle];
	
	// get width of uilabel
	UIFont *font = [UIFont fontWithName:@"Helvetica" size:15];
	CGFloat str_width = [self getWidthFromStringLength:string andFont:font];
	static CGFloat labelPad = 20;
	hotspotLabelWidth = str_width + (labelPad);
    
    _uil_HotspotTitle = [[UILabel alloc] initWithFrame:CGRectMake(companyLabelWidth-74, -36, hotspotLabelWidth, 36)];
    [_uil_HotspotTitle setText:string];
	_uil_HotspotTitle.backgroundColor = [UIColor colorWithRed:0.0000 green:0.4667 blue:0.7686 alpha:0.8];
    [_uil_HotspotTitle setTextColor:[UIColor whiteColor]];
	[_uil_HotspotTitle setTextAlignment:NSTextAlignmentCenter];
    [_uil_HotspotTitle setFont:font];
    [_uil_HotspotTitle.layer setBorderColor:[UIColor colorWithRed:0.7922 green:1.0000 blue:1.0000 alpha:1.0].CGColor];
	[_uil_HotspotTitle.layer setBorderWidth:1.0];
	
	[_uiv_textBoxContainer addSubview: _uil_HotspotTitle];
	
	// resize text container to fit
	_uiv_textBoxContainer.frame = CGRectMake(75, 0, hotspotLabelWidth+companyLabelWidth, 36);
	
	[self animate:_uil_HotspotTitle direction:LabelOnscreen];
}

-(void)removeHotspotTitle
{
	[self animate:_uil_HotspotTitle direction:LabelOffscreen];
	
//	_uil_Company.frame = CGRectMake(_uil_Company.frame.origin.x+74, _uil_Company.frame.origin.y, _uil_Company.frame.size.width, _uil_Company.frame.size.height);
//	_uil_HotspotTitle.frame = CGRectMake(_uil_HotspotTitle.frame.origin.x+74, _uil_HotspotTitle.frame.origin.y, _uil_HotspotTitle.frame.size.width, _uil_HotspotTitle.frame.size.height);
//	_uib_back.transform = CGAffineTransformMakeTranslation(-72, 0);
//	[[NSNotificationCenter defaultCenter] postNotificationName:@"moveSplitBtnLeft" object:nil];
}

-(void)animate:(UIView*)viewmove direction:(NSInteger)d
{
	int f = 0;
	if (d == LabelOffscreen) {
		f = -36;
	} else {
		f = 36;
	}
	
	[UIView animateWithDuration:0.3/1.5 animations:^{
		//viewmove.transform = CGAffineTransformTranslate(viewmove.transform, 0, 1*f);
		viewmove.frame = CGRectMake(viewmove.frame.origin.x, viewmove.frame.origin.y+f, viewmove.frame.size.width, viewmove.frame.size.height);
	} completion:^(BOOL completed){
		if (d == LabelOffscreen) {
			[viewmove removeFromSuperview];
		}
	}];
}

#pragma mark - company hotspots
-(void)createHotspots
{
	[self removeHotspots];
	
	[_arr_hotspotsArray removeAllObjects];
    _arr_hotspotsArray = nil;
    _arr_hotspotsArray = [[NSMutableArray alloc] init];
	
	[self loadSingleCompanyHotspots];
}

// load the hotpots of the company selected
-(void)loadSingleCompanyHotspots
{
	[self removeHotspots];

	[_uib_back setTag:2];
	NSLog(@"loadSingleCompanyHotspots _uib_back %i",_uib_back.tag);

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
	NSLog(@"loadCompaniesHotspots");
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
        _myHotspots.alpha = 0.0;
        _myHotspots.tagOfHs = i;
        [_uis_zoomingImg.blurView addSubview:_myHotspots];
    }
	
	NSInteger ii = 0;
	for(UIView *view in [_uis_zoomingImg.blurView subviews]) {
		if([view isKindOfClass:[neoHotspotsView class]]) {
			UIViewAnimationOptions options = UIViewAnimationOptionAllowUserInteraction;
			[UIView animateWithDuration:.2 delay:((0.05 * ii) + 0.2) options:options
							 animations:^{
								 view.alpha = 1.0;
							 }
							 completion:^(BOOL finished){
							 }];
			
			ii += 1;
		}
	}

	CGFloat horizontalMinimum = -20.0f;
	CGFloat horizontalMaximum = 20.0f;
	
	UIInterpolatingMotionEffect *horizontal = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
	horizontal.minimumRelativeValue = @(horizontalMinimum);
	horizontal.maximumRelativeValue = @(horizontalMaximum);
	
	CGFloat verticalMinimum = -20.0f;
	CGFloat verticalMaximum = 20.0f;
	
	UIInterpolatingMotionEffect *vertical = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
	vertical.minimumRelativeValue = @(verticalMinimum);
	vertical.maximumRelativeValue = @(verticalMaximum);
	
	// this time we need to create a motion effects group and add both of our motion effects to it.
	UIMotionEffectGroup *motionEffects = [[UIMotionEffectGroup alloc] init];
	motionEffects.motionEffects = @[horizontal, vertical];
	
	// add the motion effects group to our view
	
	NSMutableArray *mutableArray = [NSMutableArray arrayWithArray:_arr_hotspotsArray];
	NSUInteger count = [mutableArray count];
	// See http://en.wikipedia.org/wiki/Fisher–Yates_shuffle
	if (count > 1) {
		for (NSUInteger i = count - 1; i > 0; --i) {
			[mutableArray exchangeObjectAtIndex:i withObjectAtIndex:arc4random_uniform((int32_t)(i + 1))];
		}
	}
		
	for (int i = 0; i < [_arr_hotspotsArray count]; i++) {
		[_myHotspots addMotionEffect:motionEffects];
	}

}

#pragma mark hotspot tapped
#pragma mark Delegate Method

-(void)neoHotspotsView:(neoHotspotsView *)hotspot withTag:(int)i
{
	neoHotspotsView *tappedView;
	tappedView = _arr_hotspotsArray[i];
	
#warning more robust previously tapped method needed
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
			
			//_uiv_textBoxContainer.transform = CGAffineTransformMakeTranslation(-200, 36);
			
			_uil_Company.frame = CGRectMake(-74, _uil_Company.frame.origin.y, _uil_Company.frame.size.width, _uil_Company.frame.size.height);
			_uil_HotspotTitle.frame = CGRectMake(-74, _uil_HotspotTitle.frame.origin.y, _uil_HotspotTitle.frame.size.width, _uil_HotspotTitle.frame.size.height);
			
			_uib_back.transform = CGAffineTransformMakeTranslation(-72, 0);
			[[NSNotificationCenter defaultCenter] postNotificationName:@"moveSplitBtnLeft" object:nil];

		} completion:^(BOOL completed)
		 {
			 [self setHotSpotTitle:tappedView.str_labelText];

		 }];
		
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
	[self removeHotspotTitle];
	
	[self unhideChrome];

	[UIView animateWithDuration:0.5 animations:^{
		_uis_zoomingImg.alpha = 1.0;
	} completion:^(BOOL completed) {
		[_uis_zoomingInfoImg removeFromSuperview];
		_uis_zoomingInfoImg = nil;
	}];
}

#pragma mark - unhide Chrome
-(void)unhideChrome
{
	[UIView animateWithDuration:0.5 animations:^{
		_uil_Company.frame = CGRectMake(0, _uil_Company.frame.origin.y, _uil_Company.frame.size.width, _uil_Company.frame.size.height);
		_uil_HotspotTitle.frame = CGRectMake(74, _uil_HotspotTitle.frame.origin.y, _uil_HotspotTitle.frame.size.width, _uil_HotspotTitle.frame.size.height);
		_uib_back.transform = CGAffineTransformIdentity;
		[[NSNotificationCenter defaultCenter] postNotificationName:@"moveSplitBtnRight" object:nil];
	} completion:^(BOOL completed) {
		
	}];
}

#pragma mark - Utiltites
#pragma mark Remove Hotspots
-(void)removeHotspots
{
	for (UIView*hotspot in _arr_hotspotsArray) {
		[hotspot removeFromSuperview];
	}
}

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
    
	
	if (tapToPauseEnabled == YES) {
		NSLog(@"tapToPauseEnabled == YES");
		_isPauseable = YES;
		
		[UIView animateWithDuration:0.5 animations:^{
			_uil_Company.frame = CGRectMake(-74, _uil_Company.frame.origin.y, _uil_Company.frame.size.width, _uil_Company.frame.size.height);
			_uil_HotspotTitle.frame = CGRectMake(-74, _uil_HotspotTitle.frame.origin.y, _uil_HotspotTitle.frame.size.width, _uil_HotspotTitle.frame.size.height);
		} completion:nil];
	}

	
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
		//[self loadControlsLabels];
		selectorAfterMovieFinished = @"playerItemLoop:";
		
		UIButton *h = [UIButton buttonWithType:UIButtonTypeCustom];
		h.frame = CGRectMake(1024-94, 0, 94, 36);
		//[h setTitle:@"X" forState:UIControlStateNormal];
		//h.titleLabel.font = [UIFont fontWithName:@"ArialMT" size:14];
		[h setBackgroundImage:[UIImage imageNamed:@"grfx_closeBtn.png"] forState:UIControlStateNormal];
		[h setBackgroundImage:[UIImage imageNamed:@"grfx_closeBtn.png"] forState:UIControlStateHighlighted];
		[h setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		//set their selector using add selector
		[h addTarget:self action:@selector(closeMovie) forControlEvents:UIControlEventTouchUpInside];
		[_uiv_movieContainer addSubview:h];
		
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
	[self removeHotspotTitle];
	
	if (_isPauseable == YES) {
		[self unhideChrome];
	}

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
