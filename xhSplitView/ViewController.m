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

static NSString * const sampleDesc1 = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Pellentesque tincidunt laoreet diam, id suscipit ipsum sagittis a. ";

static NSString * const sampleDesc2 = @" Suspendisse et ultricies sem. Morbi libero dolor, dictum eget aliquam quis, blandit accumsan neque. Vivamus lacus justo, viverra non dolor nec, lobortis luctus risus.";

static NSString * const sampleDesc3 = @"In interdum scelerisque sem a convallis. Quisque vehicula a mi eu egestas. Nam semper sagittis augue, in convallis metus";

static NSString * const sampleDesc4 = @"Praesent ornare consectetur elit, in fringilla ipsum blandit sed. Nam elementum, sem sit amet convallis dictum, risus metus faucibus augue, nec consectetur tortor mauris ac purus.";

static NSString * const sampleDesc5 = @"Sed rhoncus arcu nisl, in ultrices mi egestas eget. Etiam facilisis turpis eget ipsum tempus, nec ultricies dui sagittis. Quisque interdum ipsum vitae ante laoreet, id egestas ligula auctor";

static NSString * const sampleDesc6 = @"Sed rhoncus arcu nisl, in ultrices mi egestas eget";

static CGFloat menuButtonHeights = 51;

@interface ViewController () <GHWalkThroughViewDataSource, GHWalkThroughViewDelegate>

@property (nonatomic, strong) GHWalkThroughView* ghView ;

@property (nonatomic, strong) NSArray* descStrings;

@property (nonatomic, strong) UILabel* welcomeLabel;

@property (nonatomic, strong) UIButton                          *uib_splitCtrl;
@property (nonatomic, strong) UIButton                          *uib_help;
@property (nonatomic, strong) UIView							*uiv_tapSquare;

@property (nonatomic, strong) xhSplitViewController             *splitVC;
@property (nonatomic, strong) masterViewController              *masterView;
@property (nonatomic, strong) detailViewController              *detailView;
@property (nonatomic, strong) buildingViewController            *otisView;
@property (nonatomic, strong) UIImageView						*uiiv_initImage;
@property (nonatomic, strong) AVPlayer*							avPlayer;
@property (nonatomic, strong) AVPlayerLayer*					avPlayerLayer;
@property (nonatomic, strong) UIView*							uiv_movieContainer;
@end

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

	if (((AppDelegate*)[UIApplication sharedApplication].delegate).firstRun)
    {
        //[self showHelp];
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
	
	UITapGestureRecognizer *tapOnImg = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(loadMap:)];
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


-(void)loadMap:(UIGestureRecognizer *)gesture
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
    
	/*
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
        //[[NSNotificationCenter defaultCenter] removeObserver:self];
		[[NSNotificationCenter defaultCenter] removeObserver:self name:@"playerItemLoop:" object:nil];
		[[NSNotificationCenter defaultCenter] removeObserver:self name:@"playerItemDidReachEnd:" object:nil];
    }
	 */
	
	_uiv_movieContainer = [[UIView alloc] initWithFrame:self.view.frame];
	[_uiv_movieContainer setBackgroundColor:[UIColor clearColor]];
	
	[self.view addSubview:_uiv_movieContainer];
	
	
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
    
	//[self updateStillFrameUnderFilm:@"04_HOTSPOT_CROSS_SECTION.png"];
	
	NSString *selectorAfterMovieFinished;
	
	selectorAfterMovieFinished = @"playerItemDidReachEnd:";

	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:NSSelectorFromString(selectorAfterMovieFinished)
												 name:AVPlayerItemDidPlayToEndTimeNotification
											   object:[_avPlayer currentItem]];
	
}

- (UIImage *)flipImage:(UIImage *)image
{
    UIGraphicsBeginImageContext(image.size);
    CGContextDrawImage(UIGraphicsGetCurrentContext(),CGRectMake(0.,0., image.size.width, image.size.height),image.CGImage);
    UIImage *i = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return i;
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



-(void)moveSplitBtnLeft
{
	_uib_splitCtrl.transform = CGAffineTransformMakeTranslation(-menuButtonHeights, 0);
}

-(void)moveSplitBtnRight
{
	_uib_splitCtrl.transform = CGAffineTransformIdentity;
}

-(void)showHelp
{
	_ghView = [[GHWalkThroughView alloc] initWithFrame:self.view.bounds];
	[_ghView setDataSource:self];
	_ghView.delegate = self;
	[_ghView setWalkThroughDirection:GHWalkThroughViewDirectionHorizontal];
	UILabel* welcomeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 50)];
	welcomeLabel.text = @"Welcome";
	welcomeLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:40];
	welcomeLabel.textColor = [UIColor whiteColor];
	welcomeLabel.textAlignment = NSTextAlignmentCenter;
	self.welcomeLabel = welcomeLabel;
	
	self.descStrings = [NSArray arrayWithObjects:sampleDesc1,sampleDesc2, sampleDesc3, sampleDesc4, sampleDesc5, sampleDesc6, nil];
	//self.ghView.bgImage = [UIImage imageNamed:@"bg_01.jpg"];
	
	self.ghView.isfixedBackground = NO;
	self.ghView.floatingHeaderView = nil;
	
	[self.ghView showInView:self.view animateDuration:0.3];
	[_ghView setFloatingHeaderView:self.welcomeLabel];

}

#pragma mark - GHDataSource

-(NSInteger) numberOfPages
{
    return 6;
}

- (void) configurePage:(GHWalkThroughPageCell *)cell atIndex:(NSInteger)index
{
    cell.title = [NSString stringWithFormat:@"This is page %d", index+1];
	// cell.titleImage = [UIImage imageNamed:[NSString stringWithFormat:@"title%ld", index+1]];
    cell.desc = [self.descStrings objectAtIndex:index];
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
    _otisView = [[buildingViewController alloc] initWithNibName:nil bundle:nil];
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
    [_uib_splitCtrl addTarget: self action:@selector(openAndCloseMaster) forControlEvents:UIControlEventTouchUpInside];
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

-(void)openAndCloseMaster
{
    _uib_splitCtrl.selected = !_uib_splitCtrl.selected;
    if (_uib_splitCtrl.selected) {
        [_splitVC showPanel];
        [UIView animateWithDuration:0.33 animations:^{
            _uib_splitCtrl.transform = CGAffineTransformMakeTranslation(180, 0.0);
			_uib_splitCtrl.hidden = YES;
			NSLog(@"hideDetailChrome");
			[[NSNotificationCenter defaultCenter] postNotificationName:@"hideDetailChrome" object:nil];
			[_detailView.view setUserInteractionEnabled:NO];
        }];
    }
    else {
        [_splitVC hideMasterPanel];
        [UIView animateWithDuration:0.33 animations:^{
            _uib_splitCtrl.transform = CGAffineTransformIdentity;
			_uib_splitCtrl.hidden = NO;
        }];
		NSLog(@"====unhideDetailChrome");
		[[NSNotificationCenter defaultCenter] postNotificationName:@"unhideDetailChrome" object:nil];
		[_detailView.view setUserInteractionEnabled:YES];
    }
}

-(void)updateDetailView:(NSNotification *)notification
{
    //TODO: pick building from data model
	//TODO: connect to data instaed of passing hard number
	//int index = [[[notification userInfo] valueForKey:@"index"] intValue];
    int pass = [[[notification userInfo] valueForKey:@"buttontag"] intValue];
	
	//NSLog(@"pass %i",pass);
	
	switch (pass) {
		case 0:
			
			[self setInitialImage];
			[_splitVC addDetailController:_detailView animated:NO];
			[[NSNotificationCenter defaultCenter] postNotificationName:@"loadOtis" object:nil];
			[self openAndCloseMaster];

			break;
			
		case 1:
			[_splitVC addDetailController:_detailView animated:NO];
			[[NSNotificationCenter defaultCenter] postNotificationName:@"loadOtis" object:nil];
			[self openAndCloseMaster];
			break;
			
		case 2:
			
			[self openAndCloseMaster];

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

