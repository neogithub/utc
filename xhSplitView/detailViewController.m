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
#import "LibraryAPI.h"
#import "embDrawBezierPath.h"
#import "embBldgTypePaths.h"

@interface detailViewController () <ebZoomingScrollViewDelegate,embDrawBezierPathDelegate>

@property (nonatomic, strong) ebZoomingScrollView		*uis_zoomingImg;
@property (nonatomic, strong) UIImageView				*uiiv_bg;
@property (nonatomic, strong) UIButton					*uib_buildingBtn;
@property (nonatomic, strong) buildingViewController    *buildingVC;
@property (nonatomic, strong) UIButton					*uib_back;
@property (nonatomic, strong) embDrawBezierPath                 *blockPath;
@property (nonatomic, strong) embBldgTypePaths                  *bldgTypePaths;
@property (nonatomic, strong) NSMutableArray                    *pathsArray;
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
    
    [self drawPaths];
    
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(restartView) name:@"loadBuilding" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(animateTransition) name:@"animateTransition" object:nil];
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



#pragma mark - Darw Paths On Map
-(void)drawPaths
{
    
    _bldgTypePaths = [[embBldgTypePaths alloc] init];
    _pathsArray = _bldgTypePaths.bezierPaths;
    
    // actual drawpath function
    _blockPath = [[embDrawBezierPath alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
    _blockPath.delegate=self;
    _blockPath.allowsMultipleSelection=NO;
    [self.view addSubview:_blockPath];
    
    for (int i=0; i<[_pathsArray count]; i++) {
        
        embBezierPathItem *p = _pathsArray[i];
        NSLog(@"%@", [p description]);
        
        _blockPath.myPath = p.embPath;
        _blockPath.animationSpeed = 0;
        _blockPath.pathStrokeColor = [UIColor clearColor];
        _blockPath.pathFillColor = [UIColor whiteColor];
        _blockPath.pathLineWidth = 3.0;
        _blockPath.animationSpeed = 1.5;
        _blockPath.isTappable = YES;
        _blockPath.animated = NO;
        _blockPath.isStack = NO;
        [_blockPath startAnimationFromIndex:i afterDelay:p.pathDelay];
        
        [_blockPath pulseFill];
    }
}

-(void)embDrawBezierPath:(embDrawBezierPath *)path indexOfTapped:(int)i
{
    NSLog(@"tapped building %i",i);
    
    //NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithObject:[NSNumber numberWithInt:i] forKey:@"buttontag"];
    // [[NSNotificationCenter defaultCenter] postNotificationName:@"updateDetailView" object:self userInfo:dictionary];
    
    [self loadBuildingVC:i];
    
    //[_blockPath clearAllHilightedPart];
}



-(void)loadBuilding
{
// TODO: Lookup currently selected building (maybe?)
    [self loadBuildingVC:0];
	[[LibraryAPI sharedInstance] getCompanies];
}

-(void)loadBuildingVC:(int)index
{
	_buildingVC = [[buildingViewController alloc] initWithNibName:nil bundle:nil];
	_buildingVC.transitionClipName = @"01_TRANS_CITY_TO_BLDG.mov";
	[self addChildViewController:_buildingVC];
	[self.view addSubview: _buildingVC.view];
	[_buildingVC didMoveToParentViewController:self];
	// update the company selected on the left side
	[self.delegate rowSelected:self atIndex:0];
}

-(void)restartView
{
	NSLog(@"DETAIL - restartView");
    [_uib_back removeFromSuperview];
    _uib_back = nil;
    [_buildingVC.view removeFromSuperview];
    _buildingVC = nil;
    _buildingVC.view = nil;
}

-(void)animateTransition
{
    [self loadBuildingVC:0];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"closeMaster" object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
