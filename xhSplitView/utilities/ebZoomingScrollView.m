//
//  ebZoomingScrollView.m
//  quadrangle
//
//  Created by Evan Buxton on 6/27/13.
//  Copyright (c) 2013 neoscape. All rights reserved.
//

#import "ebZoomingScrollView.h"

@interface ebZoomingScrollView () <UIScrollViewDelegate>


@property (nonatomic, strong) UIView *uiv_windowComparisonContainer;
@end

@implementation ebZoomingScrollView
@synthesize scrollView = _scrollView;
@synthesize blurView = _blurView;
@synthesize uiv_windowComparisonContainer = _uiv_windowComparisonContainer;
@synthesize canZoom;
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame image:(UIImage*)thisImage shouldZoom:(BOOL)zoomable;
{
	self = [super initWithFrame:frame];
	if (self) {
		if (nil == _scrollView) {
			_scrollView = [[UIScrollView alloc] initWithFrame:frame];
			_scrollView.delegate = self;
			[_scrollView setBackgroundColor:[UIColor whiteColor]];
			[self addSubview:_scrollView];
			
			_blurView = [[UIImageView alloc] initWithFrame:self.bounds];
			[_blurView setContentMode:UIViewContentModeScaleAspectFit];
			_blurView.image = thisImage;
			[self zoomableScrollview:self withImage:_blurView];
			
			if (zoomable==1) {
				[self unlockZoom];
			} else {
				[self lockZoom];
			}
		}
	}
	return self;
}

-(void)lockZoom
{
    maximumZoomScale = self.scrollView.maximumZoomScale;
    minimumZoomScale = self.scrollView.minimumZoomScale;
	
    self.scrollView.maximumZoomScale = 1.0;
    self.scrollView.minimumZoomScale = 1.0;
}

-(void)unlockZoom
{
	
    self.scrollView.maximumZoomScale = 4;
    self.scrollView.minimumZoomScale = 1;
	
}

-(void)setCloseBtn:(BOOL)closeBtn
{
    if (closeBtn != NO) {
        UIButton *h = [UIButton buttonWithType:UIButtonTypeCustom];
		h.frame = CGRectMake(1024-20-33, 20, 33, 33);
		[h setTitle:@"X" forState:UIControlStateNormal];
		h.titleLabel.font = [UIFont fontWithName:@"ArialMT" size:14];
		[h setBackgroundImage:[UIImage imageNamed:@"ui_btn_mm_default.png"] forState:UIControlStateNormal];
		[h setBackgroundImage:[UIImage imageNamed:@"ui_btn_mm_select.png"] forState:UIControlStateHighlighted];
		[h setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		//set their selector using add selector
		[h addTarget:self action:@selector(removeRenderScroll:) forControlEvents:UIControlEventTouchUpInside];
		[_uiv_windowComparisonContainer insertSubview:h aboveSubview:self];
		[self addSubview:h];
    }
}

-(void)zoomableScrollview:(id)sender withImage:(UIImageView*)thisImage
{
	//NSLog(@"sender tag %i",[sender tag]);
	
	_uiv_windowComparisonContainer = [[UIView alloc] initWithFrame:[self bounds]];
	
	// setup scrollview
	//_scrollView = [[UIScrollView alloc] initWithFrame:[self.view bounds]];
	self.scrollView.tag = 11000;
	//Pinch Zoom Stuff
	_scrollView.maximumZoomScale = 4.0;
	_scrollView.minimumZoomScale = 1.0;
	_scrollView.clipsToBounds = YES;
	_scrollView.delegate = self;
	_scrollView.scrollEnabled = YES;
	[_uiv_windowComparisonContainer addSubview:_scrollView];
	
	UITapGestureRecognizer *tap2Recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(zoomMyPlan:)];
	[tap2Recognizer setNumberOfTapsRequired:2];
	[tap2Recognizer setDelegate:self];
	[_scrollView addGestureRecognizer:tap2Recognizer];
	
	//NSLog(@"%@ render",renderImageView);
	
	[self.scrollView setContentMode:UIViewContentModeScaleAspectFit];
	self.scrollView.frame = CGRectMake(0, 0, 1024, 768);
	[_scrollView addSubview:thisImage];
	
//	UIButton *h = [UIButton buttonWithType:UIButtonTypeCustom];
//	h.frame = CGRectMake(1024-20-33, 20, 33, 33);
//	[h setTitle:@"X" forState:UIControlStateNormal];
//	h.titleLabel.font = [UIFont fontWithName:@"ArialMT" size:14];
//	[h setBackgroundImage:[UIImage imageNamed:@"ui_btn_mm_default.png"] forState:UIControlStateNormal];
//	[h setBackgroundImage:[UIImage imageNamed:@"ui_btn_mm_select.png"] forState:UIControlStateHighlighted];
//	[h setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//	//set their selector using add selector
//	[h addTarget:self action:@selector(removeRenderScroll:) forControlEvents:UIControlEventTouchUpInside];
//	[_uiv_windowComparisonContainer insertSubview:h aboveSubview:self];
	
	self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, self.scrollView.frame.size.height);
	
	_uiv_windowComparisonContainer.transform = CGAffineTransformMakeScale(1.5, 1.5);
	_uiv_windowComparisonContainer.alpha=0.0;
	[self addSubview:_uiv_windowComparisonContainer];
	
	UIViewAnimationOptions options = UIViewAnimationOptionAllowUserInteraction  | UIViewAnimationOptionCurveEaseInOut;
	
	[UIView animateWithDuration:0.3 delay:0.0 options:options
					 animations:^{
						 _uiv_windowComparisonContainer.alpha=1.0;
						 _uiv_windowComparisonContainer.transform = CGAffineTransformIdentity;
					 }
					 completion:^(BOOL  completed){
					 }];
	
}

-(void)zoomMyPlan:(UITapGestureRecognizer *)sender {
	
	// 1 determine which to zoom
	UIScrollView *tmp;
	
	tmp = _scrollView;
	
	CGPoint pointInView = [sender locationInView:tmp];
	
	// 2
	CGFloat newZoomScale = tmp.zoomScale * 2.0f;
	newZoomScale = MIN(newZoomScale, tmp.maximumZoomScale);
	
	// 3
	CGSize scrollViewSize = tmp.bounds.size;
	
	CGFloat w = scrollViewSize.width / newZoomScale;
	CGFloat h = scrollViewSize.height / newZoomScale;
	CGFloat x = pointInView.x - (w / 2.0f);
	CGFloat y = pointInView.y - (h / 2.0f);
	CGRect rectToZoomTo = CGRectMake(x, y, w, h);
	// 4
	
    if (tmp.zoomScale > 1.9) {
        [tmp setZoomScale: 1.0 animated:YES];
		
    } else if (tmp.zoomScale < 2) {
		[tmp zoomToRect:rectToZoomTo animated:YES];
		
    }
}


-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
	//return uiiv_contentBG;
	return _blurView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    UIView *subView = [scrollView.subviews objectAtIndex:0];
	
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?
    (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
	
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?
    (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
	
    subView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                                 scrollView.contentSize.height * 0.5 + offsetY);
}


-(void)removeRenderScroll:(id)sender {
	UIViewAnimationOptions options = UIViewAnimationOptionAllowUserInteraction  | UIViewAnimationOptionCurveEaseInOut;
	
	[UIView animateWithDuration:0.3 delay:0.0 options:options
					 animations:^{
						 _uiv_windowComparisonContainer.alpha=0.0;
						 _uiv_windowComparisonContainer.transform = CGAffineTransformScale(_uiv_windowComparisonContainer.transform, 0.5, 0.5);
					 }
					 completion:^(BOOL  completed){
						 [_uiv_windowComparisonContainer removeFromSuperview];
						 _uiv_windowComparisonContainer = nil;
						 [_scrollView removeFromSuperview];
						 [self didRemove];
					 }];
}

#pragma mark - Delegate methods 
-(void)didRemove {
    // send message the message to the delegate!
    [delegate didRemove:self];
}


//- (void)forwardInvocation:(NSInvocation *)anInvocation
//{
//    if ([self.scrollView respondsToSelector:anInvocation.selector])
//        [anInvocation invokeWithTarget:self.scrollView];
//    else
//        [super forwardInvocation:anInvocation];
//}


@end