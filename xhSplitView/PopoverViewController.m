//
//  PopoverViewController.m
//  PopoverDemo
//
//  Created by Arthur Knopper on 16-05-13.
//  Copyright (c) 2013 Arthur Knopper. All rights reserved.
//

#import "PopoverViewController.h"
#import "LibraryAPI.h"

@interface PopoverViewController ()

{
	CGFloat ebTableHeight;
	CGFloat ebTableSectionHeight;
}

@end

@implementation PopoverViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	ebTableSectionHeight = 25;

	_selectedCo = [[LibraryAPI sharedInstance] getSelectedCompanyData];

	self.preferredContentSize = CGSizeMake(270.0, 45*[_selectedCo.cocategories count]+ ebTableSectionHeight); //used instead

	self.tableView.tableHeaderView = [self headerView];
	
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//	NSString *myHeader = @"Fire Safety Products";
//	return myHeader;
//}

//- (CGSize)tableView:(UITableView *)tableView sizeForHeaderLabelInSection:(NSInteger)section
//{
//	NSString *text = [self tableView:tableView titleForHeaderInSection:section];
//	
//	CGSize constraint = CGSizeMake(self.view.frame.size.width - 10 - 10, 60);
//	return [text sizeWithFont:[UIFont fontWithName:@"Helvetica-Bold" size:12] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
//}

//-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//	
//	
//	return [self tableView:tableView sizeForHeaderLabelInSection:section].height + 10 + 10;
//	
//	
////	NSString *myHeader = @"Fire Safety Products";
////	CGSize maxSize = CGSizeMake(tableView.frame.size.width, 999999.0);
////	int height = 0;
////	
////	UIFont *f = [UIFont fontWithName:@"Helvetica-Bold" size:13];
////
////	
////	NSDictionary *attributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
////										  f, NSFontAttributeName,
////										  nil];
////
////	
////	CGRect frame = [myHeader boundingRectWithSize:maxSize
////										  options:NSStringDrawingUsesLineFragmentOrigin
////									   attributes:attributesDictionary
////										  context:nil];
////	height = frame.size.height;
////	
////	
////	return height+5;
//}

-(UIView *)headerView
{
	// Create label with section title
	UILabel *tmpTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(18, 9, 300, 20)];
	UILabel *titleLabel = tmpTitleLabel;
	titleLabel.font = [UIFont boldSystemFontOfSize:12];
	titleLabel.numberOfLines = 0;
	titleLabel.textColor = [UIColor whiteColor];
	titleLabel.shadowColor = [UIColor lightGrayColor];
	titleLabel.shadowOffset = CGSizeMake(0.0, 1.0);
	titleLabel.backgroundColor=[UIColor clearColor];
	titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
	//titleLabel.text = @"Fire Safety Products";
	titleLabel.text = _selectedCo.coinfoname;
	
	NSLog(@"%@",[_selectedCo description]);
	NSLog(@"%@",_selectedCo.coinfoname);

	
	NSString *text =titleLabel.text;
	
	//Calculate the expected size based on the font and linebreak mode of label
	CGSize maximumLabelSize = CGSizeMake(self.tableView.frame.size.width,9999);
	CGSize size = [text sizeWithFont:[UIFont fontWithName:@"Helvetica-Bold" size:12] constrainedToSize:maximumLabelSize lineBreakMode:NSLineBreakByWordWrapping];
	
	//Adjust the label the the new height
	CGRect newFrame = titleLabel.frame;
	newFrame.size.height = size.height;
	titleLabel.frame = newFrame;
	
	// Create header view and add label as a subview
	UIView *vview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 34)];
	vview.backgroundColor=[UIColor colorWithRed:0.0000 green:0.4667 blue:0.7686 alpha:0.8];
	[vview addSubview:titleLabel];
	
	return vview;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_selectedCo.cocategories count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
	// Get the text so we can measure it
	
	//NSLog(@"count %lu",(unsigned long)[_selectedCo.cocategories count]);

	NSDictionary *catDict = [_selectedCo.cocategories objectAtIndex:[indexPath row]];
	
	//NSLog(@"%@",[catDict description]);
	
	NSString *newString = [catDict objectForKey:@"catName"];
	
	NSString *text = [newString stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
	
	// Get a CGSize for the width and, effectively, unlimited height
	CGSize constraint = CGSizeMake(tableView.frame.size.width - (5 * 2), 20000.0f);
	// Get the size of the text given the CGSize we just made as a constraint
	CGSize size = [text sizeWithFont:[UIFont fontWithName:@"Helvetica-Bold" size:12] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
	// Get the height of our measurement, with a minimum of 44 (standard cell size)
	
	CGFloat height = 0;
	
	//if ([_selectedCo.coname isEqualToString:@"Kidde"]) {
	//	self.preferredContentSize = CGSizeMake(220.0, 200); //used instead
	//	height = 200;
	//} else {
		height = MAX(size.height, 30.0f);
	//}
	
	
	//NSLog(@"%f",height);

	// save height for use in resizing the popover
	ebTableHeight += size.height;
	
	// return the height, with a bit of extra padding in
	return height + (5 * 2);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
		cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
		cell.textLabel.numberOfLines = 0;
		[cell.textLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:12]];
    }
	
	NSDictionary *catDict = [_selectedCo.cocategories objectAtIndex:[indexPath row]];
	
	NSString *newString = [catDict objectForKey:@"catName"];
	
	if ([newString isEqualToString:@"Integrated Building Technologies"]) {
		cell.textLabel.textColor = [UIColor colorWithRed:0.0000 green:0.4667 blue:0.7686 alpha:0.8];
	}
	
	NSString *text = [newString stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
	
    // Configure the cell...
    cell.textLabel.text=text;
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
	[_delegate selectedRow:indexPath.row withText:cell.textLabel.text];
}

@end
