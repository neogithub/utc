//
//  SettingViewController.m
//  LangPicker
//
//  Created by Xiaohe Hu on 6/24/15.
//  Copyright (c) 2015 Xiaohe Hu. All rights reserved.
//

#import "SettingViewController.h"
#import "SettingTableViewController.h"
#import "TSLanguageManager.h"
#import "LanguageTableViewController.h"
#import "UIApplication+AppVersion.h"
@interface SettingViewController () <UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning>
{
    UINavigationController      *navVC;
    UIView                      *uiv_settingContainer;
    NSMutableArray              *arr_seetingItem;
}
@end

@implementation SettingViewController

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.modalPresentationStyle = UIModalPresentationCustom;
        self.transitioningDelegate = self;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectedLanguage:) name:@"selectedLanguage" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showAgreement:) name:@"selectedAgreement" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initLanguage) name:@"initLanguage" object:nil];
    
    self.view.backgroundColor = [UIColor clearColor];
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"RLAgreementIdentifier"]) {
        [self loadLanguagePicker];
    } else {
        [self loadSettingView];
        [self createCloseBtn];
    }
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    navVC.view.frame = uiv_settingContainer.bounds;
    
}

- (void)viewDidAppear:(BOOL)animated
{
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadLanguagePicker {
    uiv_settingContainer = [[UIView alloc] initWithFrame:CGRectMake(348, 252, 328, 264)];
    uiv_settingContainer.backgroundColor = [UIColor colorWithRed:231.0/255.0 green:230.0/255.0 blue:227.0/255.0 alpha:1.0];
    [self.view addSubview: uiv_settingContainer];
    
    LanguageTableViewController *langTable = [[LanguageTableViewController alloc] init];
    langTable.initial = YES;
    navVC = [[UINavigationController alloc] initWithRootViewController: langTable];
    navVC.view.frame = uiv_settingContainer.bounds;
    [uiv_settingContainer addSubview: navVC.view];
    navVC.navigationBar.barTintColor =  [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"setting_title.png"]];
    navVC.navigationBar.topItem.title = [TSLanguageManager localizedString:@"Language"];
    [navVC.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
}

- (void)initLanguage {
    [self dismissViewControllerAnimated:YES completion:^(void){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"finishedLang" object:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"showAgreement" object:nil];
    }];
}

- (void)loadSettingView
{
    uiv_settingContainer = [[UIView alloc] initWithFrame:CGRectMake(348, 252, 328, 264)];
    uiv_settingContainer.backgroundColor = [UIColor colorWithRed:231.0/255.0 green:230.0/255.0 blue:227.0/255.0 alpha:1.0];
    [self.view addSubview: uiv_settingContainer];
    
    
    // Setting table's data (items)
    arr_seetingItem = [[NSMutableArray alloc]initWithObjects:
                       [TSLanguageManager localizedString:@"Language"],
                       [TSLanguageManager localizedString:@"Info"],
                       [TSLanguageManager localizedString:@"License_agreement"],
                       nil];
    
    
    SettingTableViewController *settingTable = [[SettingTableViewController alloc] init];
    settingTable.arr_settingItems = [[NSArray alloc] initWithArray:arr_seetingItem];
    navVC = [[UINavigationController alloc] initWithRootViewController: settingTable];
    navVC.view.frame = uiv_settingContainer.bounds;
//    settingTable.tableView.frame = CGRectMake(10.0, 10.0, uiv_settingContainer.frame.size.width-20, uiv_settingContainer.frame.size.height);
    [uiv_settingContainer addSubview: navVC.view];
    navVC.navigationBar.barTintColor =  [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"setting_title.png"]];
    navVC.navigationBar.topItem.title = [TSLanguageManager localizedString:@"Setting"];
    [navVC.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    
    UIView *uiv_clear = [[UIView alloc] initWithFrame:self.view.bounds];
    uiv_clear.backgroundColor = [UIColor clearColor];
    [self.view insertSubview:uiv_clear belowSubview:uiv_settingContainer];
    UITapGestureRecognizer *tapClearArea = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeSetting:)];
    uiv_clear.userInteractionEnabled = YES;
    [uiv_clear addGestureRecognizer: tapClearArea];
    
//    UILabel *uil_Ver = [[UILabel alloc] initWithFrame:CGRectMake(114.0, 240, 100, 20)];
//    uil_Ver.text = [NSString stringWithFormat:@"v%@",[UIApplication appVersion]];
//    [uil_Ver setFont:[UIFont systemFontOfSize:12]];
//    [uil_Ver setTextColor:[UIColor grayColor]];
//    [uil_Ver setTextAlignment:NSTextAlignmentCenter];
//    [uiv_settingContainer addSubview: uil_Ver];
}

- (void)createCloseBtn
{
    UIButton *uib_close = [UIButton buttonWithType:UIButtonTypeCustom];
    uib_close.frame = CGRectMake(626, 252, 50.0, 50.0);
    [uib_close setImage:[UIImage imageNamed:@"grfx_ibt_close.png"] forState:UIControlStateNormal];
    [uib_close addTarget:self action:@selector(closeSetting:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview: uib_close];
}

- (void)closeSetting:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^(void){    }];
    
}

- (void)selectedLanguage:(NSNotification *)notification {
    NSString *language = [notification.userInfo objectForKey:@"language"];
    [[NSUserDefaults standardUserDefaults] setValue:language forKey:@"language"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if ([language isEqualToString:@"en"]) {
        [TSLanguageManager setSelectedLanguage:kLMEnglish];
    }else {
        [TSLanguageManager setSelectedLanguage:kLMChinese];
    }
    
    [self dismissViewControllerAnimated:NO completion:^(void){
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:0] forKey:@"buttontag"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"masterEvent" object:nil userInfo:userInfo];
    }];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateLanguage" object:nil userInfo:notification.userInfo];
}

- (void)showAgreement:(NSNotification *)notification {
    [self dismissViewControllerAnimated:YES completion:^(void){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"showAgreement" object:nil];
    }];
}

#pragma mark - custom modal presentation methods

-(id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return self;
}

-(id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return self;
}

-(NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.25;
}

- (BOOL)hasiOS8ScreenCoordinateBehaviour {
    if ( [[[UIDevice currentDevice] systemVersion] floatValue] < 8.0 ) return NO;
    
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    if ( UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]) &&
        screenSize.width < screenSize.height ) {
        return NO;
    }
    
    return YES;
}

-(void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController* vc1 = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController* vc2 = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView* con = [transitionContext containerView];
    UIView* v1 = vc1.view;
    UIView* v2 = vc2.view;
    
    if (vc2 == self) { // presenting
        [con addSubview:v2];
        v2.frame = v1.frame;
        
        // Set the parameters to be passed into the animation
        CGFloat duration = 0.8f;
        CGFloat damping = 0.75;
        CGFloat velocity = 0.5;
        
        // int to hold UIViewAnimationOption
        NSInteger option;
        option = UIViewAnimationCurveEaseInOut;
        
        if ([self hasiOS8ScreenCoordinateBehaviour] == YES) {
            
            self.view.center = CGPointMake(self.view.center.x, 768);
            
        } else {
            
            self.view.center = CGPointMake(768, 512);
        }
        
        v2.alpha = 0;
        v1.tintAdjustmentMode = UIViewTintAdjustmentModeDimmed;
        
        [UIView animateWithDuration:duration delay:0 usingSpringWithDamping:damping initialSpringVelocity:velocity options:option animations:^{
            v2.alpha = 1;
            v1.alpha = 0.8;
            
            CGFloat floatX = -1;
            CGFloat floatY = -1;
            
            if ([self hasiOS8ScreenCoordinateBehaviour] == YES) {
                
                self.view.center = CGPointMake(self.view.center.x, 384);
                
            } else {
                
                floatX = 384;
                floatY = 512;
                self.view.center = CGPointMake(floatX, floatY);
                
            }
            
        }completion:^(BOOL finished) {
            
            [transitionContext completeTransition:YES];
            
        }];
        
    } else { // dismissing
        [UIView animateWithDuration:0.25 animations:^{
            if ([self hasiOS8ScreenCoordinateBehaviour] == YES) {
                
                self.view.center = CGPointMake(self.view.center.x, 768);
                
            } else {
                
                self.view.center = CGPointMake(768, 512);
            }            v1.alpha = 0;
            v2.alpha=1.0;
        } completion:^(BOOL finished) {
            v2.tintAdjustmentMode = UIViewTintAdjustmentModeAutomatic;
            [transitionContext completeTransition:YES];
        }];
    }
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
