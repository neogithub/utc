//
//  otisViewController.m
//  xhSplitViewController
//
//  Created by Xiaohe Hu on 9/3/14.
//  Copyright (c) 2014 Neoscape. All rights reserved.
//

#import "buildingViewController.h"
#import "ebZoomingScrollView.h"

#import <AVFoundation/AVPlayer.h>
#import <AVFoundation/AVFoundation.h>

#import "neoHotspotsView.h"
#import "PopoverViewController.h"

#import "embUiViewCard.h"
#import "NSTimer+CVPausable.h"

#import "LibraryAPI.h"
#import "Company.h"
#import "embTitle.h"
#import "UIImage+FlipImage.h"

#define kshowNSLogBOOL YES

static CGFloat backButtonHeight = 51;
static CGFloat backButtonWidth	= 58;
static CGFloat backButtonX		= 36;

enum {
	TitleLabelsOnscreen,
	TitleLabelsOffscreen,
};

@interface buildingViewController () <ebZoomingScrollViewDelegate, neoHotspotViewDelegate, PopoverViewControllerDelegate,UIPopoverControllerDelegate, UIGestureRecognizerDelegate>
{
	// fact cards
    CGFloat removeTextAfterThisManySeconds;
	NSMutableArray	*arr_HotspotInfoCards;
	UIView			*uiv_HotspotInfoCardContainer;

	neoHotspotsView *tappedView;
	Company			*selectedCo;
	NSDictionary	*selectedCoDict;
	NSArray			*allCompanies;
	
	NSMutableArray	*arr_CompanyLogos;
	embTitle		*topTitle;
	NSString		*topname;
    int             factWidth;
    NSInteger       selctedRow;
    BOOL            hotspotHasLooped;
    UIButton        *uib_logoTapped;
    
    NSMutableArray	*arr_SelectedRows;

}

- (IBAction)showPopover:(UIButton *)sender;


@property (nonatomic) NSTimer *myTimer;

@property (nonatomic, strong) UIPopoverController *popOver;
@property (nonatomic, strong) UIView						*uiv_movieContainer;
@property (nonatomic, strong) UIImageView					*uiiv_bg;
@property (nonatomic, strong) NSMutableArray				*arr_hotspotsArray;
@property (nonatomic, strong) NSMutableArray				*arr_companyHotspotArray;
@property (nonatomic, strong) NSArray						*arr_subHotspots;
@property (nonatomic, strong) NSMutableArray				*arr_BreadCrumbOfImages;

@property (nonatomic, strong) ebZoomingScrollView			*uis_zoomingImg;
@property (nonatomic, strong) ebZoomingScrollView			*uis_zoomingInfoImg;

@property (nonatomic, strong) AVPlayer						*avPlayer;
@property (nonatomic, strong) AVPlayerLayer					*avPlayerLayer;
@property (nonatomic, strong) UIButton						*uib_logoBtn;
@property (nonatomic, strong) UIButton						*uib_backBtn;
@property (nonatomic, strong) UIButton						*uib_ibtBtn;
@property (nonatomic, strong) UIView						*uiv_tapSquare;
@property (nonatomic, strong) UIButton						*uib_CompanyBtn;
@property (nonatomic, strong) UILabel						*uil_filmHint;
@property (nonatomic, strong) UIImageView                   *hotspotImageView;
@property (nonatomic, strong) neoHotspotsView				*myHotspots;
@property (nonatomic, strong) NSMutableArray				*arr_hotspots;
@property (nonatomic, strong) NSDictionary                  *coDict;
@property (nonatomic) BOOL      isPauseable;

@end

@implementation buildingViewController

-(void)viewWillAppear:(BOOL)animated
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"com.neoscape.SelectedRows"];
    NSLog(@"viewwillappear");
}

#pragma mark - viewDidLoad
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.frame = CGRectMake(0.0, 0.0, 1024, 768);
	
	// init arrays and create avplayer
	arr_HotspotInfoCards	= [[NSMutableArray alloc] init];
	_arr_hotspotsArray		= [[NSMutableArray alloc] init];
	_arr_BreadCrumbOfImages = [[NSMutableArray alloc] init];
	arr_CompanyLogos		= [[NSMutableArray alloc] init];
    
    arr_SelectedRows        = [[NSMutableArray alloc] init];
    
	// load animation that leads to the hero
	// building tapped from previous screen
	[self loadMovieNamed:_transitionClipName isTapToPauseEnabled:NO belowSubview:nil withOverlay:nil];
	// add in the bg image beneath the film
	[self createStillFrameUnderFilm];
	
	[self createBackButton];
	
    // breadcrumb of selectors based on int set
	NSValue* selCommandA = [NSValue valueWithPointer:@selector(reloadBuildingVC)];
	NSValue* selCommandB = [NSValue valueWithPointer:@selector(reloadHero)];
	NSValue* selCommandC = [NSValue valueWithPointer:@selector(loadSplitAssets)];
	NSValue* selCommandD = [NSValue valueWithPointer:@selector(loadSplitAssets)];
	_arr_BreadCrumbOfImages = [NSMutableArray arrayWithObjects:selCommandA, selCommandB, selCommandC, selCommandD, nil ];
	
    // when opening the splitview - hide unwanted chrome
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideBackButton) name:@"hideDetailChrome" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(unhideBackButton) name:@"unhideDetailChrome" object:nil];
    
    // debug
   // [[NSUserDefaults standardUserDefaults] setPersistentDomain:[NSDictionary dictionary] forName:[[NSBundle mainBundle] bundleIdentifier]];
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
	_uis_zoomingImg.tag = 1100;

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

#pragma mark - buttons for splitting view
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
	
	[_uiv_tapSquare addSubview:uiv_tapCircle];
	
	UITapGestureRecognizer *tapOnImg = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(filmToSplitBuilding)];
    [_uiv_tapSquare addGestureRecognizer: tapOnImg];

	[self pulse:uiv_tapCircle.layer];
}

#pragma mark - Company Logo Buttons
-(void)initCompanyLogoBtns
{
    [self initIBTButton];
    
    _uib_CompanyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
	
#ifdef NEODEMO
	_uib_CompanyBtn.frame = CGRectMake(565.0, 245.0, 40, 40);
	_uib_CompanyBtn.layer.cornerRadius = _uib_CompanyBtn.frame.size.width/2;
	
#else
	_uib_CompanyBtn.frame = CGRectMake(469.0, 180.0, 87, 55);
	
	allCompanies = [[LibraryAPI sharedInstance] getCompanies];

	for (int i = 0; i < [allCompanies count]; i++) {
		NSDictionary *hotspotItem = allCompanies[i];
		
		//Get the position of Hs
		NSString *str_position = [[NSString alloc] initWithString:[hotspotItem objectForKey:@"xy"]];
		NSRange range = [str_position rangeOfString:@","];
		NSString *str_x = [str_position substringWithRange:NSMakeRange(0, range.location)];
		NSString *str_y = [str_position substringFromIndex:(range.location + 1)];
		float hs_x = [str_x floatValue];
		float hs_y = [str_y floatValue];
		
		CGFloat staticWidth     = 89;   // Static Width for all Buttons.
		CGFloat staticHeight    = 56;   // Static Height for all buttons.
		

		UIButton *settButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[settButton setTag:i];
		[settButton setFrame:CGRectMake(hs_x, hs_y, staticWidth, staticHeight)];
		[settButton setImage:[UIImage imageNamed:[hotspotItem objectForKey:@"background"]] forState:UIControlStateNormal];
        
        [settButton addTarget:self action:@selector(logoButtonAction:) forControlEvents:UIControlEventTouchDown];
        
		[arr_CompanyLogos addObject:settButton];
		[_uis_zoomingImg.blurView addSubview:settButton];
			
        // add drag listener
        //[settButton addTarget:self action:@selector(wasDragged:withEvent:) forControlEvents:UIControlEventTouchDragInside];
	}
#endif
}

- (void)wasDragged:(UIButton *)button withEvent:(UIEvent *)event
{
	// get the touch
	UITouch *touch = [[event touchesForView:button] anyObject];
	
	// get delta
	CGPoint previousLocation = [touch previousLocationInView:button];
	CGPoint location = [touch locationInView:button];
	CGFloat delta_x = location.x - previousLocation.x;
	CGFloat delta_y = location.y - previousLocation.y;
	
	// move button
	button.center = CGPointMake(button.center.x + delta_x,
        button.center.y + delta_y);
	
	//NSLog(@"%@",NSStringFromCGPoint(button.center));
    
//    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"New XY"
//                                                      message:NSStringFromCGRect(button.frame)
//                                                     delegate:nil
//                                            cancelButtonTitle:@"OK"
//                                            otherButtonTitles:nil];
//    [message show];
}

#pragma mark - IBT Button
-(void)initIBTButton
{
    if (_uib_ibtBtn) {
        [_uib_ibtBtn removeFromSuperview];
    }
    _uib_ibtBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _uib_ibtBtn.frame = CGRectMake(1024-120-16, 16, 119, 55);
    [_uib_ibtBtn setImage: [UIImage imageNamed:@"logo-utc.png"] forState:UIControlStateNormal];
    [_uib_ibtBtn setImage: [UIImage imageNamed:@"logo-utc.png"] forState:UIControlStateSelected];
    [_uib_ibtBtn addTarget: self action:@selector(loadIBT:) forControlEvents:UIControlEventTouchUpInside];
    [_uis_zoomingImg.blurView addSubview: _uib_ibtBtn];
}

#pragma mark Open Modal
-(void)loadIBT:(id)sender
{
    if (kshowNSLogBOOL) NSLog(@"loadIBT function");
    NSDictionary *userInfo;
        
    if ([[selectedCoDict valueForKey:@"fileName"] isEqualToString:@"Otis"] || [[selectedCoDict valueForKey:@"fileName"] isEqualToString:@"奥的斯"])
    {
        userInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:6] forKey:@"buttontag"];
        if (kshowNSLogBOOL) NSLog(@"Otis");
    }
    else if ([[selectedCoDict valueForKey:@"fileName"] isEqualToString:@"Lenel"])
    {
        userInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:5] forKey:@"buttontag"];
        if (kshowNSLogBOOL) NSLog(@"Lenel");
    }
    else if ([[selectedCoDict valueForKey:@"fileName"] isEqualToString:@"Interlogix"])
    {
        userInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:4] forKey:@"buttontag"];
        if (kshowNSLogBOOL) NSLog(@"Interlogix");
    }
    else if ([[selectedCoDict valueForKey:@"fileName"] isEqualToString:@"Edwards"] || [[selectedCoDict valueForKey:@"fileName"] isEqualToString:@"爱德华"])
    {
        userInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:3] forKey:@"buttontag"];
        if (kshowNSLogBOOL) NSLog(@"Edwards");
    }
    else if ([[selectedCoDict valueForKey:@"fileName"] isEqualToString:@"Carrier"] || [[selectedCoDict valueForKey:@"fileName"] isEqualToString:@"开利"])
    {
        userInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:2] forKey:@"buttontag"];
        if (kshowNSLogBOOL) NSLog(@"Carrier");
    }
    else if ([[selectedCoDict valueForKey:@"fileName"] isEqualToString:@"Automated Logic"])
    {
        userInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:1] forKey:@"buttontag"];
        if (kshowNSLogBOOL) NSLog(@"Automated Logic");
    }
    
    // clear dict so ibt loads to the home creen
    if (sender == _uib_ibtBtn) {
        userInfo = nil;
    }
    
    NSString *notificationName = @"applicationFullScreen";
    NSString *key = @"fullScreen";
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithObject:[NSNumber numberWithBool:0] forKey:key];
    [dictionary setObject:[NSNumber numberWithInt:0] forKey:@"buttontag"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil userInfo:dictionary];

    [[NSNotificationCenter defaultCenter] postNotificationName:@"showIBT" object:self userInfo:userInfo];

}

-(void)loadSustainability
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"showSustainability" object:self userInfo:nil];
}

-(void)loadModalVC
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"showModalVC" object:self userInfo:nil];
}


#pragma mark - Actions to play path to hero and split hero
-(void)filmToSplitBuilding
{
    [self loadMovieNamed:@"02_TRANS_BLDG_UNBUILD.mov" isTapToPauseEnabled:NO belowSubview:nil withOverlay:nil];
	[_uiv_tapSquare removeFromSuperview];
	[self loadSplitAssets];
}

-(void)filmTransitionToHotspots
{
	 _uib_logoBtn.hidden = YES;
	
	NSString *movieNamed;
	NSString *movieNamedImg;

	movieNamed =  [selectedCoDict objectForKey:@"transitionFilm"];
	movieNamedImg = [selectedCoDict objectForKey:@"transitionFilmImg"];
	
	[self loadMovieNamed:movieNamed isTapToPauseEnabled:NO belowSubview:nil withOverlay:nil];
	[self updateStillFrameUnderFilm:movieNamedImg];
	
	[self createHotspots];
}

-(void)loadHotspots
{
	_uib_logoBtn.hidden = YES;
	[self createHotspots];
	[self initTitleBox];
}

-(void)loadSplitAssets
{
	if (kshowNSLogBOOL) NSLog(@"loadSplitAssets");
	
#warning added to fix comingback from sub hotspots view
	if	( _uis_zoomingImg.alpha == 0.0 )
	{
		_uis_zoomingImg.alpha = 1.0;
		[_uis_zoomingImg.scrollView setZoomScale:1.0];
		[self removeMovieLayers];
        
	}
// end warning
	
	[topTitle removeHotspotTitle];
	[topTitle removeCompanyTitle];
	
#ifdef NEODEMO
	[self updateStillFrameUnderFilm:@"03A Building Cut DEMO.png"];
#else
	[self updateStillFrameUnderFilm:@"03A Building Cut.png"];
#endif
	
	[self initCompanyLogoBtns];
    
    [self rePopMenu];
    
	[_uis_zoomingInfoImg removeFromSuperview];
	
	[self removeHotspots];
	[_arr_hotspotsArray removeAllObjects];
		
	[_uib_backBtn setTag:1];
}

-(void)rePopMenu
{
    if (arr_SelectedRows.count != 0 ) {
        if ([selectedCo.coname isEqualToString:@"Otis"]) {
            [self showPopover:uib_logoTapped];
        } else if ([selectedCo.coname isEqualToString:@"Carrier"]) {
            [self showPopover:uib_logoTapped];
        } else if ([selectedCo.coname isEqualToString:@"Automated Logic"]) {
            [self showPopover:uib_logoTapped];
        }
    }
}

#pragma mark - menu button
-(void)createBackButton
{
	if (kshowNSLogBOOL) NSLog(@"createBackButton");
	_uib_backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
	_uib_backBtn.frame = CGRectMake(backButtonX, 0.0, 58, backButtonHeight);
	[_uib_backBtn setImage:[UIImage imageNamed:@"icon back.png"] forState:UIControlStateNormal];
	[self.view addSubview:_uib_backBtn];
	[_uib_backBtn addTarget:self action:@selector(performSelectorFromArray) forControlEvents:UIControlEventTouchUpInside];
	_uib_backBtn.layer.zPosition = MAXFLOAT;
	[_uib_backBtn setTag:0];
}

#pragma mark notification methods
-(void)hideBackButton
{
	if (kshowNSLogBOOL) NSLog(@"hideBackButton");
	self.uib_backBtn.hidden = YES;
	self.uib_backBtn.transform = CGAffineTransformMakeTranslation(-backButtonWidth*2, 0);
	[topTitle.uil_Company setHidden:YES];
}

-(void)unhideBackButton
{
	if (kshowNSLogBOOL) NSLog(@"==unhideBackButton");
	self.uib_backBtn.hidden = NO;
	self.uib_backBtn.transform = CGAffineTransformIdentity;
	[topTitle.uil_Company setHidden:NO];
}

#pragma mark back button breadcrumb fuction
-(void)performSelectorFromArray
{
	if (kshowNSLogBOOL) NSLog(@"performSelectorFromArray");
	NSValue *val = _arr_BreadCrumbOfImages[_uib_backBtn.tag];
	SEL mySelector = [val pointerValue];
	//	[self performSelector:mySelector];
	IMP imp = [self methodForSelector:mySelector];
	void (*func)(id, SEL) = (void *)imp;
	func(self, mySelector);
	
	NSLog(@"_uib_back %li",(long)_uib_backBtn.tag);
}

#pragma mark handle backbutton being tapped as needed
-(void)reloadBuildingVC
{
	//NSLog(@"should be tag 0");

	[[NSNotificationCenter defaultCenter] postNotificationName:@"loadBuilding" object:nil];
    [_uib_ibtBtn removeFromSuperview];
	[_uib_backBtn setTag:0];
	if (kshowNSLogBOOL) NSLog(@"_uib_back %li",(long)_uib_backBtn.tag);
}

-(void)reloadHero
{
	if (kshowNSLogBOOL) NSLog(@"should be tag 1");

	[self removeHotspots];
    [_uib_ibtBtn removeFromSuperview];
    
	if (_avPlayerLayer) {
        [self closeMovie];
    }
	
	[_hotspotImageView removeFromSuperview];
	[self removeCompanyLogos];
	
	[self updateStillFrameUnderFilm:@"02_HERO_BLDG.png"];
	[_uib_backBtn setTag:0];
	if (kshowNSLogBOOL) NSLog(@"_uib_back %li",(long)_uib_backBtn.tag);
	
	[self initSplitOpenBtn];

}


#pragma mark - Info Labels
#pragma mark init top left text box
-(void)initTitleBox
{

#ifdef NEODEMO
	topname = @"Elevator";
#else
	selectedCo = [[LibraryAPI sharedInstance] getSelectedCompanyData];
	topname = selectedCo.coname;
#endif
	
	if (topTitle)
	{
		[topTitle removeFromSuperview];
		topTitle=nil;
	}
	
	topTitle = [[embTitle alloc] initWithFrame:CGRectZero withText:topname startX:36 width:58];
   // [topTitle setBackButtonWidth:58];
   // [topTitle setBackButtonX:36];
	[self.view addSubview:topTitle];
    [topTitle setHotSpotTitle:topname];
}

#pragma mark - company hotspots
-(void)createHotspots
{
	[self removeHotspots];
	
	[_arr_hotspotsArray removeAllObjects];
    _arr_hotspotsArray = nil;
    _arr_hotspotsArray = [[NSMutableArray alloc] init];
	
	[self loadCompanyHotspots];
    
}

// load the hotpots of the company selected
-(void)loadCompanyHotspots
{
	[self removeHotspots];

	[_uib_backBtn setTag:2];

	// get array of all hotspots
	selectedCo = [[LibraryAPI sharedInstance] getSelectedCompanyData];
    NSArray *totalDataArray = _arr_subHotspots;
	//NSLog(@"%@",selectedCo.cohotspots);
    
   
    for (int i = 0; i < [totalDataArray count]; i++)
    {
        NSDictionary *hotspot_raw = [[NSDictionary alloc] initWithDictionary:totalDataArray[i]];
        _myHotspots = [[neoHotspotsView alloc] initWithHotspotInfo:hotspot_raw];
        int num_Alignment = [[hotspot_raw objectForKey:@"alignment"] intValue];
        _myHotspots.labelAlignment = num_Alignment;
        //hotspot2.labelAlignment = i;
        _myHotspots.tag = i;
        _myHotspots.delegate = self;
        _myHotspots.showArrow = YES;
        [_arr_hotspotsArray addObject: _myHotspots];
        [_uis_zoomingImg.blurView addSubview: _myHotspots];
    }
    

	
    /*
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
     */
}

// load the hotpots of the company selected
-(void)loadCompanySubHotspots:(NSArray*)arrayOfSubHotspots
{
	[self removeHotspots];
	
	[_uib_backBtn setTag:3];
	
	// get array of all hotspots
	//selectedCo = [[LibraryAPI sharedInstance] getSelectedCompanyData];
	NSArray *totalDataArray = arrayOfSubHotspots;
	//NSLog(@"%@",selectedCo.cohotspots);
    
    for (int i = 0; i < [totalDataArray count]; i++)
    {
        NSDictionary *hotspot_raw = [[NSDictionary alloc] initWithDictionary:totalDataArray[i]];
        _myHotspots = [[neoHotspotsView alloc] initWithHotspotInfo:hotspot_raw];
        int num_Alignment = [[hotspot_raw objectForKey:@"alignment"] intValue];
        _myHotspots.labelAlignment = num_Alignment;

        //hotspot2.labelAlignment = i;
        _myHotspots.tag = i + 100;
        _myHotspots.delegate = self;
        _myHotspots.showArrow = YES;
        [_arr_hotspotsArray addObject: _myHotspots];
        [_uis_zoomingInfoImg.blurView addSubview: _myHotspots];
    }
	
    /*
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
		
		_myHotspots.tagOfHs = i + 100;
		[_uis_zoomingInfoImg.blurView addSubview:_myHotspots];
	}
     */
}

-(void)logoButtonAction:(id)sender
{
    NSDictionary *co = allCompanies[[sender tag]];
    selectedCoDict = [[LibraryAPI sharedInstance] getSelectedCompanyNamed:[co objectForKey:@"fileName"]] [0];
    selectedCo = [[LibraryAPI sharedInstance] getSelectedCompanyData];
    NSLog(@"logoButtonAction: %@",selectedCo.coname);
    
    uib_logoTapped = sender;
    
    if ( [selectedCo.coname isEqualToString:@"Intelligent Building Technologies"] )
    {
        [self loadIBT:nil];
        
    } else if ( [selectedCo.coname isEqualToString:@"Sustainability"] ) {
        
        [self loadSustainability];
        
    } else if ( [selectedCo.coname isEqualToString:@"AdvanTE3C"] ) {
        
        [self loadModalVC];
   
    } else if ( [selectedCo.coname isEqualToString:@"Kidde"] ) {
        
        [self selectedRow:0 withText:nil];
        
    } else if ( [selectedCo.coname isEqualToString:@"Taylor"] ) {
        
        [self selectedRow:0 withText:nil];
        
    } else if ( [selectedCo.coname isEqualToString:@"Onity"] ) {
        
        [self selectedRow:0 withText:nil];
        
    } else {
        
        [self showPopover:uib_logoTapped];
        
    }
}

//----------------------------------------------------
#pragma mark - POPOVER
//----------------------------------------------------
/*
 popover when needed from company logos
 */
- (IBAction)showPopover:(UIButton *)sender
{
    
    // get company tapped on from data model
	NSDictionary *co = allCompanies[sender.tag];
	selectedCoDict = [[LibraryAPI sharedInstance] getSelectedCompanyNamed:[co objectForKey:@"fileName"]] [0];
    
    //NSLog(@"%lu",[sender tag]);
    
	PopoverViewController *PopoverView =[[PopoverViewController alloc] initWithNibName:@"PopoverViewController" bundle:nil];
	self.popOver =[[UIPopoverController alloc] initWithContentViewController:PopoverView];
    self.popOver.delegate = self;
	PopoverView.delegate = self;
	
    if (([sender tag] == 4) || ([sender tag] == 6)) {
        [self.popOver presentPopoverFromRect:sender.frame inView:_uis_zoomingImg.blurView permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];

    } else {
        
        [self.popOver presentPopoverFromRect:sender.frame inView:_uis_zoomingImg.blurView permittedArrowDirections:UIPopoverArrowDirectionLeft | UIPopoverArrowDirectionRight animated:YES];

    }
}

#pragma mark Popover Delegate method
-(void)selectedRow:(NSInteger)row withText:(NSString*)text
{
    selctedRow = row;
    
    if (text != nil) {
        [arr_SelectedRows addObject:[NSNumber numberWithInteger:row]];
        [[NSUserDefaults standardUserDefaults] setObject:arr_SelectedRows forKey:@"com.neoscape.SelectedRows"];
    }
    
    if (kshowNSLogBOOL) NSLog(@"text %@",text);
    
    [self.popOver dismissPopoverAnimated:YES];
    self.popOver = nil;

    selectedCo = [[LibraryAPI sharedInstance] getSelectedCompanyData];
    
	if ( [text isEqualToString:@"Intelligent Building Technologies"] || [text isEqualToString:@"智能建筑技术"])
	{
        
        [self loadIBT:nil];
        
//    } else if ( [selectedCo.coname isEqualToString:@"Sustainability"] ) {
//        
//        [self loadSustainability];
//        
//    } else if ( [selectedCo.coname isEqualToString:@"AdvanTE3C"] ) {
//        
//        [self loadModalVC];

	} else {
    
		NSDictionary *catDict = [selectedCo.cocategories objectAtIndex:selctedRow];
		NSString *categoryType = [catDict objectForKey:@"catType"];
		NSString *categoryName = [catDict objectForKey:@"catName"];
		NSString *subBG = [catDict objectForKey:@"subBG"];
		_arr_subHotspots = [catDict objectForKey:@"subhotspots"];
		
		NSLog(@"selectedRow subhotspots %@",_arr_subHotspots);
		
		if ([categoryType isEqualToString:@"film"]) {
			// get which company from data model
			[self cleanupBeforeLoadingFlyin];
			[self initTitleBox];
			[topTitle setHotSpotTitle:categoryName];
			
		} else if ([categoryType isEqualToString:@"filmWithCards"]) {
			//TODO: connect to data
            
            NSDictionary *co_dict = _arr_subHotspots[0];
            NSString *subBG = [co_dict objectForKey:@"background"];
            NSLog(@"subBG = %@", subBG);
            
			//[self popUpImage:subBG withCloseButton:YES];
			[self initTitleBox];
			[topTitle setHotSpotTitle:categoryName];
        
            [self animateTitleAndHotspot:TitleLabelsOffscreen];

             NSString *mov = [co_dict objectForKey:@"fileName"];
            [self loadMovieNamed:mov isTapToPauseEnabled:YES belowSubview:_uib_backBtn withOverlay:nil];
            
        } else if ([categoryType isEqualToString:@"stillWithMenu"]) {
			
			[self initTitleBox];
			[topTitle setHotSpotTitle:categoryName];
			
			[self popUpImage:subBG withCloseButton:NO];
			
			
			[self loadCompanySubHotspots:_arr_subHotspots];
			
			/*
			 
			 1. √ get hotspots for subcategory
			 2. load bg image to new alloc'd uiscrollview
			 3. inside of that view have the hotspots load card arrays based on taps
			 4. inside of that view append the hotspot title with the subcategory
			 
			 */
			
		}
        
        [_uib_ibtBtn removeFromSuperview];

	}
}

/* Called on the delegate when the popover controller will dismiss the popover. Return NO to prevent the dismissal of the view.
 */
- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController
{
    NSLog(@"shoulddismiss");
    return YES;
}

/* Called on the delegate when the user has taken action to dismiss the popover. This is not called when -dismissPopoverAnimated: is called directly.
 */

-(void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    NSLog(@"diddismiss");
    [arr_SelectedRows removeAllObjects];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"com.neoscape.SelectedRows"];
}

// load all the companies onto the view
-(void)cleanupBeforeLoadingFlyin
{
	[_hotspotImageView removeFromSuperview];
	
	for (UIButton *btn in arr_CompanyLogos) {
		[btn removeFromSuperview];
	}
	
	[self removeCompanyLogos];
	
	//SAFETY
	if ([selectedCoDict objectForKey:@"transitionFilm"]) {
		[self filmTransitionToHotspots];
	}
}

#pragma mark - HOTSPOTS
#pragma mark hotspot tapped Delegate Method

- (void)neoHotspotsView:(neoHotspotsView *)hotspot didSelectItemAtIndex:(NSInteger)index

//-(void)neoHotspotsView:(neoHotspotsView *)hotspot withTag:(int)i
{
	
	if (kshowNSLogBOOL) NSLog(@"neoHotspotsView");
	
	BOOL isSubHotspots;
	
	int formattedTag = 0;
    
    NSLog(@"%li",(long)index);
	
	if (index > 99) {
		formattedTag = index - 100;
		isSubHotspots = YES;
	} else {
		formattedTag = index;
		isSubHotspots = NO;
	}
    
    NSLog(@"%li",(long)formattedTag);

	
	tappedView = _arr_hotspotsArray[formattedTag];
	tappedView.tag = formattedTag;
	tappedView.alpha = 0.75;
	[tappedView setLabelAlpha:0.75];
    
    if ([tappedView.contentType isEqualToString:@"movie"]) {
        
        _coDict = [_arr_subHotspots objectAtIndex:formattedTag];
        NSString *movieNamed =  [_coDict objectForKey:@"fileName"];
        
        NSLog(@"movie %@",movieNamed);

        NSDictionary *cod = _arr_subHotspots[formattedTag];
        NSString *imageNameName;
        
        if ([cod objectForKey:@"overlay"]) {
            imageNameName = [cod objectForKey:@"overlay"];
        }

        if (index > 99) {
            [self loadMovieNamed:movieNamed isTapToPauseEnabled:YES belowSubview:_uib_backBtn withOverlay:imageNameName];
        } else {
            [self loadMovieNamed:movieNamed isTapToPauseEnabled:YES belowSubview:_uis_zoomingImg withOverlay:nil];
        }
    }
		
    [self zoomTowardsPointFrom:tappedView];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        if(isSubHotspots==YES)
        {
            [topTitle appendHotSpotTitle:tappedView.captionText];

        } else {
            [topTitle appendHotSpotTitle:tappedView.captionText];

        }
        
    });
}

#pragma mark transition methods
-(void)zoomTowardsPointFrom:(UIView*)view
{
	//zoom towards the point tapped
	[_uis_zoomingImg zoomToPoint:CGPointMake(tappedView.center.x, tappedView.center.y) withScale:1.5 animated:YES];
    _uis_zoomingImg.alpha = 0.0;
    
    // needs a delay so it can be APPENDED before moving
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.33 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self animateTitleAndHotspot:TitleLabelsOffscreen];
    });
}

-(void)animateTitleAndHotspot:(NSInteger)d
{
	[UIView animateWithDuration:0.5 animations:^{
        
        if (d == TitleLabelsOffscreen) {
            topTitle.uil_Company.frame = CGRectMake(-87, topTitle.uil_Company.frame.origin.y, topTitle.uil_Company.frame.size.width, topTitle.uil_Company.frame.size.height);
            topTitle.uil_HotspotTitle.frame = CGRectMake(topTitle.uil_Company.frame.size.width-87, topTitle.uil_HotspotTitle.frame.origin.y, topTitle.uil_HotspotTitle.frame.size.width, topTitle.uil_HotspotTitle.frame.size.height);
            _uib_backBtn.transform = CGAffineTransformMakeTranslation(-backButtonWidth*2, 0);
            [[NSNotificationCenter defaultCenter] postNotificationName:@"moveSplitBtnLeft" object:nil];
            
        } else if (d == TitleLabelsOnscreen) {
            topTitle.uil_Company.frame = CGRectMake(0, topTitle.uil_Company.frame.origin.y, topTitle.uil_Company.frame.size.width, topTitle.uil_Company.frame.size.height);
            _uib_backBtn.transform = CGAffineTransformIdentity;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"moveSplitBtnRight" object:nil];
        }
		
	} completion:^(BOOL completed) {    } ];
}

#pragma mark hotspot actions
-(void)popUpImage:(NSString*)imageName withCloseButton:(BOOL)closeBtn
{
	if (_uis_zoomingInfoImg) {
		[_uis_zoomingInfoImg removeFromSuperview];
		_uis_zoomingInfoImg = nil;
	}
	_uis_zoomingInfoImg = [[ebZoomingScrollView alloc] initWithFrame:CGRectMake(0.0, 0.0, 1024, 768) image:[UIImage imageNamed:imageName] shouldZoom:YES];
	[_uis_zoomingInfoImg setCloseBtn:closeBtn];
	_uis_zoomingInfoImg.tag = 2100;
	_uis_zoomingInfoImg.delegate = self;
		
	[self.view insertSubview:_uis_zoomingInfoImg belowSubview:_uib_backBtn];
}

-(void)closeSubHotspots
{
    NSLog(@"close subhotspots");
    [_uib_backBtn setTag:1];
	[_uis_zoomingInfoImg removeFromSuperview];
}

#pragma mark ebzooming delegate
-(void)scrollViewDidRemove:(ebZoomingScrollView *)ebZoomingScrollView {

    if (kshowNSLogBOOL) NSLog(@"zoomingScroll.tg = %li", (long)ebZoomingScrollView.tag);
    
    // standard interface view
	if (ebZoomingScrollView.tag == 1100) {
		[_uis_zoomingInfoImg bringSubviewToFront:_uis_zoomingImg];
		[_uis_zoomingImg.scrollView setZoomScale:1.0];
		
		// hotspot cleanup
		[topTitle removeHotspotTitle];
		[topTitle removeCompanyTitle];
		
		//TODO : Confirm if this fixes my bug
        // clean up last tapped view
		// we don't need it anymore
        //tappedView=nil;
		
		[self unhideChrome];
		
		[UIView animateWithDuration:0.5 animations:^{
			_uis_zoomingImg.alpha = 1.0;
		} completion:^(BOOL completed) {
			[_uis_zoomingInfoImg removeFromSuperview];
			_uis_zoomingInfoImg = nil;
		}];

	} else {
		if (kshowNSLogBOOL) // subhotspot  view
		NSLog(@"subhotspot");
		[UIView animateWithDuration:0.5 animations:^{
			_uis_zoomingInfoImg.alpha = 0.0;
			_uis_zoomingImg.alpha = 1.0;
		} completion:^(BOOL completed) {
			[_uis_zoomingInfoImg removeFromSuperview];
			_uis_zoomingInfoImg = nil;
		}];
		[topTitle removeHotspotTitle];
		[topTitle removeCompanyTitle];
		[self unhideChrome];
	}
	
	if (kshowNSLogBOOL) NSLog(@"scrollViewDidRemove");
}

#pragma mark - UTILITIES : General

#pragma mark unhide Chrome
-(void)unhideChrome
{
    [UIView animateWithDuration:0.33 animations:^{
        _uib_backBtn.transform = CGAffineTransformIdentity;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"moveSplitBtnRight" object:nil];
    } completion:^(BOOL completed) {
        
    }];
}


#pragma mark Remove Company Logos
-(void)removeCompanyLogos
{
	for (UIButton *btn in arr_CompanyLogos) {
		[btn removeFromSuperview];
	}
}

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

#pragma mark - MOVIE
-(void)loadMovieNamed:(NSString*)moviename isTapToPauseEnabled:(BOOL)tapToPauseEnabled belowSubview:(UIView*)belowSubview withOverlay:(NSString*)overlay
{
	
	NSString* fileName = [moviename stringByDeletingPathExtension];
	NSString* extension = [moviename pathExtension];
	
	NSString *url = [[NSBundle mainBundle] pathForResource:fileName
                                                    ofType:extension];
    
	if (tapToPauseEnabled == YES) {
		if (kshowNSLogBOOL) NSLog(@"tapToPauseEnabled == YES");
		_isPauseable = YES;
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
	[_uiv_movieContainer setBackgroundColor:[UIColor blackColor]];
	
     
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
		UIImage *image = [UIImage flipImage:[UIImage imageNamed:imageNameFromMovieName]];
		
		_avPlayerLayer.backgroundColor = [UIColor colorWithPatternImage:image].CGColor;
	} else {
		_avPlayerLayer.backgroundColor = [UIColor blackColor].CGColor;
	}
	
    [_uiv_movieContainer.layer addSublayer: _avPlayerLayer];
	
	[_avPlayer play];
	
	//NSDictionary *cod = _arr_subHotspots[tag]
	
    if (overlay) {
        NSString *imageNameName = overlay;
        UIImage *imagee = [UIImage imageNamed:imageNameName];
        UIImageView *imgv = [[UIImageView alloc ] initWithImage:imagee];
        imgv.frame = self.view.bounds;
        [_uiv_movieContainer addSubview:imgv];
    }
	
	if (tapToPauseEnabled) {
		if (kshowNSLogBOOL) NSLog(@"loadMovieNamed beginSequence");
		[self beginSequence];
	}
	
	//NSString *movieNamed =  [selectedCoDict objectForKey:@"transitionFilm"];
	NSString *movieNamedImg = [selectedCoDict objectForKey:@"transitionFilmImg"];
	
	[self updateStillFrameUnderFilm:movieNamedImg];

	//[self updateStillFrameUnderFilm:@"04_HOTSPOT_CROSS_SECTION.png"];
	
	NSString *selectorAfterMovieFinished;
	
	if (tapToPauseEnabled == YES) {
		[self addMovieGestures];
		//[self loadControlsLabels];
		selectorAfterMovieFinished = @"playerItemLoop:";
		
		UIButton *h = [UIButton buttonWithType:UIButtonTypeCustom];
		h.frame = CGRectMake(1024-44, 0, 44, 43);
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
	
	UITapGestureRecognizer *doubleTapMovie = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeMovie)];
	doubleTapMovie.numberOfTapsRequired = 2;
    doubleTapMovie.cancelsTouchesInView = NO;
	[self.view addGestureRecognizer:doubleTapMovie];

}

-(void)addMovieGestures
{
	UITapGestureRecognizer *tappedMovie = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedMovie:)];
    [self.view addGestureRecognizer: tappedMovie];
	
	UISwipeGestureRecognizer *swipeUpRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeUpPlay:)];
	[swipeUpRecognizer setDirection:(UISwipeGestureRecognizerDirectionUp)];
	[swipeUpRecognizer setDelegate:self];
	[self.view addGestureRecognizer:swipeUpRecognizer];
	
	UISwipeGestureRecognizer *swipeDownRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeDownPause:)];
	[swipeDownRecognizer setDirection:(UISwipeGestureRecognizerDirectionDown)];
	[swipeDownRecognizer setDelegate:self];
	[self.view addGestureRecognizer:swipeDownRecognizer];
}

- (void)playerItemDidReachEnd:(NSNotification *)notification {
	if (kshowNSLogBOOL) NSLog(@"playerItemDidReachEnd");
    
	[self closeMovie];
}

-(void)playerItemLoop:(NSNotification *)notification
{
	AVPlayerItem *p = [notification object];
	[p seekToTime:kCMTimeZero];
	[_avPlayer play];
	
	// starts the player as well
	if (kshowNSLogBOOL) NSLog(@"playerItemLoop beginSequence");
	[self beginSequence];
    
    hotspotHasLooped = YES;
}

#pragma mark control(s) for movie

-(void)loadControlsLabels
{
	if (kshowNSLogBOOL) NSLog(@"load loadcontrollabel");
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

#pragma mark close movie

-(void)closeMovie
{
    hotspotHasLooped = NO;
    
    [self clearHotpsotData];
    
    if (kshowNSLogBOOL) NSLog(@"closeMovie");
    CGAffineTransform t = _uib_backBtn.transform;
    
    NSDictionary *catDict = [selectedCo.cocategories objectAtIndex:selctedRow];
    NSString *categoryType = [catDict objectForKey:@"catType"];
    if ([categoryType isEqualToString:@"filmWithCards"]) {
         if (kshowNSLogBOOL) NSLog(@"closeMovie filmWithCards");
        
        [self initIBTButton];
        
        [self updateStillFrameUnderFilm:@"03A Building Cut.png"];
        
        [self rePopMenu];

        [topTitle removeFromSuperview];
        
        if (t.tx < 0) {
            [self animateTitleAndHotspot:TitleLabelsOnscreen];
        }
        
        [[NSNotificationCenter defaultCenter] removeObserver:self];

        if (_myTimer) {
            [self.myTimer invalidate];
            self.myTimer = nil;
        }
        
        if (_uis_zoomingInfoImg !=nil) {
            [self resetSubHotspot];
        } else {
            [self resetBaseInteractive];
        }
        
        [[NSNotificationCenter defaultCenter] removeObserver:self];

        
    } else {
        
        if (kshowNSLogBOOL)  NSLog(@"xscale %f",t.tx);
        
        if (t.tx < 0) {
            [self animateTitleAndHotspot:TitleLabelsOnscreen];
        }
        
        if (_myTimer) {
            [self.myTimer invalidate];
            self.myTimer = nil;
        }
        
        if (_uis_zoomingInfoImg !=nil) {
            [self resetSubHotspot];
        } else {
            [self resetBaseInteractive];
        }
        
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        
        if (kshowNSLogBOOL) NSLog(@"_arr_subHotspots %lu",(unsigned long)[_arr_subHotspots count]);
        
        if (_isPauseable == YES) {
            [self unhideChrome];
            //#warning might be trouble once movies are added
            //		if ([_arr_subHotspots count] == 0) {
            //
            //            NSLog(@"if ([_arr_subHotspots count] == 0) {");
            //
            //			//[topTitle removeHotspotTitle];
            //			if (topTitle.appendString) {
            //				if (kshowNSLogBOOL) NSLog(@"topTitle.appendString %@",topTitle.appendString);
            //				[topTitle setHotSpotTitle:topTitle.appendString];
            //			}
            //		} else {
            NSLog(@"\n\nelse");
            NSLog(@"\n\n%@",topTitle.appendString);
            //_arr_subHotspots=nil;
            
            
            if (topTitle.appendString) {
                [topTitle setHotSpotTitle:topTitle.appendString];
            }
            //		}
        }
        
    }
    
#warning I think this solved the crashing bug. It resets the tappedview tag used for -(void)createCardsInView. Needs to be 0 to reset
    tappedView.tag = 0;
}

-(void)resetBaseInteractive
{
	if (kshowNSLogBOOL) NSLog(@"resetBaseInteractive");
	
	[_uis_zoomingImg bringSubviewToFront:_uis_zoomingInfoImg];
	[_uis_zoomingImg.scrollView setZoomScale:1.0];
	
	[UIView animateWithDuration:0.3 animations:^{
		_uis_zoomingImg.alpha = 1.0;
		
	} completion:^(BOOL completed) {
		[self removeMovieLayers];
	}];
    

}

-(void)resetSubHotspot
{
	if (kshowNSLogBOOL) NSLog(@"resetSubHotspot");
	
	[_uis_zoomingImg bringSubviewToFront:_uis_zoomingInfoImg];
	[_uis_zoomingImg.scrollView setZoomScale:1.0];
	
	[UIView animateWithDuration:0.3 animations:^{
		_uis_zoomingImg.alpha = 1.0;
		
	} completion:^(BOOL completed) {
		[self removeMovieLayers];
	}];
}

-(void)removeMovieLayers
{
	[_avPlayerLayer removeFromSuperlayer];
	_avPlayerLayer = nil;
	[_uiv_movieContainer removeFromSuperview];
	_uiv_movieContainer=nil;
}

//----------------------------------------------------
#pragma mark - FACT CARDS
//----------------------------------------------------
/*
 start all info cards and movie in motion
 */
-(void)beginSequence
{

	[self startMovieTimer];
    
    // ONLY PLAY CARDS IF DICT EXISTS FOR CARDS
    NSDictionary *hotspotItem = _arr_subHotspots [0];
    if ([hotspotItem objectForKey:@"facts"]) {
        NSLog(@"NO subhotspots - SO DON'T PLAY FILM");
        [self createCardsInView:_uiv_movieContainer];
    }
}

//----------------------------------------------------
#pragma mark info cards
//----------------------------------------------------
/*
 create info cards from model
 */
-(void)createCardsInView:(UIView*)view
{
    if (kshowNSLogBOOL) NSLog(@"createCards");
    
    uiv_HotspotInfoCardContainer = [[UIView alloc] initWithFrame:CGRectZero];
	uiv_HotspotInfoCardContainer.layer.backgroundColor = [UIColor clearColor].CGColor;
	uiv_HotspotInfoCardContainer.clipsToBounds = YES;
	
	[view addSubview:uiv_HotspotInfoCardContainer];
	
	CGFloat textViewHeight = 0;
	
	selectedCo = [[LibraryAPI sharedInstance] getSelectedCompanyData];
    
  //TODO: check for key on hotspots
    NSArray *totalDataArray;

    //TODO: CRASH
	// causes crash sometimes
    
    totalDataArray = _arr_subHotspots;

	//NSLog(@"/ntapedtag %li",(long)tappedView.tag);
   // NSLog(@"/ntotalDataArray %@",[totalDataArray description]);
   // NSLog(@"/selectedCo.cohotspots.count %li",selectedCo.cohotspots.count);
    
    NSDictionary *hotspotItem = totalDataArray [tappedView.tag];

    
	//Get the exact second to remove the text boxes
	removeTextAfterThisManySeconds = [[hotspotItem objectForKey:@"removeafterseconds"] intValue];
    NSLog(@"building : createCardsInView : removeTextAfterThisManySeconds %f", removeTextAfterThisManySeconds);

	// grab facts dict
	NSDictionary *facts = [hotspotItem objectForKey:@"facts"];
	NSArray *hotspotText = [facts objectForKey:@"factscopy"];
	
	if (kshowNSLogBOOL) NSLog(@"%@",[hotspotText description]);

	//Get the position of Hs
	NSString *str_position = [[NSString alloc] initWithString:[facts objectForKey:@"factxy"]];
	NSRange range = [str_position rangeOfString:@","];
	NSString *str_x = [str_position substringWithRange:NSMakeRange(0, range.location)];
	NSString *str_y = [str_position substringFromIndex:(range.location + 1)];
	float hs_x = [str_x floatValue];
	float hs_y = [str_y floatValue];
	
	float factsCopy = [[facts objectForKey:@"factwidth"] floatValue];
    factWidth = [[facts objectForKey:@"factwidth"] intValue];
                 
	for (int i = 0; i < [hotspotText count]; i++) {
		NSDictionary *box = hotspotText[i];
		
		embUiViewCard *card = [[embUiViewCard alloc] init];
		[card setBackgroundColor:[[UIColor clearColor] colorWithAlphaComponent:0.5]];
		card.delay = (int)[[box objectForKey:@"appearanceDelay"] integerValue];
		card.text = [box objectForKey:@"copy"];
		NSLog(@"%@",card.text);
		
		[card setFrame:CGRectMake(0, textViewHeight, factsCopy, [self measureHeightOfUITextView:card.textView])];
		card.alpha = 0;
		[arr_HotspotInfoCards addObject:card];
		[uiv_HotspotInfoCardContainer addSubview:card];
		textViewHeight += [self measureHeightOfUITextView:card.textView];
	}
	
	// update container frame now that we know the heights
	uiv_HotspotInfoCardContainer.frame = CGRectMake(hs_x, hs_y, factsCopy, textViewHeight);
	
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
		
		//NSLog(@"%@",[card description]);
		
		
		// get index of card to know whether
		// to animate it bouncing/falling
		
		NSUInteger index = [arr_HotspotInfoCards indexOfObject:card];
		
		embUiViewCard *ccard;
		ccard =  [arr_HotspotInfoCards objectAtIndex:index];
		
		CGFloat startPointX = card.center.x;
		CGFloat startPointY = card.center.y;
		
		//NSLog(@"rect1: %f", startPointY);
		
		
		UIView *maskView = [[UIView alloc] initWithFrame:CGRectMake(card.frame.origin.x, card.frame.origin.y, 360, card.frame.size.height+20)];
		maskView.layer.backgroundColor = [UIColor clearColor].CGColor;
		maskView.clipsToBounds = YES;
		[maskView addSubview:card];
		[uiv_HotspotInfoCardContainer addSubview:maskView];
		
		NSArray *values;
		
		if (index == 0) { // no animation of falling/bouncing
			values = [NSArray arrayWithObjects:[NSValue valueWithCGPoint:CGPointMake(startPointX, startPointY)],
					  [NSValue valueWithCGPoint:CGPointMake(startPointX, startPointY)], nil];
		} else { // animation of falling/bouncing
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
		
		//NSLog(@"rect1: %@", NSStringFromCGRect(card.frame));
		
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
#pragma mark timer used for card reveals
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
	
	if (kshowNSLogBOOL) NSLog(@"== /n/nstart timer");
}


//----------------------------------------------------
#pragma mark fact card utilities
//----------------------------------------------------
#pragma mark hotspots : Clear array
-(void)clearHotpsotData
{
    [arr_HotspotInfoCards removeAllObjects];
}

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
		
		NSDictionary *attributes = @{ NSFontAttributeName: [UIFont systemFontOfSize:19], NSParagraphStyleAttributeName : paragraphStyle };
		
		CGRect size = [textToMeasure boundingRectWithSize:CGSizeMake(factWidth, MAXFLOAT)
												  options:NSStringDrawingUsesLineFragmentOrigin
											   attributes:attributes
												  context:nil];
		
		//NSLog(@"fontSize = \tbounds = (%f x %f)",
		//	  size.size.width,
		//	  size.size.height);
		
		CGFloat measuredHeight = ceilf(CGRectGetHeight(size) + topBottomPadding);
		
		//NSLog(@"measuredHeight %f)",
		//	  measuredHeight);
		
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
	if (kshowNSLogBOOL) NSLog(@"seconds %i",y);
	
//	if (y == removeTextAfterThisManySeconds) {
//		[self removeCards];
//	}
	
	// check if the seconds match the reveal delay
    if (    hotspotHasLooped != YES  ) {
        [self indexOfCardToReveal:y];
    }
}



#pragma mark - boiler plate

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
