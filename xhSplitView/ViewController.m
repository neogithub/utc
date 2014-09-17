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

static NSString * const sampleDesc1 = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Pellentesque tincidunt laoreet diam, id suscipit ipsum sagittis a. ";

static NSString * const sampleDesc2 = @" Suspendisse et ultricies sem. Morbi libero dolor, dictum eget aliquam quis, blandit accumsan neque. Vivamus lacus justo, viverra non dolor nec, lobortis luctus risus.";

static NSString * const sampleDesc3 = @"In interdum scelerisque sem a convallis. Quisque vehicula a mi eu egestas. Nam semper sagittis augue, in convallis metus";

static NSString * const sampleDesc4 = @"Praesent ornare consectetur elit, in fringilla ipsum blandit sed. Nam elementum, sem sit amet convallis dictum, risus metus faucibus augue, nec consectetur tortor mauris ac purus.";

static NSString * const sampleDesc5 = @"Sed rhoncus arcu nisl, in ultrices mi egestas eget. Etiam facilisis turpis eget ipsum tempus, nec ultricies dui sagittis. Quisque interdum ipsum vitae ante laoreet, id egestas ligula auctor";

static NSString * const sampleDesc6 = @"Sed rhoncus arcu nisl, in ultrices mi egestas eget";


@interface ViewController () <GHWalkThroughViewDataSource, GHWalkThroughViewDelegate>

@property (nonatomic, strong) GHWalkThroughView* ghView ;

@property (nonatomic, strong) NSArray* descStrings;

@property (nonatomic, strong) UILabel* welcomeLabel;

@property (nonatomic, strong) UIButton                          *uib_splitCtrl;
@property (nonatomic, strong) UIButton                          *uib_help;
@property (nonatomic, strong) xhSplitViewController             *splitVC;
@property (nonatomic, strong) masterViewController              *masterView;
@property (nonatomic, strong) detailViewController              *detailView;
@property (nonatomic, strong) buildingViewController            *otisView;
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
    
    [self initMasterVC];
    [self initDetailVC];
    [self initSplitVC];
    [self initBuildingVC];
    [self initSplitCtrl];
	[self initHelpButton];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateDetailView:) name:@"masterEvent" object:nil];
	
	if (((AppDelegate*)[UIApplication sharedApplication].delegate).firstRun)
    {
        [self showHelp];
	}
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
    cell.title = [NSString stringWithFormat:@"This is page %ld", index+1];
	// cell.titleImage = [UIImage imageNamed:[NSString stringWithFormat:@"title%ld", index+1]];
    cell.desc = [self.descStrings objectAtIndex:index];
}

- (UIImage*) bgImageforPage:(NSInteger)index
{
    NSString* imageName =[NSString stringWithFormat:@"bg_0%ld.jpg", index+1];
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
    _uib_splitCtrl.frame = CGRectMake(0.0, 0.0, 36, 36);
    [_uib_splitCtrl setImage: [UIImage imageNamed:@"grfx_splitBtn.jpg"] forState:UIControlStateNormal];
    [_uib_splitCtrl setImage: [UIImage imageNamed:@"grfx_splitBtn.jpg"] forState:UIControlStateSelected];
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
        }];
    }
    else {
        [_splitVC hideMasterPanel];
        [UIView animateWithDuration:0.33 animations:^{
            _uib_splitCtrl.transform = CGAffineTransformIdentity;
        }];
    }
}

-(void)updateDetailView:(NSNotification *)notification
{
    //TODO: pick building from data model
	//int index = [[[notification userInfo] valueForKey:@"index"] intValue];
	[_splitVC addDetailController:_detailView animated:NO];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"loadOtis" object:nil];
	[self openAndCloseMaster];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

