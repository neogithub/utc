//
//  IBTViewController.m
//  utc
//
//  Created by Evan Buxton on 12/27/14.
//  Copyright (c) 2014 Neoscape. All rights reserved.
//

#import "IBTViewController.h"

@interface IBTViewController () <UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning>

@end

@implementation IBTViewController

#pragma mark - custom modal presentation
-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.modalPresentationStyle = UIModalPresentationCustom;
        self.transitioningDelegate = self;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // gesture which dismisses if bg touched
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissView:)];
    gestureRecognizer.cancelsTouchesInView = NO;
    gestureRecognizer.delegate = self;
    [self.view addGestureRecognizer:gestureRecognizer];
}

// gesture to dimiss is ignored when buttons are tapped
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    
    if ([touch.view isKindOfClass:[UIButton class]]){
        return NO;
    }
    
    return YES; // handle the touch
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if([self.view respondsToSelector:@selector(setTintColor:)])
    {
        self.view.tintColor = [UIColor darkGrayColor];
    }
}

-(void)dismissView:(UIGestureRecognizer*)gestureRecognizer
{
    //CGPoint touchPoint = [gestureRecognizer locationInView:self.view];
    
    //if (!CGRectContainsPoint(_uiv_searchContainer.frame, touchPoint))
    //{
        [self doDismiss:gestureRecognizer];
    //}
}

#pragma mark - dismiss vc
// dismiss the modal view from bg tap
- (IBAction)doDismiss: (id) sender {
    [self dismissViewControllerAnimated:YES completion:^{}];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - custom modal presentation methods
// ==========

-(id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return self;
}

-(id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return self;
}

// ========

-(NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.25;
}

-(void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController* vc1 = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController* vc2 = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView* con = [transitionContext containerView];
    UIView* v1 = vc1.view;
    UIView* v2 = vc2.view;
    
    if (vc2 == self) { // presenting
        [con addSubview:v2];
        v2.frame = v1.frame;
        
        // Set the parameters to be passed into the animation
        CGFloat duration = 0.8f;
        CGFloat damping = 0.75;
        CGFloat velocity = 0.5;
        
        // int to hold UIViewAnimationOption
        NSInteger option;
        option = UIViewAnimationCurveEaseInOut;
        
        self.view.center = CGPointMake(self.view.center.x, 768);
        //self.view.transform = CGAffineTransformMakeTranslation(0, -500);
        
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        
//        if([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight)
//        {
//            self.view.transform = CGAffineTransformMakeRotation(-M_PI/2);
//            
//        } else if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft) {
//            self.view.transform = CGAffineTransformMakeRotation(M_PI/2);
//        }
        
        
        v2.alpha = 0;
        v1.tintAdjustmentMode = UIViewTintAdjustmentModeDimmed;
        
        [UIView animateWithDuration:duration delay:0 usingSpringWithDamping:damping initialSpringVelocity:velocity options:option animations:^{
            v2.alpha = 1;
            v1.alpha = 0.8;
            self.view.center = CGPointMake(self.view.center.x, 384);
            
        }completion:^(BOOL finished) {
            
            [transitionContext completeTransition:YES];
            
        }];
        
    } else { // dismissing
        [UIView animateWithDuration:0.25 animations:^{
            //self.view.center = CGPointMake(512, -500);
            v1.alpha = 0;
            v2.alpha=1.0;
        } completion:^(BOOL finished) {
            v2.tintAdjustmentMode = UIViewTintAdjustmentModeAutomatic;
            [transitionContext completeTransition:YES];
        }];
    }
}


@end
