//
//  PopoverViewController.h
//  PopoverDemo
//
//  Created by Arthur Knopper on 16-05-13.
//  Copyright (c) 2013 Arthur Knopper. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PopoverViewControllerDelegate <NSObject>
@required
-(void)selectedRow:(NSInteger)index;
@end

@interface PopoverViewController : UITableViewController
@property (nonatomic, weak) id<PopoverViewControllerDelegate> delegate;
@end
