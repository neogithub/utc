//
//  detailViewController.m
//  xhSplitViewController
//
//  Created by Xiaohe Hu on 9/2/14.
//  Copyright (c) 2014 Neoscape. All rights reserved.
//

#import "detailViewController.h"
#import "otisViewController.h"
@interface detailViewController ()
@property (nonatomic, strong) UIImageView           *uiiv_bg;
@property (nonatomic, strong) UIButton              *uib_buildingBtn;
@property (nonatomic, strong) otisViewController    *otisVC;
@property (nonatomic, strong) UIButton              *uib_back;
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideBackBtn) name:@"goIntoBuilding" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(unhideBackBtn) name:@"goToCity" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadBuilding) name:@"loadOtis" object:nil];
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
    if (_uiiv_bg) {
        [_uiiv_bg removeFromSuperview];
        _uiiv_bg = nil;
    }
    _uiiv_bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"grfx_cityBgImg.jpg"]];
    _uiiv_bg.frame = self.view.bounds;
    [self.view addSubview: _uiiv_bg];
}

-(void)initBuildingBtn
{
    _uib_buildingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _uib_buildingBtn.frame = CGRectMake(385.0, 257.0, 285, 193);
    _uib_buildingBtn.backgroundColor = [UIColor clearColor];
    [_uib_buildingBtn addTarget:self action:@selector(loadBuilding) forControlEvents:UIControlEventTouchUpInside];
    [self.view insertSubview:_uib_buildingBtn aboveSubview:_uiiv_bg];
}

-(void)loadBuilding
{
    _otisVC = [[otisViewController alloc] initWithNibName:nil bundle:nil];
    [self.view addSubview: _otisVC.view];
    [self createBackButton];
}

-(void)createBackButton
{
    _uib_back = [UIButton buttonWithType:UIButtonTypeCustom];
    _uib_back.frame = CGRectMake(37, 0.0, 36, 36);
    [_uib_back setImage:[UIImage imageNamed:@"grfx_backBtn.png"] forState:UIControlStateNormal];
    [self.view insertSubview:_uib_back aboveSubview:_otisVC.view];
    [_uib_back addTarget:self action:@selector(restartView) forControlEvents:UIControlEventTouchUpInside];
}

-(void)restartView
{
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
