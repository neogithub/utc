//
//  masterViewController.m
//  xhSplitViewController
//
//  Created by Xiaohe Hu on 9/2/14.
//  Copyright (c) 2014 Neoscape. All rights reserved.
//

#import "masterViewController.h"
#import "panelTableViewCell.h"

@interface masterViewController ()
{
	int selectedRow;
	UIButton * settButton;
}

@property (nonatomic, strong) NSMutableArray *arr_companies;

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
    CGFloat x = 0.5;
    CGFloat y = 0.5;
    CGFloat width = self.view.frame.size.width;
    CGFloat height = self.view.frame.size.height;
    CGRect tableFrame = CGRectMake(x, y, width, height);
    
    UITableView *tableView1 = [[UITableView alloc]initWithFrame:tableFrame];
    
    tableView1.rowHeight = 45;
    tableView1.sectionFooterHeight = 22;
    tableView1.sectionHeaderHeight = 22;
    tableView1.scrollEnabled = YES;
    tableView1.showsVerticalScrollIndicator = YES;
    tableView1.userInteractionEnabled = YES;
    tableView1.bounces = YES;
    [tableView1 setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    UIImage *tableBg = [[UIImage imageNamed:@"grfx_tableBg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(28, 0, 28, 0)];
    UIImageView *uiiv_tableBg = [[UIImageView alloc] initWithFrame:tableView1.bounds];
    [uiiv_tableBg setImage:tableBg];
    [uiiv_tableBg setContentMode:UIViewContentModeScaleToFill];
    tableView1.backgroundView = uiiv_tableBg;
    
    tableView1.delegate = self;
    tableView1.dataSource = self;
    return tableView1;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.frame = CGRectMake(0.0, 0.0, 179, 768);
    tableView = [self makeTableView];
    [self initNavi];
//    [self.view addSubview: tableView];
    self.view.backgroundColor = [UIColor blackColor];
	
	_arr_companies = [[NSMutableArray alloc] init];
	
	NSString *path = [[NSBundle mainBundle] pathForResource:
					  @"companyHotspotsData" ofType:@"plist"];
    NSMutableArray *totalDataArray = [[NSMutableArray alloc] initWithContentsOfFile:path];
	
	for (int i = 0; i < [totalDataArray count]; i++) {
        NSDictionary *hotspotItem = totalDataArray [i];
		[_arr_companies addObject:[hotspotItem objectForKey:@"fileName"]];
	}
	[_arr_companies sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
}

-(void)initNavi
{
    self.navigationController = [[UINavigationController alloc] init];
    [self.navigationController.view addSubview: tableView];
    [self.view addSubview: self.navigationController.view];
    [self.navigationController setTitle:@"HOME"];
    self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
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

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIImage *myImage = [UIImage imageNamed:@"menu header.png"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:myImage];
	[imageView setUserInteractionEnabled:YES];
    imageView.frame = CGRectMake(0,0,171,44);
	
	// create buttons
	CGFloat staticX         = 12;    // Static X for all buttons.
	CGFloat staticWidth     = 42;   // Static Width for all Buttons.
	CGFloat staticHeight    = 42;   // Static Height for all buttons.
	CGFloat staticPadding   = 14;    // Padding to add between each button.
	
	for (int i = 0; i < 3; i++)
	{
		settButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[settButton setTag:i];
		[settButton setFrame:CGRectMake((staticX + (i * (staticHeight + staticPadding))),0,staticWidth,staticHeight)];
		[settButton addTarget:self action:@selector(handleImageTap:) forControlEvents:UIControlEventTouchUpInside];
		[imageView addSubview: settButton];
	}

    return imageView;
}

-(void)handleImageTap:(id)sender
{
	//[[NSNotificationCenter defaultCenter] postNotificationName:@"masterEvent" object:[NSNumber numberWithInt:gesture.view.tag]];
	NSDictionary *userInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:[sender tag]] forKey:@"buttontag"];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"masterEvent" object:nil userInfo:userInfo];
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 44;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 12;
}

- (UITableViewCell *)tableView:(UITableView *)ttableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
        static NSString *CellIdentifier = @"Cell2";
        panelTableViewCell *cell = (panelTableViewCell *)[ttableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"panelTableViewCell" owner:self options:nil];
            for(id currentObject in topLevelObjects)
            {
                if([currentObject isKindOfClass:[panelTableViewCell class]])
                {
                    cell = (panelTableViewCell *)currentObject;
                    break;
                }
            }
			
			//advante3c gets a superscript 3
			if (indexPath.row == 0)
			{
				UIFont *boldFont = [UIFont boldSystemFontOfSize:17];
				NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:_arr_companies[indexPath.row]
																									 attributes:@{NSFontAttributeName:boldFont}];
				[attributedString setAttributes:@{NSFontAttributeName : [UIFont fontWithName:@"Helvetica" size:10]
												  , NSBaselineOffsetAttributeName : @8} range:NSMakeRange(7, 1)];
				
				cell.uil_title.attributedText = attributedString;
			} else {
				[cell.uil_title setText:_arr_companies[indexPath.row]];
			}
			
			
        return cell;
    }
    return nil;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.row != 9) {
		selectedRow = (int)indexPath.row;
		return;
	} else if (indexPath.row != selectedRow) {
		//TODO: connect to data instaed of passing hard number
		NSLog(@"The tapped cell is %i", (int)indexPath.row);
		NSDictionary* dict = [NSDictionary dictionaryWithObject:
							  [NSNumber numberWithInt:1]
														 forKey:@"buttontag"];
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

@end
