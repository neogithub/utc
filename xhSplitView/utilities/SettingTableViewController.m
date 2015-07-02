//
//  SettingTableViewController.m
//  LangPicker
//
//  Created by Xiaohe Hu on 6/24/15.
//  Copyright (c) 2015 Xiaohe Hu. All rights reserved.
//

#import "SettingTableViewController.h"
#import "LangPickerViewController.h"
#import "LanguageTableViewController.h"
#import "TSLanguageManager.h"
#import "LegalNoticeViewController.h"
#import "UIApplication+AppVersion.h"
@interface SettingTableViewController ()

@end

@implementation SettingTableViewController
@synthesize arr_settingItems;
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.view.backgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = [UIView new];
    UILabel *uil_Ver = [[UILabel alloc] initWithFrame:CGRectMake(114.0, 190, 100, 20)];
    uil_Ver.text = [NSString stringWithFormat:@"v%@",[UIApplication appVersion]];
    [uil_Ver setFont:[UIFont systemFontOfSize:12]];
    [uil_Ver setTextColor:[UIColor grayColor]];
    [uil_Ver setTextAlignment:NSTextAlignmentCenter];
    [self.tableView addSubview: uil_Ver];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBar.topItem.title = [TSLanguageManager localizedString:@"Setting"];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
}

- (void)viewDidAppear:(BOOL)animated
{
//    CGFloat tableBorderLeft = 10;
//    CGFloat tableBorderRight = 10;
//    
//    CGRect tableRect = self.view.frame;
//    tableRect.origin.x += tableBorderLeft; // make the table begin a few pixels right from its origin
//    tableRect.size.width -= tableBorderLeft+tableBorderRight; // reduce the width of the table
//    self.view.frame = tableRect;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (section == 0) {
        return 2;
    } else {
        return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tableCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tableCell"];
        if (indexPath.section == 0) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            UIImageView *uiiv_accessroy = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cell_accessory.png"]];
            cell.accessoryView = uiiv_accessroy;
        }
    }
    // Remove seperator inset
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    // Prevent the cell from inheriting the Table View's margin settings
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    
    // Explictly set your cell's layout margins
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    
    if (indexPath.section == 0) {
        cell.textLabel.text = arr_settingItems[indexPath.row];
    } else {
        cell.textLabel.text = arr_settingItems[2];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Load Language picker talbe
    if (indexPath.row == 0 && indexPath.section == 0) {
        LanguageTableViewController *langTable = [[LanguageTableViewController alloc] init];
        langTable.view.frame = self.view.bounds;
        [self.navigationController pushViewController:langTable animated:YES];
    }
    
    // Load Legal Notices
    if (indexPath.row == 1 && indexPath.section == 0) {
        LegalNoticeViewController *legal = [[LegalNoticeViewController alloc] init];
        legal.view.frame = self.view.bounds;
        [self.navigationController pushViewController:legal animated:YES];
    }
    
    // Load Agreement
    if (indexPath.row == 0 && indexPath.section == 1) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"selectedAgreement" object:nil];
    }
    
    
        
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
