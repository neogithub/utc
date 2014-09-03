//
//  masterViewController.h
//  xhSplitViewController
//
//  Created by Xiaohe Hu on 9/2/14.
//  Copyright (c) 2014 Neoscape. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface masterViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UINavigationController    *navigationController;
@property (nonatomic, strong) UITableView               *tableView;
@end
