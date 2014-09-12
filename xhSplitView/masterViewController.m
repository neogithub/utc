//
//  masterViewController.m
//  xhSplitViewController
//
//  Created by Xiaohe Hu on 9/2/14.
//  Copyright (c) 2014 Neoscape. All rights reserved.
//

#import "masterViewController.h"

@interface masterViewController ()
{
	int selectedRow;
}

@end

@implementation masterViewController
@synthesize tableView;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(UITableView *)makeTableView
{
    CGFloat x = 0;
    CGFloat y = 0;
    CGFloat width = self.view.frame.size.width;
    CGFloat height = self.view.frame.size.height;
    CGRect tableFrame = CGRectMake(x, y, width, height);
    
    UITableView *tableView1 = [[UITableView alloc]initWithFrame:tableFrame style:UITableViewStylePlain];
    
    tableView1.rowHeight = 45;
    tableView1.sectionFooterHeight = 22;
    tableView1.sectionHeaderHeight = 22;
    tableView1.scrollEnabled = YES;
    tableView1.showsVerticalScrollIndicator = YES;
    tableView1.userInteractionEnabled = YES;
    tableView1.bounces = YES;
    
    tableView1.delegate = self;
    tableView1.dataSource = self;
    return tableView1;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.frame = CGRectMake(0.0, 0.0, 170, 768);
    tableView = [self makeTableView];
    [self initNavi];
//    [self.view addSubview: tableView];
    self.view.backgroundColor = [UIColor blackColor];
}

-(void)initNavi
{
    self.navigationController = [[UINavigationController alloc] init];
    [self.navigationController.view addSubview: tableView];
    [self.view addSubview: self.navigationController.view];
    [self.navigationController setTitle:@"HOME"];
    [self addChildViewController: self.navigationController];
    [self.view addSubview: self.navigationController.view];
}

#pragma mark - Table view data source

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 12;
}

- (UITableViewCell *)tableView:(UITableView *)ttableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    if (indexPath.row == 9) {
        [cell.textLabel setText:[NSString stringWithFormat:@"Otis"]];
        return cell;
    }
    
    [cell.textLabel setText:[NSString stringWithFormat:@"Company %i", (int)indexPath.row]];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.row != 9) {
		return;
	} else if (indexPath.row != selectedRow) {
		
			NSLog(@"The tapped cell is %i", (int)indexPath.row);
			NSDictionary* dict = [NSDictionary dictionaryWithObject:
								  [NSNumber numberWithInt:(int)indexPath.row]
															 forKey:@"index"];
			[[NSNotificationCenter defaultCenter] postNotificationName:@"masterEvent"
																object:self
															  userInfo:dict];
	}
	
	selectedRow = (int)indexPath.row;
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
