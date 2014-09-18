//
//  panelTableViewCell.m
//  utc
//
//  Created by Xiaohe Hu on 9/18/14.
//  Copyright (c) 2014 Neoscape. All rights reserved.
//

#import "panelTableViewCell.h"

@implementation panelTableViewCell

- (void)awakeFromNib
{
    // Initialization code
    _uiiv_arrow.hidden = YES;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    if (selected) {
        [_uil_title setTextColor:[UIColor colorWithRed:103.0/255.0 green:184.0/255.0 blue:205.0/255.0 alpha:1.0]];
        _uiiv_arrow.hidden = NO;
        self.layer.borderColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.6].CGColor;
        self.layer.borderWidth = 0.5;
    }
    else {
        [_uil_title setTextColor: [UIColor whiteColor]];
        _uiiv_arrow.hidden = YES;
        self.layer.borderColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.6].CGColor;
        self.layer.borderWidth = 0.5;
    }

    // Configure the view for the selected state
}

@end
