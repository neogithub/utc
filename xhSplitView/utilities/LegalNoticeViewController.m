//
//  LegalNoticeViewController.m
//  utc
//
//  Created by Xiaohe Hu on 7/1/15.
//  Copyright (c) 2015 Neoscape. All rights reserved.
//

#import "LegalNoticeViewController.h"
#import "TSLanguageManager.h"
@interface LegalNoticeViewController ()
@property (strong, nonatomic)   UITextView  *uitv_notices;
@end

@implementation LegalNoticeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self setTitle:[TSLanguageManager localizedString:@"Info"]];
    
    self.view.backgroundColor = [UIColor colorWithRed:231.0/255.0 green:230.0/255.0 blue:227.0/255.0 alpha:1.0];
    _uitv_notices = [[UITextView alloc] initWithFrame:CGRectMake(10.0, 55.0, self.view.frame.size.width-20, self.view.frame.size.height-65)];
    _uitv_notices.backgroundColor = [UIColor whiteColor];
//    _uitv_notices.contentInset = UIEdgeInsetsMake(-40, 0, 0, 0);
//    _uitv_notices.scrollIndicatorInsets = UIEdgeInsetsMake(-40, 0, 0, 0);
    _uitv_notices.editable = NO;
    _uitv_notices.selectable = NO;
    _uitv_notices.text = [TSLanguageManager localizedString:@"Legal_content"];
    [self.view addSubview: _uitv_notices];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
