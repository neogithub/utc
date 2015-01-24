//
//  neoHotspotView.m
//  neoHotspots
//
//  Created by Xiaohe Hu on 12/22/14.
//  Copyright (c) 2014 Xiaohe Hu. All rights reserved.
//

#import "neoHotspotsView.h"

static NSString *kFontName = @"Helvetica-Bold";
static float    kFontSize = 17.0;
static float    kGap = 10.0;

@implementation neoHotspotsView
@synthesize dict_rawData;
@synthesize labelAlignment;
@synthesize delegate;
@synthesize contentType;
@synthesize contentFileName;
@synthesize showArrow;

- (id)initWithHotspotInfo:(NSDictionary *)hotspotInfo
{
    self = [super init];
    if (self) {
        dict_rawData = [[NSDictionary alloc] initWithDictionary:hotspotInfo];
    }
    return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [self prepareData];
}

//----------------------------------------------------
#pragma mark - Read data from dictionary
//----------------------------------------------------
- (void)prepareData
{
    //Get the position of hotspot
    NSString *str_position = [[NSString alloc] initWithString:[dict_rawData objectForKey:@"xy"]];
    NSRange range = [str_position rangeOfString:@","];
    NSString *str_x = [str_position substringWithRange:NSMakeRange(0, range.location)];
    NSString *str_y = [str_position substringFromIndex:(range.location + 1)];
    x_Value = [str_x floatValue];
    y_Value = [str_y floatValue];
    
    // Get content file's name of hotspot
    contentType = [[NSString alloc] initWithString:[dict_rawData objectForKey:@"type"]];
    contentFileName = [[NSString alloc] initWithString:[dict_rawData objectForKey:@"fileName"]];

    // Get hotspot's background image and set view size same as the image
    uiiv_hotspotBG = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[dict_rawData objectForKey:@"background"]]];
    self.frame = CGRectMake(x_Value, y_Value, uiiv_hotspotBG.frame.size.width, uiiv_hotspotBG.frame.size.height);
    uiiv_hotspotBG.frame = self.bounds;
    
    // Get catpion string and create the label
    if ([dict_rawData objectForKey:@"caption"]) {
        labelSize = [[dict_rawData objectForKey:@"caption"] sizeWithAttributes:
                     @{NSFontAttributeName:
                           [UIFont fontWithName:kFontName size:kFontSize]}];
        
        [self createCaptionLabel];
        _captionText = [dict_rawData objectForKey:@"caption"];
    }

    // Create arrow image
    if (showArrow) {
        [self createArrow];
    }
    
    // Add tap gesture to hotspot
    [self addGestureToView];
}

//----------------------------------------------------
#pragma mark - Create caption label
//----------------------------------------------------

- (void)createCaptionLabel
{
    CGFloat offsetX = 0.0;
    CGFloat offsetY = 0.0;
    
    switch (labelAlignment) {
        case 0:
        {
            if (labelSize.width > uiiv_hotspotBG.frame.size.width)
            {
                offsetX = (labelSize.width - uiiv_hotspotBG.frame.size.width)/2;
            }
            else
            {
                offsetX = 0.0;
            }
            uil_caption = [[UILabel alloc] initWithFrame:CGRectMake(-offsetX, uiiv_hotspotBG.frame.size.height + kGap, labelSize.width, labelSize.height)];
            break;
        }
        case 1:
        {
            offsetY = labelSize.height + kGap;
            if (labelSize.width > uiiv_hotspotBG.frame.size.width)
            {
                offsetX = (labelSize.width - uiiv_hotspotBG.frame.size.width)/2;
            }
            else
            {
                offsetX = 0.0;
            }
            uil_caption = [[UILabel alloc] initWithFrame:CGRectMake(-offsetX, -offsetY, labelSize.width, labelSize.height)];
            break;
        }
        case 2:
        {
            offsetX = labelSize.width + kGap;
            uil_caption = [[UILabel alloc] initWithFrame:CGRectMake(-offsetX-5, (uiiv_hotspotBG.frame.size.height - labelSize.height-10)/2, labelSize.width+30, labelSize.height+10)];
            break;
        }
        case 3:
        {
            uil_caption = [[UILabel alloc] initWithFrame:CGRectMake(uiiv_hotspotBG.frame.size.width-20, (uiiv_hotspotBG.frame.size.height - labelSize.height-10)/2, labelSize.width+40, labelSize.height+10)];
            break;
        }
        case 4:
        {
            offsetX = labelSize.width + kGap;
            offsetY = labelSize.height;
            uil_caption = [[UILabel alloc] initWithFrame:CGRectMake(-offsetX, -offsetY, labelSize.width, labelSize.height)];
            break;
        }
        case 5:
        {
            offsetY = labelSize.height;
            uil_caption = [[UILabel alloc] initWithFrame:CGRectMake(uiiv_hotspotBG.frame.size.width + kGap, -offsetY, labelSize.width, labelSize.height)];
            break;
        }
        case 6:
        {
            offsetX = labelSize.width + kGap;
            uil_caption = [[UILabel alloc] initWithFrame:CGRectMake(-offsetX, uiiv_hotspotBG.frame.size.height, labelSize.width, labelSize.height)];
            break;
        }
        case 7:
        {
            uil_caption = [[UILabel alloc] initWithFrame:CGRectMake(uiiv_hotspotBG.frame.size.width + kGap, uiiv_hotspotBG.frame.size.height, labelSize.width, labelSize.height)];
            break;
        }
        default:
            break;
    }
    
    uil_caption.text = [dict_rawData objectForKey:@"caption"];
    uil_caption.font = [UIFont fontWithName:kFontName size:kFontSize];
    [uil_caption setTextAlignment:NSTextAlignmentCenter];
    uil_caption.backgroundColor = [UIColor whiteColor];
    [self addSubview: uiiv_hotspotBG];
    [self insertSubview: uil_caption belowSubview: uiiv_hotspotBG];
}

//----------------------------------------------------
#pragma mark - Create arrow image
//----------------------------------------------------

- (void)createArrow
{
    float width = uiiv_hotspotBG.frame.size.width;
    float height = uiiv_hotspotBG.frame.size.height;
    float radius = sqrtf(width*width + height*height);
    
    uiiv_arrowImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"grfx_avail_view.png"]];
    uiiv_arrowImg.frame = CGRectMake(abs(uiiv_hotspotBG.frame.size.width - uiiv_arrowImg.frame.size.width)/2 + uiiv_hotspotBG.frame.origin.x, uiiv_hotspotBG.frame.origin.y - (radius-uiiv_hotspotBG.frame.size.height) - uiiv_arrowImg.frame.size.height, uiiv_arrowImg.frame.size.width, uiiv_arrowImg.frame.size.height);
    [self addSubview: uiiv_arrowImg];
    
    if ([dict_rawData objectForKey:@"angle"]) {
        arrowAngle = [[dict_rawData objectForKey:@"angle"] floatValue];
    }
    else {
        [uiiv_arrowImg removeFromSuperview];
        return;
        //        arrowAngle = 0.0;
    }
    
    CGRect oldFrame = uiiv_arrowImg.frame;
    uiiv_arrowImg.layer.anchorPoint = CGPointMake(0.5, radius/2/uiiv_arrowImg.frame.size.height+1);
    uiiv_arrowImg.frame = oldFrame;
    
    uiiv_arrowImg.transform = CGAffineTransformMakeRotation((arrowAngle/180)*M_PI);
}

#pragma mark - Utilities
#pragma mark get width of string text
-(float)getWidthFromStringLength:(NSString*)string andFont:(UIFont*)stringfont
{
    UIFont *font = stringfont;
    NSDictionary *attributes1 = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil];
    CGFloat str_width = [[[NSAttributedString alloc] initWithString:string attributes:attributes1] size].width;
    //NSLog(@"The string width is %f", str_width);
    return str_width;
}


//----------------------------------------------------
#pragma mark - Add tap gesture to hotspot
//----------------------------------------------------

- (void)addGestureToView
{
    self.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapOnView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHotspot:)];
    tapOnView.numberOfTapsRequired = 1;
    [self addGestureRecognizer:tapOnView];
}

- (void)tapHotspot:(UIGestureRecognizer *)gesture
{
    [self.delegate neoHotspotsView:self didSelectItemAtIndex:self.tag];
}

//----------------------------------------------------
#pragma mark Make outbounded arrow and label tappable
//----------------------------------------------------

-(BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    if ( CGRectContainsPoint(uiiv_arrowImg.frame, point) || CGRectContainsPoint(uil_caption.frame, point) )
        return YES;
    
    return [super pointInside:point withEvent:event];
}

//----------------------------------------------------
#pragma mark - Make label dim
//----------------------------------------------------
-(void)setLabelAlpha:(CGFloat)alpha
{
    uil_caption.alpha = alpha;
}

// Get label's text (if there is no caption text the label won't be init)
-(void)setCaptionText:(NSString *)captionText
{
    if (captionText == nil) {
        return;
    }
    else
    {
        _captionText = captionText;
        [self initHotspotLabel];
    }
}

-(void)initHotspotLabel
{
    
    float textFontSize = 14.0f;
    UIFont *font = [UIFont fontWithName:@"Helvetica-Bold" size:textFontSize];
    
    if ([_captionText isEqualToString:@""]) {
        [uil_caption setBackgroundColor:[UIColor clearColor]];
    } else {
        [uil_caption setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.8]];
        [uil_caption.layer setBorderColor:[UIColor whiteColor].CGColor];
        [uil_caption.layer setBorderWidth:1.0];
    }
    [uil_caption setText:_captionText];
    uil_caption.textColor = [UIColor blackColor];
    uil_caption.font=font;
    [uil_caption setTextAlignment:NSTextAlignmentCenter];
    
    [self insertSubview:uil_caption belowSubview:uiiv_hotspotBG];
}

//----------------------------------------------------
#pragma mark - Clean Memory
//----------------------------------------------------

- (void)removeFromSuperview
{
    [super removeFromSuperview];
    
//    [uiiv_hotspotBG removeFromSuperview];
//    uiiv_hotspotBG = nil;
//    
//    [uiiv_arrowImg removeFromSuperview];
//    uiiv_arrowImg = nil;
//    
//    [uil_caption removeFromSuperview];
//    uil_caption = nil;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
