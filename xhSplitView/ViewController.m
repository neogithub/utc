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
#import "otisViewController.h"
@interface ViewController ()
@property (nonatomic, strong) UIButton                          *uib_splitCtrl;
@property (nonatomic, strong) xhSplitViewController             *splitVC;
@property (nonatomic, strong) masterViewController              *masterView;
@property (nonatomic, strong) detailViewController              *detailView;
@property (nonatomic, strong) otisViewController                *otisView;
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
    [self initOtisVC];
    [self initSplitCtrl];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateDetailView:) name:@"masterEvent" object:nil];
}

-(void)initMasterVC
{
    _masterView = [[masterViewController alloc] initWithNibName:nil bundle:nil];
}

-(void)initDetailVC
{
    _detailView = [[detailViewController alloc] init];
    _detailView.view.backgroundColor = [UIColor whiteColor];
}

-(void)initOtisVC
{
    _otisView = [[otisViewController alloc] initWithNibName:nil bundle:nil];
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
    int index = [[[notification userInfo] valueForKey:@"index"] intValue];
    //    if (index%2 == 0) {
    //        _detailView.view.backgroundColor = [UIColor redColor];
    //    }
    //    else {
    //        _detailView.view.backgroundColor = [UIColor yellowColor];
    //    }
    if (index == 9) {
//        [_splitVC addDetailController:_otisView animated:NO];
//        _uib_splitCtrl.selected = YES;
        [_splitVC addDetailController:_detailView animated:NO];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"loadOtis" object:nil];
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"goIntoBuilding" object:nil];
        [self openAndCloseMaster];
    }
    else {
        _detailView.view.backgroundColor =  [UIColor colorWithRed:((float)rand() / RAND_MAX)
                                                            green:((float)rand() / RAND_MAX)
                                                             blue:((float)rand() / RAND_MAX)
                                                            alpha:1.0f];
        [_splitVC addDetailController:_detailView animated:NO];
        _uib_splitCtrl.selected = YES;
        [self openAndCloseMaster];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

