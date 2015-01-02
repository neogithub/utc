//
//  embTitle.h
//  utc
//
//  Created by Evan Buxton on 12/15/14.
//  Copyright (c) 2014 Neoscape. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface embTitle : UIView {
	CGFloat companyLabelWidth;
	CGFloat hotspotLabelWidth;
}

@property (nonatomic, strong) UIView                        *uiv_textBoxContainer;
@property (nonatomic, strong) UILabel                       *uil_Company;
@property (nonatomic, strong) UILabel                       *uil_HotspotTitle;
@property (nonatomic, strong) UILabel                       *uil_textSection;
@property (nonatomic, strong) NSString						*appendString;
@property CGFloat backButtonWidth;
@property CGFloat backButtonX;

-(id)initWithFrame:(CGRect)frame withText:(NSString*)text startX:(CGFloat)startx width:(CGFloat)widthx;
-(void)setHotSpotTitle:(NSString *)string;
-(void)appendHotSpotTitle:(NSString *)string;
-(void)removeHotspotTitle;
-(void)removeCompanyTitle;

@end
