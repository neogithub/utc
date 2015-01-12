//
//  masterViewController.m
//  xhSplitViewController
//
//  Created by Xiaohe Hu on 9/2/14.
//  Copyright (c) 2014 Neoscape. All rights reserved.
//

#import "masterViewController.h"
#import "panelTableViewCell.h"
#import "LibraryAPI.h"
#import "Company.h"
#import "IBTViewController.h"
#import "buildingViewController.h"
#import "embHotSpotViewController.h"
#import "UIApplication+AppVersion.h"

@interface masterViewController () <IBTViewControllerDelegate>
{
	int selectedRow;
	UIButton * settButton;
	
//	NSArray *allCompanies;
	NSDictionary *currentCompanyData;
	int currentCompanyIndex;
    Company *selectedCo;
}

@property (nonatomic, strong) NSMutableArray                *arr_companies;
@property (nonatomic, strong) UIButton						*uib_ibtBtn;
@property (nonatomic, strong) UIButton						*uib_sustainBtn;
@property (nonatomic, strong) UIButton						*uib_advante3cBtn;
@property (nonatomic, strong) UIButton						*uib_helpBtn;

@end

static CGFloat yHeight = 90;

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
    
    [self initIBTButton];
    [self initSustainButton];
    [self initAdvante3cButton];
    [self initHelpButton];
    [self initVersion];
    
	currentCompanyIndex = 0;
    selectedRow = -1;
    
    [[LibraryAPI sharedInstance] getCompanies];
 
//	//2 get all companies data
	//allCompanies = [[LibraryAPI sharedInstance] getCompanies];
//	
//	//3 get just the company names
//	_arr_companies = [[LibraryAPI sharedInstance] getCompanyNames];
//	
//	// sort them alphabetically
//	[_arr_companies sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    
    _arr_companies = [[NSMutableArray alloc] initWithObjects:@"Commercial", nil];
    
    // sort them alphabetically
    [_arr_companies sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
}

-(void)initVersion
{
    UILabel *uil_Ver = [[UILabel alloc] initWithFrame:CGRectMake(39.0, 740, 100, 20)];
    uil_Ver.text = [NSString stringWithFormat:@"v%@",[UIApplication appVersion]];
    [uil_Ver setFont:[UIFont systemFontOfSize:8]];
    [uil_Ver setTextColor:[UIColor whiteColor]];
    [uil_Ver setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview: uil_Ver];
}

#pragma mark - Sustain Button
-(void)initHelpButton
{
    if (_uib_helpBtn) {
        [_uib_helpBtn removeFromSuperview];
    }
    _uib_helpBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _uib_helpBtn.frame = CGRectMake(48, 715, 85, 24);
    _uib_helpBtn.tag = 0;
    [_uib_helpBtn.titleLabel setFont:[UIFont systemFontOfSize:12]];
    [_uib_helpBtn setTitle:@"Help" forState:UIControlStateNormal];
    [_uib_helpBtn addTarget: self action:@selector(loadHelpView) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview: _uib_helpBtn];
    
    [_uib_helpBtn.layer setBorderColor:[UIColor whiteColor].CGColor];
    [_uib_helpBtn.layer setBorderWidth:1.0];
}

-(void)loadHelpView
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"showHelp" object:self];
}

#pragma mark - Sustain Button
-(void)initAdvante3cButton
{
    if (_uib_advante3cBtn) {
        [_uib_advante3cBtn removeFromSuperview];
    }
    _uib_advante3cBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _uib_advante3cBtn.frame = CGRectMake(0, yHeight, 180, 44);
    _uib_advante3cBtn.tag = 0;
    [_uib_advante3cBtn setImage: [UIImage imageNamed:@"menu_advantec.png"] forState:UIControlStateNormal];
    [_uib_advante3cBtn setImage: [UIImage imageNamed:@"menu_advantec.png"] forState:UIControlStateSelected];
    [_uib_advante3cBtn addTarget: self action:@selector(loadModalVC) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview: _uib_advante3cBtn];
}

#pragma mark - Sustain Button
-(void)initSustainButton
{
    if (_uib_sustainBtn) {
        [_uib_sustainBtn removeFromSuperview];
    }
    _uib_sustainBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _uib_sustainBtn.frame = CGRectMake(0, yHeight+44, 180, 44);
    _uib_sustainBtn.tag = 0;
    [_uib_sustainBtn setImage: [UIImage imageNamed:@"menu_sustainability.png"] forState:UIControlStateNormal];
    [_uib_sustainBtn setImage: [UIImage imageNamed:@"menu_sustainability.png"] forState:UIControlStateSelected];
    [_uib_sustainBtn addTarget: self action:@selector(loadSustainability) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview: _uib_sustainBtn];
}

-(void)loadModalVC
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"showModalVC" object:self userInfo:nil];
}

-(void)loadSustainability
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"showSustainability" object:self userInfo:nil];
}


-(IBAction)loadHotSpotView:(id)sender
{
    
    if (sender == _uib_advante3cBtn) {
        [[LibraryAPI sharedInstance] getSelectedCompanyNamed:@"AdvanTE3C"];
    } else if (sender == _uib_sustainBtn) {
        [[LibraryAPI sharedInstance] getSelectedCompanyNamed:@"Sustainability"];
    }
    
    selectedCo = [[LibraryAPI sharedInstance] getSelectedCompanyData];
    NSDictionary *catDict = [selectedCo.cocategories objectAtIndex:[sender tag]];
    
    NSLog(@" cat dict %@",catDict);
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    embHotSpotViewController *vc = [sb instantiateViewControllerWithIdentifier:@"embHotSpotViewController"];
    vc.dict_ibt = catDict;
    vc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:vc animated:YES completion:NULL];
}


#pragma mark - IBT Button
-(void)initIBTButton
{
    if (_uib_ibtBtn) {
        [_uib_ibtBtn removeFromSuperview];
    }
    _uib_ibtBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _uib_ibtBtn.frame = CGRectMake(0, yHeight+44+44, 180, 44);
    [_uib_ibtBtn setImage: [UIImage imageNamed:@"menu_utc.png"] forState:UIControlStateNormal];
    [_uib_ibtBtn setImage: [UIImage imageNamed:@"menu_utc.png"] forState:UIControlStateSelected];
    [_uib_ibtBtn addTarget: self action:@selector(notifyIBT) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview: _uib_ibtBtn];
}

#pragma mark Open Modal
-(void)notifyIBT
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"showIBT" object:nil];
    NSLog(@"loadIBT");
}

-(void)notifySustainability
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"showSustainability" object:nil];
    NSLog(@"loadSustainability");
}



#pragma mark - Init Navigation
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
	NSDictionary *userInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:(int)[sender tag]] forKey:@"buttontag"];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"masterEvent" object:nil userInfo:userInfo];
    
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 44;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [_arr_companies count];
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
			
#ifdef NEODEMO
			[cell.uil_title setText:_arr_companies[indexPath.row]];
#else
			//advante3c gets a superscript 3
//			if (indexPath.row == 0)
//			{
//				UIFont *boldFont = [UIFont boldSystemFontOfSize:17];
//				NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:_arr_companies[indexPath.row]
//																									 attributes:@{NSFontAttributeName:boldFont}];
//				[attributedString setAttributes:@{NSFontAttributeName : [UIFont fontWithName:@"Helvetica" size:10]
//												  , NSBaselineOffsetAttributeName : @8} range:NSMakeRange(7, 1)];
//				
//				cell.uil_title.attributedText = attributedString;
//			} else {
				[cell.uil_title setText:_arr_companies[indexPath.row]];
//			}
#endif
            
            cell.textLabel.font = [cell.textLabel.font fontWithSize:8];
		
        return cell;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([indexPath row] != 0) //<-----ignores touches on first cell in the UITableView
    {                        //simply change this around to suit your needs
        cell.userInteractionEnabled = NO;
        cell.textLabel.enabled = NO;
        cell.detailTextLabel.enabled = NO;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	//if ((indexPath.row != selectedRow) && (indexPath.row == 0)) { // commercial
    if (indexPath.row == 0) { // commercial
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"closeMaster" object:nil];
        
		NSLog(@"The tapped cell is %i", (int)indexPath.row);
		NSDictionary* dict = [NSDictionary dictionaryWithObject:
							  [NSNumber numberWithInt:3]
														 forKey:@"buttontag"];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"animateTransition"
															object:self
														  userInfo:dict];
	}
    selectedRow = (int)indexPath.row;
	
	//2 get company selected
	//[[LibraryAPI sharedInstance] getSelectedCompanyNamed:_arr_companies[selectedRow]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
