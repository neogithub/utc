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
@interface SettingViewController ()
{
    UINavigationController      *navVC;
    UIView                      *uiv_settingContainer;
    NSMutableArray              *arr_seetingItem;
}
@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor clearColor];
    [self loadSettingView];
    [self createCloseBtn];
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

- (void)loadSettingView
{
    uiv_settingContainer = [[UIView alloc] initWithFrame:CGRectMake(262, 184, 500, 400)];
    uiv_settingContainer.backgroundColor = [UIColor whiteColor];
    [self.view addSubview: uiv_settingContainer];
    
    
    // Setting table's data (items)
    arr_seetingItem = [[NSMutableArray alloc]initWithObjects:
                       [TSLanguageManager localizedString:@"Version"],
                       [TSLanguageManager localizedString:@"Language"],
                       nil];
    
    
    SettingTableViewController *settingTable = [[SettingTableViewController alloc] init];
    settingTable.arr_settingItems = [[NSArray alloc] initWithArray:arr_seetingItem];
    navVC = [[UINavigationController alloc] initWithRootViewController: settingTable];
    navVC.view.frame = uiv_settingContainer.bounds;
    [uiv_settingContainer addSubview: navVC.view];
    
    navVC.navigationBar.topItem.title = [TSLanguageManager localizedString:@"Setting"];
}

- (void)createCloseBtn
{
    UIButton *uib_close = [UIButton buttonWithType:UIButtonTypeCustom];
    uib_close.frame = CGRectMake(20.0, 20.0, 50.0, 50.0);
    [uib_close setTitle:@"X" forState:UIControlStateNormal];
    [uib_close addTarget:self action:@selector(closeSetting:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview: uib_close];
}

- (void)closeSetting:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^(void){ }];
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
