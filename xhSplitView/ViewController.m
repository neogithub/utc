//
//  ViewController.m
//  xhSplitView
//
//  Created by Xiaohe Hu on 9/3/14.
//  Copyright (c) 2014 Neoscape. All rights reserved.
//

#import "ViewController.h"
#import "xhSplitViewController.h"
#import "masterViewController.h"
#import "detailViewController.h"
#import "buildingViewController.h"
#import "AppDelegate.h"
#import "GHWalkThroughView.h"
@import MediaPlayer;
#import <AVFoundation/AVPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "UIImage+FlipImage.h"
#import "IBTViewController.h"
#import "SustainViewController.h"
#import "ModalViewController.h"
#import "UIColor+Extensions.h"

static NSString * const sampleTitle1 = @"How to use UTC  Building Possible";
static NSString * const sampleDesc1 = @"Tap the center Commercial Building to zoom closer.\nUse the Refresh button in the MENU (top left corner) to restart the app.\nPinch and zoom functionality applies to every image (outside of the help area).";

static NSString * const sampleTitle2 = @"UTC Companies";
static NSString * const sampleDesc2 = @"Tap the glowing circle (bottom center) to reveal the building's interior and the Companies located within.\nDouble tap to skip the transformation animation.";

static NSString * const sampleTitle3 = @"Company Products";
static NSString * const sampleDesc3 = @"Tap a Company to explore its products.\nSome Companies present a menu of product options; those with only one available product move directly to a product information screen.";

static NSString * const sampleTitle4 = @"Hotspots";
static NSString * const sampleDesc4 = @"Tap the orange circle in each hotspot to explore and view a product film.\nOr use the Back button (top left) to go back a level and return to the main Company screen.";

static NSString * const sampleTitle5 = @"Hotspot Films";
static NSString * const sampleDesc5 = @"Tap the screen to pause a hotspot film; tap again to resume.\nTap the X in the corner to close.";

static NSString * const sampleTitle6 = @"Intelligent Building Technology";
static NSString * const sampleDesc6 = @"Where applicable, you many jump directly to a Company’s Intelligent Building Technology section (listed in blue) from its menu.\nOr, tap United Technologies (top right corner of Home screen) to explore the entire Intelligent Building Technology section.\nTap the product logos or Learn More to play a film.";

static CGFloat menuButtonHeights = 51;

@interface ViewController () <GHWalkThroughViewDataSource, GHWalkThroughViewDelegate, IBTViewControllerDelegate, SustainViewControllerDelegate, ModalViewControllerDelegate>
{
    UIView *tappableUIVIEW;
    UILabel* welcomeLabel;
}

@property (nonatomic, strong) GHWalkThroughView* ghView ;

@property (nonatomic, strong) NSArray* descStrings;
@property (nonatomic, strong) NSArray* titleStrings;

@property (nonatomic, strong) UILabel* welcomeLabel;

@property (nonatomic, strong) UIButton                          *uib_splitCtrl;
@property (nonatomic, strong) UIButton                          *uib_help;
@property (nonatomic, strong) UIView							*uiv_tapSquare;

@property (nonatomic, strong) xhSplitViewController             *splitVC;
@property (nonatomic, strong) masterViewController              *masterView;
@property (nonatomic, strong) detailViewController              *detailView;
@property (nonatomic, strong) buildingViewController            *buildingView;
@property (nonatomic, strong) UIImageView						*uiiv_initImage;
@property (nonatomic, strong) AVPlayer*							avPlayer;
@property (nonatomic, strong) AVPlayerLayer*					avPlayerLayer;
@property (nonatomic, strong) UIView*							uiv_movieContainer;
@end

enum MenuVisibilityType : NSUInteger {
    MenuVisibilityTypeOnscreen = 1,
    MenuVisibilityTypeOffscreen = 2,
};

@implementation ViewController
- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.frame = CGRectMake(0.0, 0.0, 1024, 768);
	// Do any additional setup after loading the view, typically from a nib.
    [self prefersStatusBarHidden];
	
#ifdef NEODEMO
	NSLog(@"Welcome to DEMO");
#else
	NSLog(@"Welcome to UTC");
#endif

    [self initMasterVC];
    [self initDetailVC];
    [self initSplitVC];
    [self initBuildingVC];
    [self initSplitCtrl];
    
	[self setInitialImage];
	
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateDetailView:) name:@"masterEvent" object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moveSplitBtnLeft) name:@"moveSplitBtnLeft" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moveSplitBtnRight) name:@"moveSplitBtnRight" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initIBT:) name:@"showIBT" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initSustainability:) name:@"showSustainability" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initModalVC:) name:@"showModalVC" object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeMaster) name:@"closeMaster" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openMaster) name:@"openMaster" object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showHelp) name:@"showHelp" object:nil];


	if (((AppDelegate*)[UIApplication sharedApplication].delegate).firstRun)
    {
        [self showHelp];
	}
}

-(void)setInitialImage
{
#ifdef NEODEMO
	_uiiv_initImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"00_LOGO_TRANS_HERO_CITY DEMO.png"]];
#else
	_uiiv_initImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"00_LOGO_TRANS_HERO_CITY.png"]];
#endif
	
    _uiiv_initImage.frame = CGRectMake(0.0, 0.0, 1024.0, 768.0);
    [self.view addSubview: _uiiv_initImage];
    
    _uiiv_initImage.userInteractionEnabled = YES;
	
	_uiv_tapSquare = [[UIView alloc] initWithFrame:CGRectZero];
	_uiv_tapSquare.frame = CGRectMake(473, 670, 80, 80);
	//_uiv_tapSquare.layer.cornerRadius = _uiv_tapSquare.frame.size.width/2;
	[_uiv_tapSquare setBackgroundColor:[UIColor clearColor]];
	[_uiv_tapSquare setUserInteractionEnabled:YES];
	
	UIView *uiv_tapCircle = [[UIView alloc] initWithFrame:CGRectZero];
	uiv_tapCircle.frame = CGRectMake(20, 20, 40, 40);
	uiv_tapCircle.layer.cornerRadius = uiv_tapCircle.frame.size.width/2;
	[uiv_tapCircle setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.5]];
	[_uiv_tapSquare addSubview:uiv_tapCircle];
	
	[_uiiv_initImage addSubview:_uiv_tapSquare];
	
	UITapGestureRecognizer *tapOnImg = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(loadLogoToCityTransition:)];
    [_uiv_tapSquare addGestureRecognizer: tapOnImg];
	
	[self pulse:_uiv_tapSquare.layer];
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
	theAnimation.fromValue=[NSNumber numberWithFloat:0.5];
	theAnimation.toValue=[NSNumber numberWithFloat:0.25];
	[pplayer addAnimation:theAnimation forKey:@"animateOpacity"];
}


-(void)loadLogoToCityTransition:(UIGestureRecognizer *)gesture
{
#ifdef NEODEMO
	[self loadMovieNamed:@"00_LOGO_TRANS_HERO_CITY DEMO.mov" isTapToPauseEnabled:NO];
#else
	[self loadMovieNamed:@"00_LOGO_TRANS_HERO_CITY.mov" isTapToPauseEnabled:NO];
#endif

	UIView *image = gesture.view;
	
	[UIView animateWithDuration:0.33 animations:^{
        _uiiv_initImage.alpha = 0.0;
		image.alpha = 0.0;
    } completion:^(BOOL finished){
        [_uiiv_initImage removeFromSuperview];
		[image removeFromSuperview];
    }];
}

#pragma mark - play movie
-(void)loadMovieNamed:(NSString*)moviename isTapToPauseEnabled:(BOOL)tapToPauseEnabled
{
	
	NSString* fileName = [moviename stringByDeletingPathExtension];
	NSString* extension = [moviename pathExtension];
	
	NSString *url = [[NSBundle mainBundle] pathForResource:fileName
                                                    ofType:extension];
	
	_uiv_movieContainer = [[UIView alloc] initWithFrame:self.view.frame];
	[_uiv_movieContainer setBackgroundColor:[UIColor clearColor]];
	
	[self.view addSubview:_uiv_movieContainer];
	
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
    
	NSString *selectorAfterMovieFinished;
	
	selectorAfterMovieFinished = @"playerItemDidReachEnd:";

	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:NSSelectorFromString(selectorAfterMovieFinished)
												 name:AVPlayerItemDidPlayToEndTimeNotification
											   object:[_avPlayer currentItem]];
	
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

-(void)closeMovie
{
	[_avPlayerLayer removeFromSuperlayer];
	_avPlayerLayer = nil;
	[_uiv_movieContainer removeFromSuperview];
	_uiv_movieContainer=nil;
}

#pragma mark - menu button movement
-(void)moveSplitBtnLeft
{
	_uib_splitCtrl.transform = CGAffineTransformMakeTranslation(-menuButtonHeights, 0);
}

-(void)moveSplitBtnRight
{
	_uib_splitCtrl.transform = CGAffineTransformIdentity;
}

#pragma mark - Help
-(void)showHelp
{
	_ghView = [[GHWalkThroughView alloc] initWithFrame:self.view.bounds];
	[_ghView setDataSource:self];
	_ghView.delegate = self;
	[_ghView setWalkThroughDirection:GHWalkThroughViewDirectionHorizontal];
	welcomeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 400, 40)];
	welcomeLabel.text = @"How to use UTC  Building Possible";
	welcomeLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:20];
	welcomeLabel.textColor = [UIColor whiteColor];
	welcomeLabel.textAlignment = NSTextAlignmentCenter;
    welcomeLabel.backgroundColor = [UIColor utcBlueA];
	self.welcomeLabel = welcomeLabel;
	
	self.descStrings = [NSArray arrayWithObjects:sampleDesc1,sampleDesc2, sampleDesc3, sampleDesc4, sampleDesc5, sampleDesc6, nil];
    self.titleStrings = [NSArray arrayWithObjects:sampleTitle1,sampleTitle2, sampleTitle3, sampleTitle4, sampleTitle5, sampleTitle6, nil];

    self.ghView.bgImage = [UIImage imageNamed:@"bg_01.jpg"];
	
	self.ghView.isfixedBackground = NO;
	self.ghView.floatingHeaderView = nil;
	
	[self.ghView showInView:self.view animateDuration:0.3];
	[_ghView setFloatingHeaderView:self.welcomeLabel];

}

#pragma mark GHDataSource

-(NSInteger) numberOfPages
{
    return 6;
}

- (void) configurePage:(GHWalkThroughPageCell *)cell atIndex:(NSInteger)index
{
    cell.title = [NSString stringWithFormat:@"Page %d of %ld", index+1,(unsigned long)self.descStrings.count];
    cell.desc = [self.descStrings objectAtIndex:index];
    welcomeLabel.text = self.titleStrings [index];

}

- (UIImage*) bgImageforPage:(NSInteger)index
{
    NSString* imageName =[NSString stringWithFormat:@"bg_0%d.jpg", index+1];
    UIImage* image = [UIImage imageNamed:imageName];
    return image;
}

- (void)walkthroughDidDismissView:(GHWalkThroughView *)walkthroughView
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	if (![defaults objectForKey:@"firstRun"]) {
		[defaults setObject:[NSDate date] forKey:@"firstRun"];
	}
}

#pragma mark - description Master Detail inits

-(void)initMasterVC
{
    _masterView = [[masterViewController alloc] initWithNibName:nil bundle:nil];
}

-(void)initDetailVC
{
    _detailView = [[detailViewController alloc] init];
    _detailView.view.backgroundColor = [UIColor whiteColor];
}

-(void)initBuildingVC
{
    _buildingView = [[buildingViewController alloc] initWithNibName:nil bundle:nil];
}

#pragma mark Open Modal
-(void)initIBT:(NSNotification *)notification
{
    
    NSLog(@"%@",[[notification userInfo] valueForKey:@"buttontag"]);
    NSLog(@"initIBT function");
    
    IBTViewController* vc = [IBTViewController new];
    vc.view.frame = CGRectMake(0, 0, 1024, 768);
    
    if ([[notification userInfo] valueForKey:@"buttontag"] == nil) {
        [vc loadIBT:nil];
    } else {
        [vc loadIBTAtDetail:[[notification userInfo] valueForKey:@"buttontag"]];
    }
    
    vc.delegate = self;
    [self presentViewController:vc animated:YES completion:^{}];
    
    [self closeMaster];
}

#pragma mark Open Modal
#pragma mark Open Modal
-(void)initModalVC:(NSNotification *)notification
{
    
    NSLog(@"%@",[[notification userInfo] valueForKey:@"buttontag"]);
    NSLog(@"initModal function");
    ModalViewController* vc = [ModalViewController new];
    vc.delegate = self;
    [self presentViewController:vc animated:YES completion:^{}];
    
    [self closeMaster];
}

-(void)initSustainability:(NSNotification *)notification
{
    
    NSLog(@"%@",[[notification userInfo] valueForKey:@"buttontag"]);
    NSLog(@"initSustainability function");
    SustainViewController* vc = [SustainViewController new];
    vc.delegate = self;
    [self presentViewController:vc animated:YES completion:^{}];
   
    [self closeMaster];
}

-(void)initSplitVC
{
    _splitVC = [[xhSplitViewController alloc] initWithNibName:@"xhSplitViewController" bundle:nil];
    _splitVC.view.frame = self.view.bounds;
    [_splitVC addMasterController:_masterView animated:NO];
    [_splitVC addDetailController:_detailView animated:NO];
    [self.view addSubview: _splitVC.view];
}

-(void)initSplitCtrl
{
    _uib_splitCtrl = [UIButton buttonWithType:UIButtonTypeCustom];
    _uib_splitCtrl.frame = CGRectMake(0.0, 0.0, menuButtonHeights, menuButtonHeights);
    [_uib_splitCtrl setImage: [UIImage imageNamed:@"icon main menu.png"] forState:UIControlStateNormal];
    [_uib_splitCtrl setImage: [UIImage imageNamed:@"icon main menu.png"] forState:UIControlStateSelected];
    [_uib_splitCtrl addTarget: self action:@selector(openMaster) forControlEvents:UIControlEventTouchUpInside];
    [self.view insertSubview: _uib_splitCtrl aboveSubview:_splitVC.view];
}

-(void)initHelpButton
{
    _uib_help = [UIButton buttonWithType:UIButtonTypeCustom];
    _uib_help.frame = CGRectMake(1024-36, 768.0-36, 36, 36);
    [_uib_help setImage: [UIImage imageNamed:@"grfx_helpBtn.png"] forState:UIControlStateNormal];
    [_uib_help setImage: [UIImage imageNamed:@"grfx_helpBtn.png"] forState:UIControlStateSelected];
    [_uib_help addTarget: self action:@selector(showHelp) forControlEvents:UIControlEventTouchUpInside];
    [self.view insertSubview: _uib_help aboveSubview:_splitVC.view];
}


-(void)openMaster
{
    [_splitVC showPanel];
    [UIView animateWithDuration:0.33 animations:^{
        _uib_splitCtrl.transform = CGAffineTransformMakeTranslation(180, 0.0);
        _uib_splitCtrl.hidden = YES;
        NSLog(@"hideDetailChrome");
        [[NSNotificationCenter defaultCenter] postNotificationName:@"hideDetailChrome" object:nil];
        [_detailView.view setUserInteractionEnabled:NO];
    }];
    
    _uib_splitCtrl.selected = !_uib_splitCtrl.selected;
    
    [self addGestureToBigContainer];
}

#pragma mark Action of Side Panel's buttons
- (void)addGestureToBigContainer
{
    tappableUIVIEW = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
    [tappableUIVIEW setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.0]];\
    [tappableUIVIEW setUserInteractionEnabled:NO];
    [self.view addSubview:tappableUIVIEW];
    
    [UIView animateWithDuration:0.33 animations:^{
        
        [tappableUIVIEW setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.6]];
        [tappableUIVIEW setUserInteractionEnabled:YES];
        tappableUIVIEW.frame = CGRectMake(_masterView.view.frame.size.width, 0, 1024-_masterView.view.frame.size.width, 768);

        UITapGestureRecognizer *tapOnBigContainer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeMaster)];
        [tappableUIVIEW addGestureRecognizer: tapOnBigContainer];
    
    }];
}


-(void)closeMaster
{
    [_splitVC hideMasterPanel];
    [UIView animateWithDuration:0.33 animations:^{
        _uib_splitCtrl.transform = CGAffineTransformIdentity;
        _uib_splitCtrl.hidden = NO;
        
        [tappableUIVIEW setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.0]];
        [tappableUIVIEW setUserInteractionEnabled:NO];
        tappableUIVIEW.frame = CGRectMake(0, 0, 1024, 768);

    } completion:^ (BOOL finished) {
         [tappableUIVIEW removeFromSuperview];
    }];
    
    NSLog(@"====unhideDetailChrome");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"unhideDetailChrome" object:nil];
    [_detailView.view setUserInteractionEnabled:YES];
    
}

-(void)updateDetailView:(NSNotification *)notification
{
    //TODO: pick building from data model
	//TODO: connect to data instaed of passing hard number
    
    int pass = [[[notification userInfo] valueForKey:@"buttontag"] intValue];
	
	NSLog(@"pass %i",pass);
	
	switch (pass) {
		case 0:
			
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"com.neoscape.SelectedRows"];

			[self setInitialImage];
			[_splitVC addDetailController:_detailView animated:NO];
			[[NSNotificationCenter defaultCenter] postNotificationName:@"loadBuilding" object:nil];
            [self closeMaster];

			break;
			
		case 1:
			[_splitVC addDetailController:_detailView animated:NO];
			[[NSNotificationCenter defaultCenter] postNotificationName:@"loadBuilding" object:nil];
            [self closeMaster];
			break;
			
		case 2:
			
            [self closeMaster];

			break;
			
		default:
			break;
	}
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

