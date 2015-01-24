//
//  neoHotspotView.h
//  neoHotspots
//
//  Created by Xiaohe Hu on 12/22/14.
//  Copyright (c) 2014 Xiaohe Hu. All rights reserved.
//

#import <UIKit/UIKit.h>
@class neoHotspotsView;
@protocol neoHotspotViewDelegate
typedef enum {
    CaptionAlignmentBottom,     //0
    
    CaptionAlignmentTop,        //1
    
    CaptionAlignmentLeft,       //2
    
    CaptionAlignmentRight,      //3
    
    CaptionAlignmentTopLeft,    //4
    
    CaptionAlignmentTopRight,   //5
    
    CaptionAlignmentBottomLeft, //6
    
    CaptionAlignmentBottomRight //7
    
} HotspotCaptionAlignment;
@optional
- (void)neoHotspotsView:(neoHotspotsView *)hotspot didSelectItemAtIndex:(NSInteger)index;
@end

@interface neoHotspotsView : UIView
{
    float               x_Value;
    float               y_Value;
    CGSize              labelSize;
    UIImageView         *uiiv_hotspotBG;
    UIImageView         *uiiv_arrowImg;
    UILabel             *uil_caption;
    float               arrowAngle;
}

@property (nonatomic, readwrite) BOOL                       showArrow;
@property (nonatomic, strong) id                            delegate;
@property (nonatomic, strong) NSDictionary                  *dict_rawData;
@property (nonatomic, assign) HotspotCaptionAlignment       labelAlignment;
@property (nonatomic, strong) NSString                      *contentType;
@property (nonatomic, strong) NSString                      *contentFileName;
@property (nonatomic ,strong) NSString                      *captionText;


- (id)initWithHotspotInfo:(NSDictionary *)hotspotInfo;
- (void)setLabelAlpha:(CGFloat)alpha;

@end
