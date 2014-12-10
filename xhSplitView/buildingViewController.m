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
#import "PopoverViewController.h"
#import "embUiViewCard.h"
#import "NSTimer+CVPausable.h"

enum { kEnableSwiping = YES };
enum { kEnableDoubleTapToKillMovie = YES };

enum {
    LabelOnscreen,
    LabelOffscreen,
};
typedef NSInteger PlayerState;

static CGFloat backButtonHeight = 51;
static CGFloat backButtonWidth	= 58;
static CGFloat backButtonX		= 36;
static CGFloat backButtonActualHeight = 44;


@interface buildingViewController () <ebZoomingScrollViewDelegate, neoHotspotsViewDelegate, PopoverViewControllerDelegate, UIGestureRecognizerDelegate>
{
	CGFloat companyLabelWidth;
	CGFloat hotspotLabelWidth;
	CGFloat time;
	CGFloat removeTextAfterThisManySeconds;

	NSMutableArray *arr_HotspotInfoCards;
	UIView *uiv_HotspotInfoCardContainer;
}

@property (nonatomic) NSTimer *myTimer;

@property (nonatomic,strong) UIPopoverController *popOver;

- (IBAction)showPopover:(UIButton *)sender;

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
@property (nonatomic, strong) UIButton						*uib_backBtn;
@property (nonatomic, strong) UIView						*uiv_tapSquare;
@property (nonatomic, strong) UIButton						*uib_CompanyBtn;
@property (nonatomic, strong) UILabel						*uil_filmHint;
@property (nonatomic, strong) UIImageView *hotspotImageView;
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
	
	// init arrays and create avplayer
	arr_HotspotInfoCards = [[NSMutableArray alloc] init];
	_arr_hotspotsArray		= [[NSMutableArray alloc] init];
	_arr_BreadCrumbOfImages = [[NSMutableArray alloc] init];
	
	// load animation that leads to the hero
	// building tapped from previous screen
	[self loadMovieNamed:_transitionClipName isTapToPauseEnabled:NO belowSubview:nil];
	// add in the bg image beneath the film
	[self createStillFrameUnderFilm];
	
	time = 1;
		
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
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideBackButton) name:@"hideDetailChrome" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(unhideBackButton) name:@"unhideDetailChrome" object:nil];

}

#pragma mark - stills under movie
-(void)createStillFrameUnderFilm
{
    if (_uiiv_bg) {
        [_uiiv_bg removeFromSuperview];
        _uiiv_bg = nil;
		
		[self removeHotspots];
    }
	
	_uis_zoomingImg = [[ebZoomingScrollView alloc] initWithFrame:CGRectMake(0.0, 0.0, 1024, 768) image:[UIImage imageNamed:@"02_HERO_BLDG.png"] shouldZoom:YES];
    _uis_zoomingImg.delegate = self;
	
	if (_uiv_movieContainer) {
		[self.view insertSubview: _uis_zoomingImg belowSubview:_uiv_movieContainer];
	} else {
		[self.view insertSubview: _uis_zoomingImg belowSubview:_uib_backBtn];
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
	// add container
	_uiv_tapSquare = [[UIView alloc] initWithFrame:CGRectZero];
	_uiv_tapSquare.frame = CGRectMake(473, 670, 80, 80);
	[_uiv_tapSquare setBackgroundColor:[UIColor clearColor]];
	[_uiv_tapSquare setUserInteractionEnabled:YES];

	UIView *uiv_tapCircle = [[UIView alloc] initWithFrame:CGRectZero];
	uiv_tapCircle.frame = CGRectMake(20, 20, 40, 40);
	uiv_tapCircle.layer.cornerRadius = uiv_tapCircle.frame.size.width/2;
	[uiv_tapCircle setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.5]];
	
	if (_uiv_movieContainer) {
		[self.view insertSubview:_uiv_tapSquare belowSubview:_uiv_movieContainer];
	} else {
		[self.view addSubview:_uiv_tapSquare];
	}
	
	//[self.view addSubview:uiv_circleContainer];
	[_uiv_tapSquare addSubview:uiv_tapCircle];
	
	UITapGestureRecognizer *tapOnImg = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(filmToSplitBuilding)];
    [_uiv_tapSquare addGestureRecognizer: tapOnImg];

	[self pulse:uiv_tapCircle.layer];
}

-(void)initLogoBtn
{
	_uib_CompanyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
	
#ifdef NEODEMO
	_uib_CompanyBtn.frame = CGRectMake(565.0, 245.0, 40, 40);
	_uib_CompanyBtn.layer.cornerRadius = _uib_CompanyBtn.frame.size.width/2;
	
#else
	_uib_CompanyBtn.frame = CGRectMake(469.0, 180.0, 87, 55);
	
#endif
	
    _uib_CompanyBtn.backgroundColor = [UIColor colorWithWhite:1 alpha:0.75];
    [_uib_CompanyBtn addTarget:self action:@selector(showPopover:) forControlEvents:UIControlEventTouchUpInside];
    [_uis_zoomingImg.blurView addSubview:_uib_CompanyBtn];
	
	[self pulse:_uib_CompanyBtn.layer];
}

#pragma mark - Actions to play path to hero and split hero
-(void)filmToSplitBuilding
{
    [self loadMovieNamed:@"02_TRANS_BLDG_UNBUILD.mov" isTapToPauseEnabled:NO belowSubview:nil];
	[_uiv_tapSquare removeFromSuperview];
	[self loadSplitAssets];
}

-(void)filmTransitionToHotspots
{
	 _uib_logoBtn.hidden = YES;
    [self loadMovieNamed:@"03_TRANS_ELEV.mov" isTapToPauseEnabled:NO belowSubview:nil];
    [self updateStillFrameUnderFilm:@"04_HOTSPOT_CROSS_SECTION.png"];
	
	[self createHotspots];
	
	[self initTitleBox];
}

-(void)loadSplitAssets
{
	[self removeHotspotTitle];
	[self removeCompanyTitle];
	
#ifdef NEODEMO
	[self updateStillFrameUnderFilm:@"03A Building Cut DEMO.png"];
#else
	[self updateStillFrameUnderFilm:@"03A Building Cut.png"];
#endif
	
	[self initLogoBtn];
	
	[self removeHotspots];
	[_arr_hotspotsArray removeAllObjects];
		
	[_uib_backBtn setTag:1];
	NSLog(@"_uib_back %li",(long)_uib_backBtn.tag);
}

#pragma mark - menu buttons
-(void)createBackButton
{
	NSLog(@"createBackButton AGAIN");
		_uib_backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
		_uib_backBtn.frame = CGRectMake(backButtonX, 0.0, 58, backButtonHeight);
		[_uib_backBtn setImage:[UIImage imageNamed:@"icon back.png"] forState:UIControlStateNormal];
		[self.view addSubview:_uib_backBtn];
		[_uib_backBtn addTarget:self action:@selector(performSelectorFromArray) forControlEvents:UIControlEventTouchUpInside];
		_uib_backBtn.layer.zPosition = MAXFLOAT;
		[_uib_backBtn setTag:0];
		NSLog(@"_uib_back %li",(long)_uib_backBtn.tag);
	
}

-(void)hideBackButton
{
	NSLog(@"hideBackButton");
	self.uib_backBtn.hidden = YES;
	self.uib_backBtn.transform = CGAffineTransformMakeTranslation(-backButtonWidth*2, 0);
	[_uil_Company setHidden:YES];
}

-(void)unhideBackButton
{
	NSLog(@"==unhideBackButton");
	self.uib_backBtn.hidden = NO;
	self.uib_backBtn.transform = CGAffineTransformIdentity;
	[_uil_Company setHidden:NO];
}

-(void)performSelectorFromArray
{
	NSValue *val = _arr_BreadCrumbOfImages[_uib_backBtn.tag];
	SEL mySelector = [val pointerValue];
	//	[self performSelector:mySelector];
	IMP imp = [self methodForSelector:mySelector];
	void (*func)(id, SEL) = (void *)imp;
	func(self, mySelector);
	
	NSLog(@"_uib_back %li",(long)_uib_backBtn.tag);
}

-(void)reloadBuildingVC
{
	NSLog(@"should be tag 0");
	[[NSNotificationCenter defaultCenter] postNotificationName:@"loadOtis" object:nil];
	[_uib_backBtn setTag:0];
	NSLog(@"_uib_back %li",(long)_uib_backBtn.tag);
}


-(void)reloadHero
{
	NSLog(@"should be tag 1");

	[self removeHotspots];

	if (_avPlayerLayer) {
        [self closeMovie];
    }
	
	[_hotspotImageView removeFromSuperview];
	[_uib_CompanyBtn removeFromSuperview];
	
	[self updateStillFrameUnderFilm:@"02_HERO_BLDG.png"];
	[_uib_backBtn setTag:0];
	NSLog(@"_uib_back %li",(long)_uib_backBtn.tag);
	
	[self initSplitOpenBtn];

}


#pragma mark - Info Labels
#pragma mark init top left text box
-(void)initTitleBox
{
    _uiv_textBoxContainer = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view insertSubview:_uiv_textBoxContainer aboveSubview:_uiv_movieContainer];
    _uiv_textBoxContainer.layer.zPosition = MAXFLOAT;
	
#ifdef NEODEMO
	[self setCompanyTitle:@"Elevator"];
#else
	[self setCompanyTitle:@"Otis"];
#endif
	
}

-(void)setCompanyTitle:(NSString *)year
{
    [self removeCompanyTitle];
	
	// get width of uilabel
	UIFont *font = [UIFont fontWithName:@"Helvetica-Bold" size:19];
	CGFloat str_width = [self getWidthFromStringLength:year andFont:font];
	static CGFloat labelPad = 15;
	companyLabelWidth = str_width + (labelPad*2);
	
    _uil_Company = [[UILabel alloc] initWithFrame:CGRectMake(0.0, -backButtonActualHeight, companyLabelWidth, backButtonActualHeight)];
    [_uil_Company setText:year];
    [_uil_Company setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.8]];
    [_uil_Company setTextColor:[UIColor blackColor]];
    [_uil_Company setFont: font];
    [_uil_Company setTextAlignment:NSTextAlignmentCenter];
	[_uil_Company.layer setBorderColor:[UIColor lightGrayColor].CGColor];
	[_uil_Company.layer setBorderWidth:1.0];
	
	[_uiv_textBoxContainer addSubview: _uil_Company];
	
	// resize text container to fit
	_uiv_textBoxContainer.frame = CGRectMake(backButtonX+backButtonWidth-7, 0, companyLabelWidth, backButtonHeight);
	
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
	UIFont *font = [UIFont fontWithName:@"Helvetica" size:19];
	CGFloat str_width = [self getWidthFromStringLength:string andFont:font];
	static CGFloat labelPad = 20;
	hotspotLabelWidth = str_width + (labelPad);
    
    _uil_HotspotTitle = [[UILabel alloc] initWithFrame:CGRectMake(companyLabelWidth-backButtonWidth-15, -backButtonActualHeight, hotspotLabelWidth, backButtonActualHeight)];
    [_uil_HotspotTitle setText:string];
	_uil_HotspotTitle.backgroundColor = [UIColor colorWithRed:0.0000 green:0.4667 blue:0.7686 alpha:0.8];
    [_uil_HotspotTitle setTextColor:[UIColor whiteColor]];
	[_uil_HotspotTitle setTextAlignment:NSTextAlignmentCenter];
    [_uil_HotspotTitle setFont:font];
    [_uil_HotspotTitle.layer setBorderColor:[UIColor colorWithRed:0.7922 green:1.0000 blue:1.0000 alpha:1.0].CGColor];
	[_uil_HotspotTitle.layer setBorderWidth:1.0];
	
	[_uiv_textBoxContainer addSubview: _uil_HotspotTitle];
	
	// resize text container to fit
	_uiv_textBoxContainer.frame = CGRectMake(73, 0, hotspotLabelWidth+companyLabelWidth, backButtonHeight);
	
	[self animate:_uil_HotspotTitle direction:LabelOnscreen];
}

-(void)removeHotspotTitle
{
	[self animate:_uil_HotspotTitle direction:LabelOffscreen];
}

-(void)animate:(UIView*)viewmove direction:(NSInteger)d
{
	int f = 0;
	if (d == LabelOffscreen) {
		f = -backButtonActualHeight;
	} else {
		f = backButtonActualHeight;
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

	[_uib_backBtn setTag:2];

    NSString *path = [[NSBundle mainBundle] pathForResource:
					  @"hotspotsData" ofType:@"plist"];
	NSDictionary *totalDataDict = [[NSDictionary alloc] initWithContentsOfFile:path];
	
	//Get the exact second to remove the text boxes
	removeTextAfterThisManySeconds = [[totalDataDict objectForKey:@"removeafterseconds"] intValue];
	
	// get array of all hotspots
    NSMutableArray *totalDataArray = [totalDataDict objectForKey:@"hotspots"];
	
	for (int i = 0; i < [totalDataArray count]; i++) {
        NSDictionary *hotspotItem = totalDataArray [i];
        
        //Get the position of Hs
        NSString *str_position = [[NSString alloc] initWithString:[hotspotItem objectForKey:@"xy"]];
        NSRange range = [str_position rangeOfString:@","];
        NSString *str_x = [str_position substringWithRange:NSMakeRange(0, range.location)];
        NSString *str_y = [str_position substringFromIndex:(range.location + 1)];
        float hs_x = [str_x floatValue];
        float hs_y = [str_y floatValue];
        _myHotspots = [[neoHotspotsView alloc] initWithFrame:CGRectMake(hs_x, hs_y, 49, 42)];
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

- (IBAction)showPopover:(UIButton *)sender {
	
  PopoverViewController *PopoverView =[[PopoverViewController alloc] initWithNibName:@"PopoverViewController" bundle:nil];
  self.popOver =[[UIPopoverController alloc] initWithContentViewController:PopoverView];
  PopoverView.delegate = self;
  [self.popOver presentPopoverFromRect:sender.frame inView:_uis_zoomingImg.blurView permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
}

#pragma mark - PopoverViewControllerDelegate method
-(void)selectedRow:(NSInteger)row
{
	[self loadCompaniesHotspots];
	//The color picker popover is showing. Hide it.
	[self.popOver dismissPopoverAnimated:YES];
	self.popOver = nil;
}


// load all the companies onto the view
-(void)loadCompaniesHotspots
{
	NSLog(@"asd");
	
	[_hotspotImageView removeFromSuperview];
	[_uib_CompanyBtn removeFromSuperview];
	
	[self filmTransitionToHotspots];
	/*
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
*/
}

#pragma mark hotspot tapped
#pragma mark Delegate Method

-(void)neoHotspotsView:(neoHotspotsView *)hotspot withTag:(int)i
{
	neoHotspotsView *tappedView;
	tappedView = _arr_hotspotsArray[i];
	
#warning more robust previously tapped method needed
	tappedView.alpha = 0.75;
	[tappedView setLabelAlpha:0.75];
	
	if ([tappedView.str_typeOfHs isEqualToString:@"company"]) {
		[self filmTransitionToHotspots];
	} else {
		NSLog(@"str_typeOfHs %@",tappedView.str_typeOfHs);
		
		if ([tappedView.str_typeOfHs isEqualToString:@"movie"]) {
			
			switch (i) {
				case 0:
					[self loadMovieNamed:@"05_HOTSPOT_F_REMOTE_DIAGNOSTICS.mov" isTapToPauseEnabled:YES belowSubview:_uis_zoomingImg];
					break;
				case 1:
					[self loadMovieNamed:@"05_HOTSPOT_C_REGEN_DRIVE.mov" isTapToPauseEnabled:YES belowSubview:_uis_zoomingImg];
					break;
				case 2:
					[self loadMovieNamed:@"05_HOTSPOT_E_GLIDE_DOOR_OPERATORS.mov" isTapToPauseEnabled:YES belowSubview:_uis_zoomingImg];
					break;
				case 3:
					[self loadMovieNamed:@"05_HOTSPOT_D_ERT.mov" isTapToPauseEnabled:YES belowSubview:_uis_zoomingImg];
					break;
				case 4:
					[self loadMovieNamed:@"05_HOTSPOT_A_COATED_STEEL_BELTS.mov" isTapToPauseEnabled:YES belowSubview:_uis_zoomingImg];
					break;
				case 5:
					[self loadMovieNamed:@"05_HOTSPOT_B_COMPACT_CONTROLLER.mov" isTapToPauseEnabled:YES belowSubview:_uis_zoomingImg];
					break;
					
				default:
					break;
			}
			/*
			05_HOTSPOT_E_GLIDE_DOOR_OPERATORS.m4v
			05_HOTSPOT_B_COMPACT_CONTROLLER.m4v
			05_HOTSPOT_C_REGEN_DRIVE.m4v
			05_HOTSPOT_D_ERT.m4v
			05_HOTSPOT_F_REMOTE_DIAGNOSTICS.m4v
			05_HOTSPOT_A_COATED_STEEL_BELTS.m4v
			*/
		} else {
			[self popUpImage];
		}
		
		[_uis_zoomingImg zoomToPoint:CGPointMake(tappedView.center.x, tappedView.center.y) withScale:1.5 animated:YES];
		[UIView animateWithDuration:0.5 animations:^{
			_uis_zoomingImg.alpha = 0.0;
			
			//_uiv_textBoxContainer.transform = CGAffineTransformMakeTranslation(-200, 36);
			
			_uil_Company.frame = CGRectMake(-74, _uil_Company.frame.origin.y, _uil_Company.frame.size.width, _uil_Company.frame.size.height);
			_uil_HotspotTitle.frame = CGRectMake(-40, _uil_HotspotTitle.frame.origin.y, _uil_HotspotTitle.frame.size.width, _uil_HotspotTitle.frame.size.height);
			
			_uib_backBtn.transform = CGAffineTransformMakeTranslation(-backButtonWidth*2, 0);
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
	[UIView animateWithDuration:0.33 animations:^{
		_uil_Company.frame = CGRectMake(14, _uil_Company.frame.origin.y, _uil_Company.frame.size.width, _uil_Company.frame.size.height);
		_uil_HotspotTitle.frame = CGRectMake(74, _uil_HotspotTitle.frame.origin.y, _uil_HotspotTitle.frame.size.width, _uil_HotspotTitle.frame.size.height);
		_uib_backBtn.transform = CGAffineTransformIdentity;
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
	theAnimation.fromValue=[NSNumber numberWithFloat:0.70];
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

- (void) handlePanGesture:(UIPanGestureRecognizer*)pan{
	
	/*
	//CGFloat time = 1;
	CGPoint vel = [pan velocityInView:self.view];
	
    if (vel.x > 0)
    {
        // user dragged towards the right
		NSLog(@"+");
		time ++;
    }
    else
    {
        // user dragged towards the left
		NSLog(@"-");
		time --;

    }
	NSLog(@"time %f", time);

	[_avPlayer seekToTime:CMTimeMakeWithSeconds(time, 10) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
	
	if(pan.state == UIGestureRecognizerStateEnded){
		time = 0;
	}
	*/
	
	
//	CGPoint translate = [pan translationInView:self.view];
//	CGFloat xCoord = translate.x;
//    double diff = (xCoord);
//    NSLog(@"%F",diff);
	
	//[_avPlayer seekToTime:CMTimeMakeWithSeconds(time, 10) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
	
	/*
	CGPoint translation = [pan translationInView:self.view];
	
    // Figure out where the user is trying to drag the view.
    CGPoint newCenter = CGPointMake(self.view.bounds.size.width / 2,
									pan.view.center.y + translation.y);
	
    // See if the new position is in bounds.
    if (newCenter.y >= 160 && newCenter.y <= 300) {
        pan.view.center = newCenter;
        [pan setTranslation:CGPointZero inView:self.view];
    }
	*/
	
	
//	if(pan.state == UIGestureRecognizerStateEnded){
//		[_avPlayer play];
//	} else {
//		CGPoint velocity = [pan translationInView:self.view];
//		CGFloat xVel = velocity.x;
//		int i = xVel*100;
//		CGFloat rate = i/10000;
//		[_avPlayer seekToTime:CMTimeMakeWithSeconds(rate, 10) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
//	}
	
	
    /*
	CGPoint translate = [pan translationInView:self.view];
    CGFloat xCoord = translate.x;
    double diff = (xCoord);
    //NSLog(@"%F",diff);
	
	CMTime duration = self.avPlayer.currentItem.asset.duration;
	float seconds = CMTimeGetSeconds(duration);
	NSLog(@"duration: %.2f", seconds);
	
	
	CGFloat gh = 0;
	//[_avPlayer seekToTime:CMTimeMakeWithSeconds(seconds*(Float64)diff , 1024) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
	
    if (diff>=0) {
        //If the difference is positive
        //moviePlayer.currentPlaybackTime = [moviePlayer currentPlaybackTime] + (diff/10);
		NSLog(@"%f",diff);
		gh = diff;
    } else {
        //If the difference is negative
        //moviePlayer.currentPlaybackTime = [moviePlayer currentPlaybackTime] - (diff/10);
		NSLog(@"%f",diff*-1);
		gh = diff*-1;
    }
	
	float minValue = 0;
	float maxValue = 1024;
	float value = gh;
	
	double time = seconds * (value - minValue) / (maxValue - minValue);
	NSLog(@"Seek Time in Seconds is : %f", time);
	//NSEC_PER_SEC
	//600
	//10
	[_avPlayer seekToTime:CMTimeMakeWithSeconds(time, 10) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
	 */
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
		
		[UIView animateWithDuration:0.3 animations:^{
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
        //[[NSNotificationCenter defaultCenter] removeObserver:self];
		[[NSNotificationCenter defaultCenter] removeObserver:self name:@"playerItemLoop:" object:nil];
		[[NSNotificationCenter defaultCenter] removeObserver:self name:@"playerItemDidReachEnd:" object:nil];
    }
	
	_uiv_movieContainer = [[UIView alloc] initWithFrame:self.view.frame];
	[_uiv_movieContainer setBackgroundColor:[UIColor clearColor]];
	
	UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
	
    [_uiv_movieContainer addGestureRecognizer:panGesture];
	
    //[_uiv_movieContainer setUserInteractionEnabled:YES];
    //[_uiv_movieContainer addGestureRecognizer:panGesture];
	
	
	if (belowSubview != nil) {
		[self.view insertSubview:_uiv_movieContainer belowSubview:belowSubview];
	} else {
		[self.view addSubview:_uiv_movieContainer];
	}
	
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
	
    [_uiv_movieContainer.layer addSublayer: _avPlayerLayer];
	
	// starts the player as well
	[self beginSequence];
	
	[self updateStillFrameUnderFilm:@"04_HOTSPOT_CROSS_SECTION.png"];
	
	NSString *selectorAfterMovieFinished;
	
	if (tapToPauseEnabled == YES) {
		[self addMovieGestures];
		//[self loadControlsLabels];
		selectorAfterMovieFinished = @"playerItemLoop:";
		
		UIButton *h = [UIButton buttonWithType:UIButtonTypeCustom];
		h.frame = CGRectMake(1024-36, 0, 36, 36);
		//[h setTitle:@"X" forState:UIControlStateNormal];
		//h.titleLabel.font = [UIFont fontWithName:@"ArialMT" size:14];
		[h setBackgroundImage:[UIImage imageNamed:@"close bttn.png"] forState:UIControlStateNormal];
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

- (UIImage *)flipImage:(UIImage *)image
{
    UIGraphicsBeginImageContext(image.size);
    CGContextDrawImage(UIGraphicsGetCurrentContext(),CGRectMake(0.,0., image.size.width, image.size.height),image.CGImage);
    UIImage *i = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return i;
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
	
	// starts the player as well
	[self beginSequence];
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
		//[_avPlayer play];
		[self resumeAnimation];
	} else {
		//[_avPlayer pause];
		[self pauseAnimation];
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
	//[_avPlayer play];
	[self resumeAnimation];
	[self updateFilmHint];
}

-(void)swipeDownPause:(id)sender {
	//[_avPlayer pause];
	[self pauseAnimation];
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

	[UIView animateWithDuration:0.3 animations:^{
		_uis_zoomingImg.alpha = 1.0;
			
	} completion:^(BOOL completed) {
		[_uis_zoomingInfoImg removeFromSuperview];
		_uis_zoomingInfoImg = nil;
		
		[_avPlayerLayer removeFromSuperlayer];
		_avPlayerLayer = nil;
		[_uiv_movieContainer removeFromSuperview];
		_uiv_movieContainer=nil;

	}];
	
	if (_myTimer) {
		[self.myTimer invalidate];
		self.myTimer = nil;
	}
}

//----------------------------------------------------
#pragma mark - start sequences
//----------------------------------------------------
/*
 start all info cards and movie in motion
 */
-(void)beginSequence
{
	[_avPlayer play];
	[self startMovieTimer];
	[self createCards];
}

//----------------------------------------------------
#pragma mark - info cards
//----------------------------------------------------
/*
 create info cards from model
 */
-(void)createCards
{
	uiv_HotspotInfoCardContainer = [[UIView alloc] initWithFrame:CGRectZero];
	uiv_HotspotInfoCardContainer.layer.backgroundColor = [UIColor clearColor].CGColor;
	uiv_HotspotInfoCardContainer.clipsToBounds = YES;
	
	[_uiv_movieContainer addSubview:uiv_HotspotInfoCardContainer];
	
	CGFloat textViewHeight = 0;
	
	NSString *path = [[NSBundle mainBundle] pathForResource:
					  @"hotspotsData" ofType:@"plist"];
	NSDictionary *totalDataDict = [[NSDictionary alloc] initWithContentsOfFile:path];
	
	NSMutableArray *totalDataArray = [totalDataDict objectForKey:@"hotspots"];

	NSDictionary *hotspotItem = totalDataArray [0];
	NSArray *hotspotText = [hotspotItem objectForKey:@"hotspottext"];
	
	for (int i = 0; i < [hotspotText count]; i++) {
		NSDictionary *box = hotspotText[i];
		
		embUiViewCard *card = [[embUiViewCard alloc] init];
		[card setBackgroundColor:[[UIColor clearColor] colorWithAlphaComponent:0.5]];
		card.delay = (int)[[box objectForKey:@"appearanceDelay"] integerValue];
		card.text = [box objectForKey:@"copy"];
		NSLog(@"%@",card.text);
		
		[card setFrame:CGRectMake(0, textViewHeight, 360, [self measureHeightOfUITextView:card.textView])];
		card.alpha = 0;
		[arr_HotspotInfoCards addObject:card];
		[uiv_HotspotInfoCardContainer addSubview:card];
		textViewHeight += [self measureHeightOfUITextView:card.textView];
	}
	
	// update container frame now that we know the heights
	uiv_HotspotInfoCardContainer.frame = CGRectMake(120, 200, 360, textViewHeight);
	
}

-(void)removeCards
{
	NSInteger i = 0;
	
	for (embUiViewCard *card in arr_HotspotInfoCards)
	{
		
		UIViewAnimationOptions options = UIViewAnimationOptionAllowUserInteraction;
		[UIView animateWithDuration:.2 delay:((0.05 * i) + 0.2) options:options
						 animations:^{
							 card.alpha = 0.0;
						 }
						 completion:^(BOOL finished){
							 [arr_HotspotInfoCards removeObject:card];
						 }];
		i += 1;
	}
}

//----------------------------------------------------
#pragma mark find card that should appear
//----------------------------------------------------

// find card and remove
-(void)indexOfCardToReveal:(int)index
{
	for (embUiViewCard *card in arr_HotspotInfoCards)
	{
		if (card.delay == index) {
			embUiViewCard *ccard = arr_HotspotInfoCards[[arr_HotspotInfoCards indexOfObject:card]];
			[self revealCard:ccard afterDelay:0];
		}
	}
	
}

//----------------------------------------------------
#pragma mark reveal card
//----------------------------------------------------

// reveal card
-(void)revealCard:(embUiViewCard*)card afterDelay:(CGFloat)delay
{
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		
		card.alpha = 1.0;
		CAKeyframeAnimation *anim = [CAKeyframeAnimation animationWithKeyPath:@"position"];
		
		NSLog(@"%@",[card description]);
		
		
		// get index of card to know whether
		// to animate it bouncing/falling
		
		NSUInteger index = [arr_HotspotInfoCards indexOfObject:card];
		
		embUiViewCard *ccard;
		ccard =  [arr_HotspotInfoCards objectAtIndex:index];
		
		CGFloat startPointX = card.center.x;
		CGFloat startPointY = card.center.y;
		
		NSLog(@"rect1: %f", startPointY);
		
		
		UIView *maskView = [[UIView alloc] initWithFrame:CGRectMake(card.frame.origin.x, card.frame.origin.y, 360, card.frame.size.height+20)];
		maskView.layer.backgroundColor = [UIColor clearColor].CGColor;
		maskView.clipsToBounds = YES;
		[maskView addSubview:card];
		[uiv_HotspotInfoCardContainer addSubview:maskView];
		
		NSArray *values;
		
		if (index == 0) { // no animation of falling/bouncing
			values = [NSArray arrayWithObjects:[NSValue valueWithCGPoint:CGPointMake(startPointX, startPointY)],
					  [NSValue valueWithCGPoint:CGPointMake(startPointX, startPointY)], nil];
		} else {
			values = [NSArray arrayWithObjects:[NSValue valueWithCGPoint:CGPointMake(startPointX, -card.frame.size.height/2)],
					  [NSValue valueWithCGPoint:CGPointMake(startPointX, card.frame.size.height/1.9)],
					  [NSValue valueWithCGPoint:CGPointMake(startPointX, card.frame.size.height/2.1)],
					  [NSValue valueWithCGPoint:CGPointMake(startPointX, card.frame.size.height/1.95)],
					  [NSValue valueWithCGPoint:CGPointMake(startPointX, card.frame.size.height/2)], nil];
		}
		
		[anim setValues:values];
		[anim setDuration:1.0]; //seconds
		anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
		
		[card.layer addAnimation:anim forKey:@"position"];
		
		[card setCenter:CGPointMake(startPointX, card.frame.size.height/2)];
		
		NSLog(@"rect1: %@", NSStringFromCGRect(card.frame));
		
		CALayer *mask = [CALayer layer];
		mask.contents = (id)[[UIImage imageNamed:@"card_mask.png"] CGImage];
		
		if (index == 0) {
			mask.frame = CGRectMake(0, 0, 0, 0);
			mask.anchorPoint = CGPointMake(0, 0);
			
			card.layer.mask = mask;
			
			CGRect oldBounds = mask.bounds;
			CGRect newBounds = card.bounds;
			
			CABasicAnimation* revealAnimation = [CABasicAnimation animationWithKeyPath:@"bounds"];
			revealAnimation.fromValue = [NSValue valueWithCGRect:oldBounds];
			revealAnimation.toValue = [NSValue valueWithCGRect:newBounds];
			revealAnimation.duration = 0.33;
			
			// Update the bounds so the layer doesn't snap back when the animation completes.
			mask.bounds = newBounds;
			
			[mask addAnimation:revealAnimation forKey:@"revealAnimation"];
			
		}
		
	});
}

//----------------------------------------------------
#pragma mark pause card animations
//----------------------------------------------------
/*
 actions for pausing and resuming animations
 */



- (IBAction)pauseAnimation
{
	[_myTimer pauseOrResume];
	
	[_avPlayer pause];
	
	for (embUiViewCard *card in arr_HotspotInfoCards)
	{
		[self pauseLayer:card.layer];
	}
}

- (IBAction)resumeAnimation
{
	[_avPlayer play];
	
	if (_myTimer.isPaused) {
		[_myTimer pauseOrResume];
	}
	
	for (embUiViewCard *card in arr_HotspotInfoCards)
	{
		[self resumeLayer:card.layer];
	}
}

-(void)pauseLayer:(CALayer*)layer
{
	CFTimeInterval pausedTime = [layer convertTime:CACurrentMediaTime() fromLayer:nil];
	layer.speed = 0.0;
	layer.timeOffset = pausedTime;
}

-(void)resumeLayer:(CALayer*)layer
{
	CFTimeInterval pausedTime = [layer timeOffset];
	layer.speed = 1.0;
	layer.timeOffset = 0.0;
	layer.beginTime = 0.0;
	CFTimeInterval timeSincePause = [layer convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
	layer.beginTime = timeSincePause;
}

//----------------------------------------------------
#pragma mark - timer
//----------------------------------------------------
/*
 keeps track of number seconds elapsed
 to help sync which card to reveal next
 */

-(void)startMovieTimer
{
	if (_myTimer) {
		[self.myTimer invalidate];
		self.myTimer = nil;
	}
	
	self.myTimer = [NSTimer scheduledTimerWithTimeInterval:1
													target:self
												  selector:@selector(displayMyCurrentTime:)
												  userInfo:nil
												   repeats:YES];
	
	NSLog(@"== /n/nstart timer");
}


//----------------------------------------------------
#pragma mark - utilties
//----------------------------------------------------
/*
 calculate height of
 */
- (CGFloat)measureHeightOfUITextView:(UITextView *)textView
{
	if ([textView respondsToSelector:@selector(snapshotViewAfterScreenUpdates:)])
	{
		// This is the code for iOS 7. contentSize no longer returns the correct value, so
		// we have to calculate it.
		//
		// This is partly borrowed from HPGrowingTextView, but I've replaced the
		// magic fudge factors with the calculated values (having worked out where
		// they came from)
		
		CGRect frame = textView.bounds;
		
		// Take account of the padding added around the text.
		
		UIEdgeInsets textContainerInsets = textView.textContainerInset;
		UIEdgeInsets contentInsets = textView.contentInset;
		
		CGFloat leftRightPadding = textContainerInsets.left + textContainerInsets.right + textView.textContainer.lineFragmentPadding * 2 + contentInsets.left + contentInsets.right;
		CGFloat topBottomPadding = textContainerInsets.top + textContainerInsets.bottom + contentInsets.top + contentInsets.bottom;
		
		frame.size.width -= leftRightPadding;
		frame.size.height -= topBottomPadding;
		
		NSString *textToMeasure = textView.text;
		if ([textToMeasure hasSuffix:@"\n"])
		{
			textToMeasure = [NSString stringWithFormat:@"%@-", textView.text];
		}
		
		// NSString class method: boundingRectWithSize:options:attributes:context is
		// available only on ios7.0 sdk.
		
		NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
		[paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
		
		NSDictionary *attributes = @{ NSFontAttributeName: [UIFont systemFontOfSize:18.5], NSParagraphStyleAttributeName : paragraphStyle };
		
		CGRect size = [textToMeasure boundingRectWithSize:CGSizeMake(360, MAXFLOAT)
												  options:NSStringDrawingUsesLineFragmentOrigin
											   attributes:attributes
												  context:nil];
		
		NSLog(@"fontSize = \tbounds = (%f x %f)",
			  size.size.width,
			  size.size.height);
		
		CGFloat measuredHeight = ceilf(CGRectGetHeight(size) + topBottomPadding);
		
		NSLog(@"measuredHeight %f)",
			  measuredHeight);
		
		return measuredHeight;
	}
	else
	{
		return textView.contentSize.height;
	}
}

/*
 as each second passes check if the seconds
 match the reveal delay
 */
- (void)displayMyCurrentTime:(NSTimer *)timer
{
	CGFloat movieLength = CMTimeGetSeconds([_avPlayer currentTime]);
	
	int y = movieLength;
	NSLog(@"seconds %i",y);
	
	if (y == removeTextAfterThisManySeconds) {
		[self removeCards];
	}
	
	// check if the seconds match the reveal delay
	[self indexOfCardToReveal:y];
}



#pragma mark - boiler plate

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
