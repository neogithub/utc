//
//  IBTViewController.m
//  utc
//
//  Created by Evan Buxton on 12/27/14.
//  Copyright (c) 2014 Neoscape. All rights reserved.
//

#import "IBTViewController.h"
#import "embHotSpotViewController.h"
#import "Company.h"
#import "LibraryAPI.h"

@interface IBTViewController () <UIGestureRecognizerDelegate, UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning>
{
    Company			*selectedCo;
}

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
    
    _uib_learn.hidden = YES;
    //[self blurbackground];
}

-(IBAction)loadIBT:(id)sender
{
    NSLog(@"loadIBT");
    NSLog(@"%@",NSStringFromCGRect(_uiv_ibt.frame));

    [_uibCollection enumerateObjectsUsingBlock:^(UIButton *obj, NSUInteger idx, BOOL *stop) {
        obj.alpha = 1.0;
    }];
    _uib_learn.hidden = YES;
    
    [UIView animateWithDuration:0.33 delay:0
         usingSpringWithDamping:0.8 initialSpringVelocity:0.0f
                        options:0 animations:^{
                            _uiv_detail.frame = CGRectMake(0, 410, 620, 410);
                            _uiv_ibtData.frame = CGRectMake(0, 30, 620, 410);
                            _uiv_ibt.frame = CGRectMake(_uiv_ibt.frame.origin.x, _uiv_ibt.frame.origin.y+90, _uiv_ibt.frame.size.width, _uiv_ibt.frame.size.height-170);
                            
                        } completion:nil];
}


-(IBAction)loadIBTDetail:(id)sender
{
    NSLog(@"loadIBTDetail");
    
    NSLog(@"%@",NSStringFromCGRect(_uiv_ibt.frame));

    [_uiv_ibt insertSubview:_uiv_detail belowSubview:_uiv_header];
    _uiv_detail.frame = CGRectMake(0, 410, 620, 410);
    
    [UIView animateWithDuration:0.33 delay:0
         usingSpringWithDamping:0.8 initialSpringVelocity:0.0f
                        options:0 animations:^{
                            
                            _uiv_detail.frame = CGRectMake(0, 140, 620, 410);
                            _uiv_ibtData.frame = CGRectMake(0, -220, 620, 410);
                            
                            if (_uiv_ibt.frame.size.height == 410) {
                                _uiv_ibt.frame = CGRectMake(_uiv_ibt.frame.origin.x, _uiv_ibt.frame.origin.y-90, _uiv_ibt.frame.size.width, _uiv_ibt.frame.size.height+170);
                            }
                            
                        } completion:nil];
    
    _uib_learn.hidden = NO;
    
    NSLog(@"tag %li", (long)[sender tag]);
    
    [self dimButtonAtIndex:(int)[sender tag]];

}


-(IBAction)loadIBTAtDetail:(NSNumber*)i
{
    NSLog(@"%@", i);
    NSLog(@"loadIBTAtDetail");
    UIButton*btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.tag = [i integerValue];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.03 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self loadIBTDetail:btn];
    });
}

-(void)dimButtonAtIndex:(int)index
{
    NSLog(@"index %i",index);
    [_uibCollection enumerateObjectsUsingBlock:^(UIButton *obj, NSUInteger idx, BOOL *stop) {
        NSLog(@"dimButtonAtIndex");
       // btn.alpha = 1.0;
        if (obj.tag == index) {
            NSLog(@"found!");

            //Assigning YES to the stop variable is the equivalent of calling "break" during fast enumeration
            obj.alpha = 0.35;
            //*stop = YES;
            return ;
        } else {
            obj.alpha = 1.0;
        }
    }];
}

#pragma mark - Blur Background
-(void)blurbackground
{
    
    //Get a UIImage from the UIView which is dynamically sent
    CIContext *context = [CIContext contextWithOptions:nil];
    UIGraphicsBeginImageContext(self.view.bounds.size);
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //Blur the UIImage
    CIImage *imageToBlur = [CIImage imageWithCGImage:viewImage.CGImage];
    CIFilter *gaussianBlurFilter = [CIFilter filterWithName: @"CIGaussianBlur"];
    [gaussianBlurFilter setValue:imageToBlur forKey: @"inputImage"];
    [gaussianBlurFilter setValue:[NSNumber numberWithFloat: 3] forKey: @"inputRadius"];
    CIImage *resultImage = [gaussianBlurFilter valueForKey:kCIOutputImageKey];
    CGImageRef cgImage = [context createCGImage:resultImage fromRect:[imageToBlur extent]];
    UIImage* endImage = [UIImage imageWithCGImage: cgImage];
    
    //Place the UIImage in a UIImageView
    UIImageView *_blurView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    _blurView.image = endImage;
    _blurView.alpha = 0.0;
    [self.view insertSubview:_blurView belowSubview:_uiv_modalContainer];
    
    UIViewAnimationOptions options = UIViewAnimationOptionAllowUserInteraction  | UIViewAnimationOptionCurveEaseInOut;
    [UIView animateWithDuration:0.3 delay:1.0 options:options
                     animations:^{
                         _blurView.alpha = 1.0;
                     }
                     completion:^(BOOL finished){    }];
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
    CGPoint touchPoint = [gestureRecognizer locationInView:self.view];
    
    if (!CGRectContainsPoint(_uiv_ibt.frame, touchPoint))
    {
        [self doDismiss:gestureRecognizer];
    }
}

-(IBAction)loadHotSpotView:(id)sender
{
    selectedCo = [[LibraryAPI sharedInstance] getSelectedCompanyData];
    NSDictionary *catDict = [selectedCo.coibt objectAtIndex:[sender tag]];
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    embHotSpotViewController *vc = [sb instantiateViewControllerWithIdentifier:@"embHotSpotViewController"];
    vc.dict_ibt = catDict;
    vc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:vc animated:YES completion:NULL];

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

-(id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return self;
}

-(id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return self;
}

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
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        
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
