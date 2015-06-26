//
//  LangPickerViewController.m
//  LangPicker
//
//  Created by Xiaohe Hu on 6/24/15.
//  Copyright (c) 2015 Xiaohe Hu. All rights reserved.
//

#import "LangPickerViewController.h"
#import "TSLanguageManager.h"

@interface LangPickerViewController ()
{
    UIView          *uiv_container;
    UIButton        *uib_en;
    UIButton        *uib_cn;
    UILabel         *uil_title;
}
@end

@implementation LangPickerViewController

@synthesize inSetting;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    [self createLangBtn];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)createLangBtn
{
    uiv_container = [[UIView alloc] initWithFrame:CGRectMake(262, 184, 500, 400)];
    uiv_container.backgroundColor = [UIColor whiteColor];
    [self.view addSubview: uiv_container];

    uil_title = [[UILabel alloc] initWithFrame:CGRectMake(100, 20, 300, 50)];
    uil_title.backgroundColor = [UIColor greenColor];
    uil_title.text =[TSLanguageManager localizedString:@"Picker Title"];
    uil_title.textAlignment = NSTextAlignmentCenter;
    [uiv_container addSubview: uil_title];
    
    uib_en = [UIButton buttonWithType:UIButtonTypeCustom];
    uib_en.frame = CGRectMake(50, 300, 100, 30);
    uib_en.backgroundColor = [UIColor blueColor];
    [uib_en setTitle:[TSLanguageManager localizedString:@"EN Button"] forState:UIControlStateNormal];
    uib_en.titleLabel.textColor = [UIColor whiteColor];
    uib_en.titleLabel.textAlignment = NSTextAlignmentCenter;
    [uib_en addTarget:self action:@selector(tapENBtn) forControlEvents:UIControlEventTouchUpInside];
    [uiv_container addSubview: uib_en];
    
    uib_cn = [UIButton buttonWithType: UIButtonTypeCustom];
    uib_cn.frame = CGRectMake(350, 300, 100, 30);
    uib_cn.backgroundColor = [UIColor blueColor];
    [uib_cn setTitle:[TSLanguageManager localizedString:@"ZH Button"] forState:UIControlStateNormal];
    uib_cn.titleLabel.textColor = [UIColor whiteColor];
    uib_cn.titleLabel.textAlignment = NSTextAlignmentCenter;
    [uib_cn addTarget:self action:@selector(tapCNBtn) forControlEvents:UIControlEventTouchUpInside];
    [uiv_container addSubview: uib_cn];
    
    if (inSetting) {
        uiv_container.frame = CGRectMake(0.0, 40.0, 500, 360);
        uil_title.frame = CGRectMake(100, 10, 300, 50);
        uib_en.frame = CGRectMake(50.0, 200, 100, 30);
        uib_cn.frame = CGRectMake(350.0, 200, 100, 30);
    }
}

- (void)tapCNBtn
{
    [[NSUserDefaults standardUserDefaults] setValue:@"zh" forKey:@"language"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [TSLanguageManager setSelectedLanguage:kLMChinese];
    if (inSetting) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"finishedLang" object:nil];
    }
    else{
        [self dismissViewControllerAnimated:YES
                                 completion:^(void){
                                     [[NSNotificationCenter defaultCenter] postNotificationName:@"finishedLang" object:nil];
                                 }];
    }
}

- (void)tapENBtn
{
    [[NSUserDefaults standardUserDefaults] setValue:@"en" forKey:@"language"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [TSLanguageManager setSelectedLanguage:kLMEnglish];
    if (inSetting) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"finishedLang" object:nil];
    }
    else{
        [self dismissViewControllerAnimated:YES
                                 completion:^(void){
                                     [[NSNotificationCenter defaultCenter] postNotificationName:@"finishedLang" object:nil];
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
