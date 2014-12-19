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
	

	_selectedCo = [[LibraryAPI sharedInstance] getSelectedCompanyData];

	self.preferredContentSize = CGSizeMake(220.0, 50*[_selectedCo.cocategories count]); //used instead

	
	
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
	CGSize size = [text sizeWithFont:[UIFont fontWithName:@"Helvetica-Bold" size:15] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
	// Get the height of our measurement, with a minimum of 44 (standard cell size)
	CGFloat height = MAX(size.height, 38.0f);
	
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
		[cell.textLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:15]];
    }
	
	NSDictionary *catDict = [_selectedCo.cocategories objectAtIndex:[indexPath row]];

	
	if ([[catDict objectForKey:@"catType"] isEqualToString:@"film"]) {
		cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon-rt-arrow.png"]];
	}
	
	NSString *newString = [catDict objectForKey:@"catName"];
	
	NSString *text = [newString stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
	
    // Configure the cell...
    cell.textLabel.text=text;
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[_delegate selectedRow:indexPath.row];
}

@end
