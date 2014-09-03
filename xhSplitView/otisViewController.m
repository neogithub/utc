//
//  otisViewController.m
//  xhSplitViewController
//
//  Created by Xiaohe Hu on 9/3/14.
//  Copyright (c) 2014 Neoscape. All rights reserved.
//

#import "otisViewController.h"
#import "ebZoomingScrollView.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVPlayer.h>
#import <AVFoundation/AVFoundation.h>
@interface otisViewController ()<ebZoomingScrollViewDelegate>

@property (nonatomic, strong) UIImageView           *uiiv_bg;
@property (nonatomic, strong) NSMutableArray        *arr_hotspotsArray;
@property (nonatomic, strong) ebZoomingScrollView   *uis_zoomingImg;
@property (nonatomic, strong) AVPlayer              *avPlayer;
@property (nonatomic, strong) AVPlayerLayer         *avPlayerLayer;
@property (nonatomic, strong) UIButton              *uib_logoBtn;
@property (nonatomic, strong) UIButton              *uib_back;
@property (nonatomic, strong) UIButton              *uib_buildingBtn;
@end

@implementation otisViewController

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
    [self createBg];
//    [self createHotspots];
}

-(void)createBg
{
    if (_uiiv_bg) {
        [_uiiv_bg removeFromSuperview];
        _uiiv_bg = nil;
    }
    _uiiv_bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"otis_building.jpg"]];
    _uiiv_bg.frame = self.view.bounds;
    [self.view addSubview: _uiiv_bg];
//    [self initBuildingBtn];
    [self initLogoBtn];
//    [self performSelector:@selector(loadMovie) withObject:nil afterDelay:2];
//    [self performSelector:@selector(updateBgImg) withObject:nil afterDelay:3];
}

//-(void)initBuildingBtn
//{
//    _uib_buildingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    _uib_buildingBtn.frame = CGRectMake(385.0, 257.0, 285, 193);
//    _uib_buildingBtn.backgroundColor = [UIColor clearColor];
//    [_uib_buildingBtn addTarget:self action:@selector(loadBuilding) forControlEvents:UIControlEventTouchUpInside];
//    [self.view insertSubview:_uib_buildingBtn aboveSubview:_uiiv_bg];
//}

//-(void)loadBuilding
//{
//    [_uib_buildingBtn removeFromSuperview];
//    _uib_buildingBtn = nil;
//    
//    [_uiiv_bg setImage:[UIImage imageNamed:@"otis_building.jpg"]];
//    [self initLogoBtn];
////    [self createBackButton];
//}

-(void)initLogoBtn
{
    _uib_logoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _uib_logoBtn.frame = CGRectMake(500, 110, 100, 50);
    _uib_logoBtn.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_uib_logoBtn];
    [_uib_logoBtn addTarget:self action:@selector(changeView) forControlEvents:UIControlEventTouchUpInside];
}

-(void)changeView
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"goIntoBuilding" object:nil];
    _uib_logoBtn.hidden = YES;
    [self createBackButton];
    [self loadMovie];
    [self updateBgImg];
}

-(void)createBackButton
{
    _uib_back = [UIButton buttonWithType:UIButtonTypeCustom];
    _uib_back.frame = CGRectMake(37, 0.0, 36, 36);
    [_uib_back setImage:[UIImage imageNamed:@"grfx_backBtn.png"] forState:UIControlStateNormal];
    [self.view insertSubview:_uib_back aboveSubview:_uiiv_bg];
    [_uib_back addTarget:self action:@selector(restartView) forControlEvents:UIControlEventTouchUpInside];
}

-(void)restartView
{
    if (_avPlayerLayer) {
        [self closeMovie];
    }

    [self createBg];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"goToCity" object:nil];
}

-(void)updateBgImg
{
    [_uiiv_bg setImage:[UIImage imageNamed:@"otis_building_inside.png"]];
    [self createHotspots];
}

-(void)createHotspots
{
    [_arr_hotspotsArray removeAllObjects];
    _arr_hotspotsArray = nil;
    _arr_hotspotsArray = [[NSMutableArray alloc] init];
    
    UIView *hotspot1 = [[UIView alloc] initWithFrame:CGRectMake(560, 250, 131, 35)];
    UIImageView *hotspotMark1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Marker.png"]];
    hotspotMark1.frame = CGRectMake(90.0, 0.0, 41.0, 35.0);
    UILabel *hotsoptLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 90.0, 35.0)];
    [hotsoptLabel1 setText:@"Hotspot Label"];
    [hotsoptLabel1 setFont:[UIFont systemFontOfSize:13]];
    [hotsoptLabel1 setTextAlignment:NSTextAlignmentCenter];
    [hotspot1 addSubview: hotsoptLabel1];
    [hotspot1 addSubview: hotspotMark1];
    [self.view insertSubview:hotspot1 aboveSubview:_uiiv_bg];
    hotspot1.tag = 1;
    [_arr_hotspotsArray addObject: hotspot1];
    [self addGestureToHotspots:hotspot1];
    
//    UIView *hotspot2 = [[UIView alloc] initWithFrame:CGRectMake(560, 360, 131, 35)];
//    UIImageView *hotspotMark2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Marker.png"]];
//    hotspotMark2.frame = CGRectMake(90.0, 0.0, 41.0, 35.0);
//    UILabel *hotsoptLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 90.0, 35.0)];
//    [hotsoptLabel2 setText:@"Hotspot Label"];
//    [hotsoptLabel2 setFont:[UIFont systemFontOfSize:13]];
//    [hotsoptLabel2 setTextAlignment:NSTextAlignmentCenter];
//    [hotspot2 addSubview: hotsoptLabel2];
//    [hotspot2 addSubview: hotspotMark2];
//    [self.view addSubview: hotspot2];
//    hotspot2.tag = 2;
//    [_arr_hotspotsArray addObject: hotspot2];
//    [self addGestureToHotspots:hotspot2];
}

-(void)addGestureToHotspots:(UIView *)hotspot
{
    UITapGestureRecognizer *tapOnHotspot = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHotspot:)];
    tapOnHotspot.numberOfTapsRequired = 1;
    hotspot.userInteractionEnabled = YES;
    [hotspot addGestureRecognizer: tapOnHotspot];
    
}

-(void)tapHotspot:(UIGestureRecognizer *)gesture
{
    UIView *tappedView = gesture.view;
    //    NSLog(@"THe view is %i", (int)tappedView.tag);
    if (tappedView.tag == 1) {
        [self popUpImage];
    }
    if (tappedView.tag == 2) {
        [self loadMovie];
    }
}

-(void)popUpImage
{
    if (_uis_zoomingImg) {
        [_uis_zoomingImg removeFromSuperview];
        _uis_zoomingImg = nil;
    }
    _uis_zoomingImg = [[ebZoomingScrollView alloc] initWithFrame:CGRectMake(0.0, 0.0, 1024, 768) image:[UIImage imageNamed:@"otis-hotpost-still.png"] shouldZoom:YES];
    [_uis_zoomingImg setCloseBtn:YES];
    _uis_zoomingImg.delegate = self;
    [self.view addSubview:_uis_zoomingImg];
}

-(void)didRemove:(ebZoomingScrollView *)customClass {
    [_uis_zoomingImg removeFromSuperview];
    _uis_zoomingImg = nil;
}

-(void)loadMovie
{
//    UIButton *uib_closeMovie = [UIButton buttonWithType:UIButtonTypeCustom];
//    uib_closeMovie.frame = CGRectMake(1024-20-33, 20, 33, 33);
//    [uib_closeMovie setTitle:@"X" forState:UIControlStateNormal];
//    uib_closeMovie.titleLabel.font = [UIFont fontWithName:@"ArialMT" size:14];
//    [uib_closeMovie setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    [self.view addSubview:uib_closeMovie];
//    [uib_closeMovie addTarget:self action:@selector(closeMovie:) forControlEvents:UIControlEventTouchUpInside];
    
    NSString *url = [[NSBundle mainBundle] pathForResource:@"20140903_UTC_SCHEMATIC_ANIMATION_REV"
                                                    ofType:@"m4v"];
    
    if (_avPlayer) {
        [_avPlayerLayer removeFromSuperlayer];
        _avPlayerLayer = nil;
        _avPlayer = nil;
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
    _avPlayer = [AVPlayer playerWithURL:[NSURL fileURLWithPath:url]] ;
    _avPlayerLayer = [AVPlayerLayer playerLayerWithPlayer:_avPlayer];
    
    _avPlayerLayer.frame = CGRectMake(0.0, 0.0, 1024, 768);
    _avPlayerLayer.backgroundColor = [UIColor blackColor].CGColor;
//    [self.view.layer insertSublayer:_avPlayerLayer below:uib_closeMovie.layer];
    [self.view.layer insertSublayer: _avPlayerLayer below:_uib_back.layer];
    
    [_avPlayer play];
    
    _avPlayer.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:[_avPlayer currentItem]];
}

- (void)playerItemDidReachEnd:(NSNotification *)notification {
//    AVPlayerItem *p = [notification object];
//    [p seekToTime:kCMTimeZero];
    [self closeMovie];
}

-(void)closeMovie
{
//    UIButton *tappedBtn = sender;
//    [tappedBtn removeFromSuperview];
//    tappedBtn = nil;
    [_avPlayerLayer removeFromSuperlayer];
    _avPlayerLayer = nil;
    
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
