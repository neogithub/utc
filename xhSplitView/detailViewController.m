//
//  detailViewController.m
//  xhSplitViewController
//
//  Created by Xiaohe Hu on 9/2/14.
//  Copyright (c) 2014 Neoscape. All rights reserved.
//

#import "detailViewController.h"
#import "buildingViewController.h"
#import "ebZoomingScrollView.h"

@interface detailViewController () <ebZoomingScrollViewDelegate>

@property (nonatomic, strong) ebZoomingScrollView		*uis_zoomingImg;
@property (nonatomic, strong) UIImageView				*uiiv_bg;
@property (nonatomic, strong) UIButton					*uib_buildingBtn;
@property (nonatomic, strong) buildingViewController    *otisVC;
@property (nonatomic, strong) UIButton					*uib_back;
@end

@implementation detailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.frame = CGRectMake(0.0, 0.0, 1024, 768);
    // Do any additional setup after loading the view.
    [self createBG];
    [self initBuildingBtn];
	// [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideBackBtn) name:@"goIntoBuilding" object:nil];
	// [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(unhideBackBtn) name:@"goToCity" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(restartView) name:@"loadOtis" object:nil];
}

-(void)hideBackBtn
{
    _uib_back.hidden = YES;
}

-(void)unhideBackBtn
{
    _uib_back.hidden = NO;
}

-(void)createBG
{
    if (_uis_zoomingImg) {
        [_uis_zoomingImg removeFromSuperview];
        _uis_zoomingImg = nil;
    }
	
	_uis_zoomingImg = [[ebZoomingScrollView alloc] initWithFrame:CGRectMake(0.0, 0.0, 1024, 768) image:[UIImage imageNamed:@"01_HERO_CITY.png"] shouldZoom:YES];
    _uis_zoomingImg.delegate = self;
	[self.view addSubview:_uis_zoomingImg];
}

-(void)initBuildingBtn
{
    _uib_buildingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _uib_buildingBtn.frame = CGRectMake(390.0, 245.0, 245, 215);
    //_uib_buildingBtn.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5];
    [_uib_buildingBtn addTarget:self action:@selector(loadBuilding) forControlEvents:UIControlEventTouchUpInside];
    [_uis_zoomingImg.blurView addSubview:_uib_buildingBtn];
}

-(void)loadBuilding
{
	[self loadBuildingVC:0];
}

-(void)loadBuildingVC:(int)index
{
	_otisVC = [[buildingViewController alloc] initWithNibName:nil bundle:nil];
	_otisVC.transitionClipName = @"01_TRANS_CITY_TO_BLDG_4.mov";
	[self.view addSubview: _otisVC.view];
    //[self createBackButton];
}

-(void)createBackButton
{
    NSLog(@"createBackButton");
	_uib_back = [UIButton buttonWithType:UIButtonTypeCustom];
    _uib_back.frame = CGRectMake(37, 0.0, 51, 43);
    [_uib_back setImage:[UIImage imageNamed:@"icon back.png"] forState:UIControlStateNormal];
    [self.view insertSubview:_uib_back aboveSubview:_otisVC.view];
    [_uib_back addTarget:self action:@selector(restartView) forControlEvents:UIControlEventTouchUpInside];
}

-(void)restartView
{
	NSLog(@"DETAIL - restartView");

    [_uib_back removeFromSuperview];
    _uib_back = nil;
    [_otisVC.view removeFromSuperview];
    _otisVC = nil;
    _otisVC.view = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
