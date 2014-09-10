//
//  ebZoomingScrollView.h
//  quadrangle
//
//  Created by Evan Buxton on 6/27/13.
//  Copyright (c) 2013 neoscape. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIScrollView+ZoomToPoint.h"

@class ebZoomingScrollView;

@protocol ebZoomingScrollViewDelegate
@optional
-(void)didRemove:(ebZoomingScrollView *)ebZoomingScrollView;
@end

@interface ebZoomingScrollView : UIView <UIScrollViewDelegate,UIGestureRecognizerDelegate>
{
	CGFloat maximumZoomScale;
	CGFloat minimumZoomScale;
}
 
- (id)initWithFrame:(CGRect)frame image:(UIImage*)thisImage shouldZoom:(BOOL)zoomable;
@property (assign) BOOL canZoom;

// define delegate property
@property (nonatomic, assign) id  delegate;
@property (nonatomic, readwrite) BOOL  closeBtn;
@property (nonatomic, strong) UIImageView *blurView;
@property (nonatomic, strong, readonly) UIScrollView *scrollView;

// define public functions
-(void)didRemove;
-(void)zoomToPoint:(CGPoint)zoomPoint withScale: (CGFloat)scale animated: (BOOL)animated;
@end
