//
//  otisViewController.m
//  xhSplitViewController
//
//  Created by Xiaohe Hu on 9/3/14.
//  Copyright (c) 2014 Neoscape. All rights reserved.
//

#import "buildingViewController.h"
#import "ebZoomingScrollView.h"
#import "IBTViewController.h"

#import <AVFoundation/AVPlayer.h>
#import <AVFoundation/AVFoundation.h>

#import "neoHotspotsView.h"
#import "PopoverViewController.h"

#import "embUiViewCard.h"
#import "NSTimer+CVPausable.h"

#import "LibraryAPI.h"
#import "Company.h"
#import "embTitle.h"

static CGFloat backButtonHeight = 51;
static CGFloat backButtonWidth	= 58;
static CGFloat backButtonX		= 36;

enum {
	LabelOnscreen,
	LabelOffscreen,
};

@interface buildingViewController () <ebZoomingScrollViewDelegate, neoHotspotsViewDelegate, PopoverViewControllerDelegate, IBTViewControllerDelegate, UIGestureRecognizerDelegate>
{
	CGFloat removeTextAfterThisManySeconds;

	NSMutableArray	*arr_HotspotInfoCards;
	UIView			*uiv_HotspotInfoCardContainer;
	neoHotspotsView *tappedView;
	float			factsCopy;
	Company			*selectedCo;
	NSDictionary	*selectedCoDict;
	NSArray			*allCompanies;
	
	NSMutableArray	*arr_CompanyLogos;
	embTitle		*topTitle;
	NSString		*topname;
    BOOL            titleOffScreen;
}

@property (nonatomic) NSTimer *myTimer;

@property (nonatomic,strong) UIPopoverController *popOver;

- (IBAction)showPopover:(UIButton *)sender;

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
@property (nonatomic, strong) UIImageView *hotspotImageView;
@property (nonatomic, strong) neoHotspotsView				*myHotspots;
@property (nonatomic, strong) NSMutableArray				*arr_hotspots;
@property (nonatomic, strong) NSDictionary                  *coDict;
@property (nonatomic) BOOL isPauseable;

@end

@implementation buildingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.frame = CGRectMake(0.0, 0.0, 1024, 768);
	
	// init arrays and create avplayer
	arr_HotspotInfoCards	= [[NSMutableArray alloc] init];
	_arr_hotspotsArray		= [[NSMutableArray alloc] init];
	_arr_BreadCrumbOfImages = [[NSMutableArray alloc] init];
	arr_CompanyLogos		= [[NSMutableArray alloc] init];
	
	// load animation that leads to the hero
	// building tapped from previous screen
	[self loadMovieNamed:_transitionClipName isTapToPauseEnabled:NO belowSubview:nil withOverlay:nil];
	// add in the bg image beneath the film
	[self createStillFrameUnderFilm];
	
	[self createBackButton];
	
	NSValue* selCommandA = [NSValue valueWithPointer:@selector(reloadBuildingVC)];
	NSValue* selCommandB = [NSValue valueWithPointer:@selector(reloadHero)];
	NSValue* selCommandC = [NSValue valueWithPointer:@selector(loadSplitAssets)];
	NSValue* selCommandD = [NSValue valueWithPointer:@selector(loadSplitAssets)];

	_arr_BreadCrumbOfImages = [NSMutableArray arrayWithObjects:selCommandA, selCommandB, selCommandC, selCommandD, nil ];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideBackButton) name:@"hideDetailChrome" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(unhideBackButton) name:@"unhideDetailChrome" object:nil];

}

-(void)initIBTButton
{
    if (_uib_ibtBtn) {
        [_uib_ibtBtn removeFromSuperview];
    }
    _uib_ibtBtn = [UIButton buttonWithType:UIButtonTypeCustom];
	_uib_ibtBtn.frame = CGRectMake(1024-89-16, 16, 89, 56);
	[_uib_ibtBtn setImage: [UIImage imageNamed:@"logo_utcibt.png.png"] forState:UIControlStateNormal];
	[_uib_ibtBtn setImage: [UIImage imageNamed:@"logo_utcibt.png.png"] forState:UIControlStateSelected];
	[_uib_ibtBtn addTarget: self action:@selector(loadIBT) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview: _uib_ibtBtn];
}

#pragma IBT

#pragma mark search
-(void)loadIBT
{
    NSLog(@"loadSearch");
    IBTViewController* vc = [IBTViewController new];
    //vc.delegate = self;
    [self presentViewController:vc animated:YES completion:^{}];
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

-(void)initCompanyLogoBtns
{
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
		
		//TODO: check if company needs popover
		//[self zoomTowardsPointFrom:sender];

		
		
		[settButton addTarget:self action:@selector(showPopover:) forControlEvents:UIControlEventTouchDown];
		[arr_CompanyLogos addObject:settButton];
		[_uis_zoomingImg.blurView addSubview:settButton];
		//[self pulse:settButton.layer];
			
			// add drag listener
			//[settButton addTarget:self action:@selector(wasDragged:withEvent:)
			//forControlEvents:UIControlEventTouchDragInside];
		//}
		
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
#warning trying to get subcat into title for all films
	//now set in selectrow
	// [self initTitleBox];
}

-(void)loadHotspots
{
	_uib_logoBtn.hidden = YES;
	[self createHotspots];
	[self initTitleBox];
}

-(void)loadSplitAssets
{
	NSLog(@"loadSplitAssets");
	
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
    [self initIBTButton];
	
	[_uis_zoomingInfoImg removeFromSuperview];
	
	[self removeHotspots];
	[_arr_hotspotsArray removeAllObjects];
		
	[_uib_backBtn setTag:1];
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
	//NSLog(@"_uib_back %li",(long)_uib_backBtn.tag);
	
}

-(void)hideBackButton
{
	NSLog(@"hideBackButton");
	self.uib_backBtn.hidden = YES;
	self.uib_backBtn.transform = CGAffineTransformMakeTranslation(-backButtonWidth*2, 0);
	[topTitle.uil_Company setHidden:YES];
}

-(void)unhideBackButton
{
	NSLog(@"==unhideBackButton");
	self.uib_backBtn.hidden = NO;
	self.uib_backBtn.transform = CGAffineTransformIdentity;
	[topTitle.uil_Company setHidden:NO];
}

-(void)performSelectorFromArray
{
	NSLog(@"performSelectorFromArray");
	NSValue *val = _arr_BreadCrumbOfImages[_uib_backBtn.tag];
	SEL mySelector = [val pointerValue];
	//	[self performSelector:mySelector];
	IMP imp = [self methodForSelector:mySelector];
	void (*func)(id, SEL) = (void *)imp;
	func(self, mySelector);
	
	//NSLog(@"_uib_back %li",(long)_uib_backBtn.tag);
}

-(void)reloadBuildingVC
{
	//NSLog(@"should be tag 0");
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
	[self removeCompanyLogos];
	
	[self updateStillFrameUnderFilm:@"02_HERO_BLDG.png"];
	[_uib_backBtn setTag:0];
	NSLog(@"_uib_back %li",(long)_uib_backBtn.tag);
	
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
	
	topTitle = [[embTitle alloc] initWithFrame:CGRectZero withText:topname];
	[self.view addSubview:topTitle];
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

	// get array of all hotspots
	selectedCo = [[LibraryAPI sharedInstance] getSelectedCompanyData];
    NSArray *totalDataArray = selectedCo.cohotspots;
	//NSLog(@"%@",selectedCo.cohotspots);
	
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

// load the hotpots of the company selected
-(void)loadCompanySubHotspots:(NSArray*)arrayOfSubHotspots
{
	[self removeHotspots];
	
	[_uib_backBtn setTag:3];
	
	// get array of all hotspots
	//selectedCo = [[LibraryAPI sharedInstance] getSelectedCompanyData];
	NSArray *totalDataArray = arrayOfSubHotspots;
	//NSLog(@"%@",selectedCo.cohotspots);
	
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
		
		_myHotspots.tagOfHs = i + 100;
		[_uis_zoomingInfoImg.blurView addSubview:_myHotspots];
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
	
	PopoverViewController *PopoverView =[[PopoverViewController alloc] initWithNibName:@"PopoverViewController" bundle:nil];
	self.popOver =[[UIPopoverController alloc] initWithContentViewController:PopoverView];
	PopoverView.delegate = self;
	
	[self.popOver presentPopoverFromRect:sender.frame inView:_uis_zoomingImg.blurView permittedArrowDirections:UIPopoverArrowDirectionLeft | UIPopoverArrowDirectionRight animated:YES];
}

#pragma mark - PopoverViewControllerDelegate method
-(void)selectedRow:(NSInteger)row withText:(NSString*)text
{
	NSLog(@"text %@",text);

	if ( [text isEqualToString:@"Intelligent Building Technologies"] )
	{
		//TODO: Load IBT functionality
		UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Intelligent Building Technologies"
														  message:@"IBS will display soon"
														 delegate:nil
												cancelButtonTitle:@"OK"
												otherButtonTitles:nil];
		[message show];
		
	} else {
		
		selectedCo = [[LibraryAPI sharedInstance] getSelectedCompanyData];
		NSDictionary *catDict = [selectedCo.cocategories objectAtIndex:row];
		NSString *categoryType = [catDict objectForKey:@"catType"];
		NSString *categoryName = [catDict objectForKey:@"catName"];
		NSString *subBG = [catDict objectForKey:@"subBG"];
		_arr_subHotspots = [catDict objectForKey:@"subhotspots"];
		
		//NSLog(@"subhotspots %@",_arr_subHotspots);
		
		if ([categoryType isEqualToString:@"film"]) {
			// get which company from data model
			[self cleanupBeforeLoadingFlyin];
			[self initTitleBox];
			[topTitle setHotSpotTitle:categoryName];
			
		} else if ([categoryType isEqualToString:@"still"]) {
			//TODO: connect to data
			[self popUpImage:@"PH2_KIDDE_01_SMG_FM200.PNG" withCloseButton:YES];
			[self initTitleBox];
			[topTitle setHotSpotTitle:categoryName];
			
			
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
		
		//The color picker popover is showing. Hide it.
		[self.popOver dismissPopoverAnimated:YES];
		self.popOver = nil;
        
        [_uib_ibtBtn removeFromSuperview];

	}
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

#pragma mark hotspot tapped
#pragma mark Delegate Method

-(void)neoHotspotsView:(neoHotspotsView *)hotspot withTag:(int)i
{
	
	NSLog(@"neoHotspotsView");
	
	BOOL isSubHotspots;
	
	int formattedTag = 0;
	
	if (i > 99) {
		formattedTag = i - 100;
		isSubHotspots = YES;
	} else {
		formattedTag = i;
		isSubHotspots = NO;
	}
	
	tappedView = _arr_hotspotsArray[formattedTag];
	tappedView.tag = formattedTag;
	tappedView.alpha = 0.75;
	[tappedView setLabelAlpha:0.75];
	
		if ([tappedView.str_typeOfHs isEqualToString:@"movie"]) {
			
			_coDict = [selectedCo.cohotspots objectAtIndex:formattedTag];
			NSString *movieNamed =  [_coDict objectForKey:@"fileName"];
			
			NSDictionary *cod = _arr_subHotspots[formattedTag];
			NSString *imageNameName;
			
			if ([cod objectForKey:@"overlay"]) {
				imageNameName = [NSString stringWithFormat:@"overlay.png"];
			}

			if (i > 99) {
				[self loadMovieNamed:movieNamed isTapToPauseEnabled:YES belowSubview:_uib_backBtn withOverlay:imageNameName];
			} else {
				[self loadMovieNamed:movieNamed isTapToPauseEnabled:YES belowSubview:_uis_zoomingImg withOverlay:nil];
			}
		}
		else {
			NSLog(@"=======/n/n/nn/\n\n\n\n neoHotspotsView no need ==========");
			//TODO: attach to data if some subhotspots load different content
//			[self popUpImage:@"PH2_KIDDE_01_SMG_FM200.PNG"];
		}
		
		[self zoomTowardsPointFrom:tappedView];
		
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
			
			if(isSubHotspots==YES)
			{
				[topTitle appendHotSpotTitle:tappedView.str_labelText];

			} else {
				[topTitle appendHotSpotTitle:tappedView.str_labelText];

				//[topTitle setHotSpotTitle:tappedView.str_labelText];
			}
			
		});
}

-(void)zoomTowardsPointFrom:(UIView*)view
{
	//zoom towards the point tapped
	[_uis_zoomingImg zoomToPoint:CGPointMake(tappedView.center.x, tappedView.center.y) withScale:1.5 animated:YES];
    _uis_zoomingImg.alpha = 0.0;
    
    // needs a delay so it can be APPENDED before moving
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.33 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self animateTitleAndHotspot:LabelOffscreen];
    });
}

-(void)animateTitleAndHotspot:(NSInteger)d
{
	[UIView animateWithDuration:0.5 animations:^{
//		_uis_zoomingImg.alpha = 0.0;
        
        if (d == LabelOffscreen) {
            topTitle.uil_Company.frame = CGRectMake(-87, topTitle.uil_Company.frame.origin.y, topTitle.uil_Company.frame.size.width, topTitle.uil_Company.frame.size.height);
            topTitle.uil_HotspotTitle.frame = CGRectMake(-20, topTitle.uil_HotspotTitle.frame.origin.y, topTitle.uil_HotspotTitle.frame.size.width, topTitle.uil_HotspotTitle.frame.size.height);
            _uib_backBtn.transform = CGAffineTransformMakeTranslation(-backButtonWidth*2, 0);
            [[NSNotificationCenter defaultCenter] postNotificationName:@"moveSplitBtnLeft" object:nil];
            
            titleOffScreen = YES;
            
        } else if (d == LabelOnscreen) {
            topTitle.uil_Company.frame = CGRectMake(0, topTitle.uil_Company.frame.origin.y, topTitle.uil_Company.frame.size.width, topTitle.uil_Company.frame.size.height);
            _uib_backBtn.transform = CGAffineTransformIdentity;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"moveSplitBtnRight" object:nil];
            
            titleOffScreen = NO;

        }
        
        
        /*
        _uib_backBtn.transform = CGAffineTransformMakeTranslation(-backButtonWidth*2, 0);
        [[NSNotificationCenter defaultCenter] postNotificationName:@"moveSplitBtnLeft" object:nil];
        */
        
		
//		if (d == 0) {
//			topTitle.uil_Company.frame = CGRectMake(-74, topTitle.uil_Company.frame.origin.y, topTitle.uil_Company.frame.size.width, topTitle.uil_Company.frame.size.height);
//			topTitle.uil_HotspotTitle.frame = CGRectMake(-40, topTitle.uil_HotspotTitle.frame.origin.y, topTitle.uil_HotspotTitle.frame.size.width, topTitle.uil_HotspotTitle.frame.size.height);
//			
//			_uib_backBtn.transform = CGAffineTransformMakeTranslation(-backButtonWidth*2, 0);
//			[[NSNotificationCenter defaultCenter] postNotificationName:@"moveSplitBtnLeft" object:nil];
//		} else if (d == 1){
//			topTitle.uil_Company.frame = CGRectMake(74, topTitle.uil_Company.frame.origin.y, topTitle.uil_Company.frame.size.width, topTitle.uil_Company.frame.size.height);
//			topTitle.uil_HotspotTitle.frame = CGRectMake(74, topTitle.uil_HotspotTitle.frame.origin.y, topTitle.uil_HotspotTitle.frame.size.width, topTitle.uil_HotspotTitle.frame.size.height);
//			[[NSNotificationCenter defaultCenter] postNotificationName:@"moveSplitBtnRight" object:nil];
//		}
		
		
		
	} completion:^(BOOL completed) {    } ];
}

#pragma mark - hotspot actions
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
	[_uib_backBtn setTag:1];
	[_uis_zoomingInfoImg removeFromSuperview];
}

#pragma mark - ebzooming delegate
-(void)didRemove:(ebZoomingScrollView *)ebZoomingScrollView {

    NSLog(@"zoomingScroll.tg = %li", (long)ebZoomingScrollView.tag);
    
    // standard interface view
	if (ebZoomingScrollView.tag == 1100) {
		[_uis_zoomingInfoImg bringSubviewToFront:_uis_zoomingImg];
		[_uis_zoomingImg.scrollView setZoomScale:1.0];
		
		// hotspot cleanup
		[topTitle removeHotspotTitle];
		[topTitle removeCompanyTitle];
		
		// clean up last tapped view
		// we don;t need it anymore
		tappedView=nil;
		
		[self unhideChrome];
		
		[UIView animateWithDuration:0.5 animations:^{
			_uis_zoomingImg.alpha = 1.0;
		} completion:^(BOOL completed) {
			[_uis_zoomingInfoImg removeFromSuperview];
			_uis_zoomingInfoImg = nil;
		}];

	} else {
		// subhotspot  view
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
	
	NSLog(@"didRemove");
}

#pragma mark - unhide Chrome
-(void)unhideChrome
{
	[UIView animateWithDuration:0.33 animations:^{
//		topTitle.uil_Company.frame = CGRectMake(14, topTitle.uil_Company.frame.origin.y, topTitle.uil_Company.frame.size.width, topTitle.uil_Company.frame.size.height);
//		topTitle.uil_HotspotTitle.frame = CGRectMake(74, topTitle.uil_HotspotTitle.frame.origin.y, topTitle.uil_HotspotTitle.frame.size.width, topTitle.uil_HotspotTitle.frame.size.height);
		_uib_backBtn.transform = CGAffineTransformIdentity;
		[[NSNotificationCenter defaultCenter] postNotificationName:@"moveSplitBtnRight" object:nil];
	} completion:^(BOOL completed) {
		
	}];
}

#pragma mark - Utiltites
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

#pragma mark - play movie
-(void)loadMovieNamed:(NSString*)moviename isTapToPauseEnabled:(BOOL)tapToPauseEnabled belowSubview:(UIView*)belowSubview withOverlay:(NSString*)overlay
{
	
	NSString* fileName = [moviename stringByDeletingPathExtension];
	NSString* extension = [moviename pathExtension];
	
	NSString *url = [[NSBundle mainBundle] pathForResource:fileName
                                                    ofType:extension];
    
	if (tapToPauseEnabled == YES) {
		NSLog(@"tapToPauseEnabled == YES");
		_isPauseable = YES;
		
//		[UIView animateWithDuration:0.3 animations:^{
//			topTitle.uil_Company.frame = CGRectMake(-74, topTitle.uil_Company.frame.origin.y, topTitle.uil_Company.frame.size.width, topTitle.uil_Company.frame.size.height);
//			topTitle.uil_HotspotTitle.frame = CGRectMake(-74, topTitle.uil_HotspotTitle.frame.origin.y, topTitle.uil_HotspotTitle.frame.size.width, topTitle.uil_HotspotTitle.frame.size.height);
//		} completion:nil];
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
	[_uiv_movieContainer setBackgroundColor:[UIColor redColor]];
	
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
	
	[_avPlayer play];
	
	//NSDictionary *cod = _arr_subHotspots[tag]
	
		if (overlay) {
			NSString *imageNameName = overlay;
			UIImage *imagee = [self flipImage:[UIImage imageNamed:imageNameName]];
			UIImageView *imgv = [[UIImageView alloc ] initWithImage:imagee];
			imgv.frame = self.view.bounds;
			[_uiv_movieContainer addSubview:imgv];
		}
	
	if (tapToPauseEnabled) {
		NSLog(@"loadMovieNamed beginSequence");
		[self beginSequence];
	}
	
	NSString *movieNamed =  [selectedCoDict objectForKey:@"transitionFilm"];
	NSString *movieNamedImg = [selectedCoDict objectForKey:@"transitionFilmImg"];
	
	[self updateStillFrameUnderFilm:movieNamedImg];

	//[self updateStillFrameUnderFilm:@"04_HOTSPOT_CROSS_SECTION.png"];
	
	NSString *selectorAfterMovieFinished;
	
	if (tapToPauseEnabled == YES) {
		[self addMovieGestures];
		//[self loadControlsLabels];
		selectorAfterMovieFinished = @"playerItemLoop:";
		
		UIButton *h = [UIButton buttonWithType:UIButtonTypeCustom];
		h.frame = CGRectMake(1024-36, 0, 36, 36);
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
	[self.view addGestureRecognizer:doubleTapMovie];

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
	NSLog(@"playerItemDidReachEnd");
    
	[self closeMovie];
}

-(void)playerItemLoop:(NSNotification *)notification
{
	AVPlayerItem *p = [notification object];
	[p seekToTime:kCMTimeZero];
	[_avPlayer play];
	
	// starts the player as well
	NSLog(@"playerItemLoop beginSequence");
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
	NSLog(@"closeMovie");

    CGAffineTransform t = _uib_backBtn.transform;
    
    NSLog(@"xscale %f",t.tx);
    
    if (t.tx < 0) {
        [self animateTitleAndHotspot:LabelOnscreen];
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
	
	NSLog(@"_arr_subHotspots %lu",(unsigned long)[_arr_subHotspots count]);
	
	if (_isPauseable == YES) {
		[self unhideChrome];
#warning might be trouble once movies are added
		if ([_arr_subHotspots count] == 0) {
			//[topTitle removeHotspotTitle];
			if (topTitle.appendString) {
				NSLog(@"topTitle.appendString %@",topTitle.appendString);
				[topTitle setHotSpotTitle:topTitle.appendString];
			}
		} else {
			//_arr_subHotspots=nil;
			[topTitle setHotSpotTitle:topTitle.appendString];
		}
	}
	
	[self clearHotpsotData];
    
}

-(void)resetBaseInteractive
{
	NSLog(@"resetBaseInteractive");
	
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
	NSLog(@"resetSubHotspot");
	
	//[self removeMovieLayers];
	
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
#pragma mark - HOTSPOT MODEL
//----------------------------------------------------
/*
	All hotspots need to be cleared or the
	animation will run all cards
*/
-(void)clearHotpsotData
{
	[arr_HotspotInfoCards removeAllObjects];
}


//----------------------------------------------------
#pragma mark - start sequences
//----------------------------------------------------
/*
 start all info cards and movie in motion
 */
-(void)beginSequence
{

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
	
	selectedCo = [[LibraryAPI sharedInstance] getSelectedCompanyData];
	NSArray *totalDataArray = selectedCo.cohotspots;

	// causes crash sometimes
	NSDictionary *hotspotItem = totalDataArray [tappedView.tag];
	//NSLog(@"/ntapedtag %li",(long)tappedView.tag);
	
	//Get the exact second to remove the text boxes
	removeTextAfterThisManySeconds = [[hotspotItem objectForKey:@"removeafterseconds"] intValue];
	
	// grab facts dict
	NSDictionary *facts = [hotspotItem objectForKey:@"facts"];
	NSArray *hotspotText = [facts objectForKey:@"factscopy"];
	
	//NSLog(@"%@",[hotspotText description]);

	
	//Get the position of Hs
	NSString *str_position = [[NSString alloc] initWithString:[facts objectForKey:@"factxy"]];
	NSRange range = [str_position rangeOfString:@","];
	NSString *str_x = [str_position substringWithRange:NSMakeRange(0, range.location)];
	NSString *str_y = [str_position substringFromIndex:(range.location + 1)];
	float hs_x = [str_x floatValue];
	float hs_y = [str_y floatValue];
	
	factsCopy = [[facts objectForKey:@"factwidth"] floatValue];
	
	for (int i = 0; i < [hotspotText count]; i++) {
		NSDictionary *box = hotspotText[i];
		
		embUiViewCard *card = [[embUiViewCard alloc] init];
		[card setBackgroundColor:[[UIColor clearColor] colorWithAlphaComponent:0.5]];
		card.delay = (int)[[box objectForKey:@"appearanceDelay"] integerValue];
		card.text = [box objectForKey:@"copy"];
		//NSLog(@"%@",card.text);
		
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
