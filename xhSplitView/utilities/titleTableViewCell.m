//
//  titleTableViewCell.m
//  utc
//
//  Created by Xiaohe Hu on 9/18/14.
//  Copyright (c) 2014 Neoscape. All rights reserved.
//

#import "titleTableViewCell.h"

@implementation titleTableViewCell

- (void)awakeFromNib
{
    // Initialization code
    
    //Turn off selection highlighted
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.layer.borderColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.6].CGColor;
    self.layer.borderWidth = 0.5;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
