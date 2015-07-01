//
//  LanguageTableViewController.m
//  utc
//
//  Created by Xiaohe Hu on 6/30/15.
//  Copyright (c) 2015 Neoscape. All rights reserved.
//

#import "LanguageTableViewController.h"
#import "TSLanguageManager.h"
@interface LanguageTableViewController ()

@end

@implementation LanguageTableViewController

@synthesize initial;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.view.backgroundColor = [UIColor colorWithRed:231.0/255.0 green:230.0/255.0 blue:227.0/255.0 alpha:1.0];
    self.tableView.tableFooterView = [UIView new];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self setTitle:[TSLanguageManager localizedString:@"Language"]];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self checkCurrentLanguage];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)checkCurrentLanguage {
    int index = 0;
    NSString *language = [[NSUserDefaults standardUserDefaults] valueForKey:@"language"];
    if ([language isEqualToString:@"en"]) {
        index = 0;
    } else if ([language isEqualToString:@"zh"]) {
        index = 1;
    }
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    [self.tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
    [self.tableView cellForRowAtIndexPath:indexPath].textLabel.textColor = [UIColor colorWithRed:45.0/255.0 green:122.0/255.0 blue:174.0/255.0 alpha:1.0];
    [self.tableView cellForRowAtIndexPath:indexPath].detailTextLabel.textColor = [UIColor colorWithRed:45.0/255.0 green:122.0/255.0 blue:174.0/255.0 alpha:1.0];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tableCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"tableCell"];
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
    
    cell.textLabel.textColor = [UIColor blackColor];
    cell.detailTextLabel.textColor = [UIColor lightGrayColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (indexPath.row == 0) {
        cell.textLabel.text = [TSLanguageManager localizedString:@"EN Button"];
        cell.detailTextLabel.text = [TSLanguageManager localizedString:@"EN_subtitle"];
       
    } else {
        cell.textLabel.text = [TSLanguageManager localizedString:@"ZH Button"];
        cell.detailTextLabel.text = [TSLanguageManager localizedString:@"ZH_subtitle"];
    }
    
    return cell;
}

-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSIndexPath *oldIndex = [self.tableView indexPathForSelectedRow];
    [self.tableView cellForRowAtIndexPath:oldIndex].accessoryType = UITableViewCellAccessoryNone;
    [self.tableView cellForRowAtIndexPath:oldIndex].textLabel.textColor = [UIColor blackColor];
    [self.tableView cellForRowAtIndexPath:oldIndex].detailTextLabel.textColor = [UIColor lightGrayColor];
    [self.tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
    [self.tableView cellForRowAtIndexPath:indexPath].textLabel.textColor = [UIColor colorWithRed:45.0/255.0 green:122.0/255.0 blue:174.0/255.0 alpha:1.0];
    [self.tableView cellForRowAtIndexPath:indexPath].detailTextLabel.textColor = [UIColor colorWithRed:45.0/255.0 green:122.0/255.0 blue:174.0/255.0 alpha:1.0];
    return indexPath;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (initial) {
        if (indexPath.row == 0) {
            NSLog(@"Should be english");
            [[NSUserDefaults standardUserDefaults] setValue:@"en" forKey:@"language"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [TSLanguageManager setSelectedLanguage:kLMEnglish];
        } else {
            [[NSUserDefaults standardUserDefaults] setValue:@"zh" forKey:@"language"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [TSLanguageManager setSelectedLanguage:kLMChinese];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"initLanguage" object:nil];
        return;
    } else {
        
        if (indexPath.row == 0) {
            NSDictionary *user_info = @{@"language":@"en"};
            [[NSNotificationCenter defaultCenter] postNotificationName:@"selectedLanguage" object:nil userInfo:user_info];
        } else {
            NSDictionary *user_info = @{@"language":@"zh"};
            [[NSNotificationCenter defaultCenter] postNotificationName:@"selectedLanguage" object:nil userInfo:user_info];
        }
        
        [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
    }
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
