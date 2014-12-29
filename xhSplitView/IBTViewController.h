//
//  IBTViewController.h
//  utc
//
//  Created by Evan Buxton on 12/27/14.
//  Copyright (c) 2014 Neoscape. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol IBTViewControllerDelegate <NSObject>;
@end

@interface IBTViewController : UIViewController
@property (nonatomic, weak) id<IBTViewControllerDelegate> delegate;
@end
