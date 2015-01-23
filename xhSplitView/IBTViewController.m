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
#import "NSAttributedString+RegisteredTrademark.h"
#import "UIColor+Extensions.h"

@interface IBTViewController () <UIGestureRecognizerDelegate, UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning>
{
    Company			*selectedCo;
    UIButton        *topBtn;
    UIButton        *midBtn;
    UIButton        *btmBtn;
    NSArray         *companies;
    NSMutableArray  *ibtCompanies;
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
    
    _uil_UIcue.transform = CGAffineTransformMakeTranslation(100, 0);
    _uil_UIcue.alpha = 0.0;

    //[self blurbackground];
    
    _uiiv_BG.alpha = 0.0;
    
    _uiiv_pointer.alpha = 0.0;

    [self performSelector:@selector(fadeUpBG) withObject:nil afterDelay:0.75];
    
    topBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    topBtn.frame = CGRectMake(381.0, 23.0, 89, 56);
    topBtn.tag = 0;
    [topBtn addTarget:self action:@selector(loadHotSpotView:) forControlEvents:UIControlEventTouchUpInside];
    [_uiv_detail addSubview:topBtn];
    
    midBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    midBtn.frame = CGRectMake(381.0, 110, 89, 56);
    midBtn.tag = 1;
    [midBtn addTarget:self action:@selector(loadHotSpotView:) forControlEvents:UIControlEventTouchUpInside];
    [_uiv_detail addSubview:midBtn];
    
    btmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    btmBtn.frame = CGRectMake(381.0, 190, 89, 56);
    btmBtn.tag = 2;
    [btmBtn addTarget:self action:@selector(loadHotSpotView:) forControlEvents:UIControlEventTouchUpInside];
    [_uiv_detail addSubview:btmBtn];
    
    [_uitv_connectText setFont:[UIFont fontWithName:@"Arial" size:17]];
    
    [_uibCollection enumerateObjectsUsingBlock:^(UIButton *obj, NSUInteger idx, BOOL *stop) {
        [obj addTarget:self action:@selector(bouncyButtonTouchDown:) forControlEvents:UIControlEventTouchDown];
        [obj addTarget:self action:@selector(bouncyButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        [obj addTarget:self action:@selector(bouncyButtonTouchUpOutside:) forControlEvents:UIControlEventTouchUpOutside];
    }];
    
    [_uib_learnTop addTarget:self action:@selector(loadHotSpotView:) forControlEvents:UIControlEventTouchUpInside];
    [_uib_learnMid addTarget:self action:@selector(loadHotSpotView:) forControlEvents:UIControlEventTouchUpInside];
    [_uib_learnBtm addTarget:self action:@selector(loadHotSpotView:) forControlEvents:UIControlEventTouchUpInside];

    ibtCompanies = [[NSMutableArray alloc] initWithObjects:topBtn,midBtn,btmBtn, nil];
    [ibtCompanies enumerateObjectsUsingBlock:^(UIButton *obj, NSUInteger idx, BOOL *stop) {
        [obj setAlpha:0.0];
    }];
    
    _uiiv_arrow.alpha = 0.0;

    [self dimButtonAtIndex:0];
}

- (void)bouncyButtonTouchDown:(id)sender
{
    UIButton *btn = (UIButton*)sender;
    [UIView animateWithDuration:0.1 animations:^{
        btn.layer.transform = CATransform3DMakeScale(0.8, 0.8, 1.0);
    }];
}

- (void)bouncyButtonTouchUpInside:(id)sender
{
    UIButton *btn = (UIButton*)sender;
    [self restoreTransformWithBounceForView:btn];
    // Perform button actions
}

- (void)bouncyButtonTouchUpOutside:(id)sender
{
    UIButton *btn = (UIButton*)sender;

    [self restoreTransformWithBounceForView:btn];
}

- (void)restoreTransformWithBounceForView:(UIView*)view
{
    [UIView animateWithDuration:0.3
                          delay:0.0
         usingSpringWithDamping:0.3
          initialSpringVelocity:1.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^
     {
         view.layer.transform = CATransform3DIdentity;
     }
                     completion:nil];
}

-(void)fadeUpBG
{
    [UIView animateWithDuration:0.33 animations:^{
        
        _uiiv_BG.alpha = 1.0;
        
    } completion:^(BOOL completed) {    } ];
    
}

-(IBAction)loadIBT:(id)sender
{
    NSLog(@"loadIBT");
    NSLog(@"%@",NSStringFromCGRect(_uiv_ibt.frame));

    _uiiv_pointer.alpha = 0.0;
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];

    [_uibCollection enumerateObjectsUsingBlock:^(UIButton *obj, NSUInteger idx, BOOL *stop) {
        obj.alpha = 1.0;
    }];
    
//    [_uibCollection enumerateObjectsUsingBlock:^(UIButton *obj, NSUInteger idx, BOOL *stop) {
//            obj.alpha = 1.0;
//            [obj.layer setBorderColor:[UIColor clearColor].CGColor];
//            [obj.layer setBorderWidth:0.0];
//    }];
    
    [self dimButtonAtIndex:(int)[sender tag]];

    
    [UIView animateWithDuration:0.33 delay:0
         usingSpringWithDamping:0.8 initialSpringVelocity:0.0f
                        options:0 animations:^{
                            _uiv_detail.frame = CGRectMake(125, 575, 575, 575);
                            _uitv_summaryText.frame = CGRectMake(137, 30, 524, 575);
                            //_uiv_ibt.frame = CGRectMake(_uiv_ibt.frame.origin.x, _uiv_ibt.frame.origin.y+90, _uiv_ibt.frame.size.width, _uiv_ibt.frame.size.height-170);
                            
                        } completion:nil];
}


-(IBAction)loadIBTDetail:(id)sender
{
   // [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(popMainLogo) object:nil];
   // [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(popLogos) object:nil];
   // [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(scaleConnectors) object:nil];
    
    
    UIButton *btn = (UIButton*)sender;

    [NSObject cancelPreviousPerformRequestsWithTarget:self];
        
        BOOL runOnce;
        
        if(runOnce == NO)
        {
            [UIView animateWithDuration:0.33 delay:1.33 options:0
                             animations:^{
                                 
                                 _uil_UIcue.transform = CGAffineTransformMakeTranslation(0, 0);
                                 _uil_UIcue.alpha = 1.0;
                                 
                             } completion:^(BOOL finished){
                                 
                                 [UIView animateWithDuration:0.33 delay:1.33 options:0
                                                  animations:^{
                                                      
                                                      _uil_UIcue.alpha = 0.5;
                                                      
                                                      
                                                  } completion:^(BOOL finished){
                                                      
                                                  }];
                                 
                                 
                             }];
            runOnce = true;
        }
    
    NSLog(@"loadIBTDetail");
    
    NSLog(@"%@",NSStringFromCGRect(_uiv_ibt.frame));
    
    //UIButton *btn = (UIButton*)sender;
    
    int sendertag = (int)[sender tag];
    
    _uib_learnMid.hidden = YES;
    _uib_learnBtm.hidden = NO;

    switch (sendertag) {
            
        case 0:
            [self loadIBT:nil];
            return;
            break;
            
        case 1:
            _uib_learnTop.frame = CGRectMake(18, 82, _uib_learnTop.frame.size.width, _uib_learnTop.frame.size.height);
            _uib_learnBtm.frame = CGRectMake(18, 148, _uib_learnTop.frame.size.width, _uib_learnTop.frame.size.height);
            break;
            
        case 2:
            _uib_learnTop.frame = CGRectMake(18, 165, _uib_learnTop.frame.size.width, _uib_learnTop.frame.size.height);
            //_uib_learnBtm.frame = CGRectMake(18, 182, _uib_learnTop.frame.size.width, _uib_learnTop.frame.size.height);
            _uib_learnBtm.hidden = YES;
            break;
            
        case 3:
            _uib_learnTop.frame = CGRectMake(18, 82, _uib_learnTop.frame.size.width, _uib_learnTop.frame.size.height);
            _uib_learnBtm.frame = CGRectMake(18, 149, _uib_learnTop.frame.size.width, _uib_learnTop.frame.size.height);
            break;
            
        case 4:
            _uib_learnTop.frame = CGRectMake(18, 82, _uib_learnTop.frame.size.width, _uib_learnTop.frame.size.height);
            _uib_learnBtm.frame = CGRectMake(18, 169, _uib_learnTop.frame.size.width, _uib_learnTop.frame.size.height);
            break;
            
        case 5:
            _uib_learnTop.frame = CGRectMake(18, 84, _uib_learnTop.frame.size.width, _uib_learnTop.frame.size.height);
            _uib_learnBtm.frame = CGRectMake(18, 149, _uib_learnTop.frame.size.width, _uib_learnTop.frame.size.height);
            _uib_learnMid.frame = CGRectMake(18, 235, _uib_learnTop.frame.size.width, _uib_learnTop.frame.size.height);
            _uib_learnMid.hidden = NO;
            break;
            
        case 6:
            _uib_learnTop.frame = CGRectMake(18, 132, _uib_learnTop.frame.size.width, _uib_learnTop.frame.size.height);
            _uib_learnBtm.frame = CGRectMake(18, 200, _uib_learnTop.frame.size.width, _uib_learnTop.frame.size.height);
            break;
            
        default:
            break;
    }
    
    NSLog(@"SHOULD NOT PASS");

    [_uiv_ibt insertSubview:_uiv_detail belowSubview:_uiv_header];
    _uiv_detail.frame = CGRectMake(125, 410, 560, 575);

    [UIView animateWithDuration:0.33 delay:0
         usingSpringWithDamping:0.8 initialSpringVelocity:0.0f
                        options:0 animations:^{
                          
                            
                            
                            _uiv_detail.frame = CGRectMake(125, 50, 560, 575);
                            _uitv_summaryText.frame = CGRectMake(137, -575, 524, 575);
                            
                           // _uib_learn.frame = CGRectMake(_uib_learn.frame.origin.x, 0, _uib_learn.frame.size.width, _uib_learn.frame.size.height);
                            
                            /*if (_uiv_ibt.frame.size.height == 410) {
                                _uiv_ibt.frame = CGRectMake(_uiv_ibt.frame.origin.x, _uiv_ibt.frame.origin.y-90, _uiv_ibt.frame.size.width, _uiv_ibt.frame.size.height+170);
                            }*/
                            
                            CGPoint originInWindowCoordinates = [_uiv_logoBns convertPoint:btn.bounds.origin fromView:btn];
                            
                            _uiiv_pointer.frame = CGRectMake(114 , originInWindowCoordinates.y+15, 11, 21);
                            _uiiv_pointer.alpha = 1.0;
                            
                        } completion:nil];
    
    NSLog(@"tag %li", (long)[sender tag]);
    
    [self dimButtonAtIndex:(int)[sender tag]];
    
    companies = @[@"Automated Logic",@"Carrier",@"Edwards",@"Interlogix",@"Lenel",@"Otis"];
    
    [[LibraryAPI sharedInstance] getSelectedCompanyNamed:companies[(int)[sender tag] - 1 ]];
    
    selectedCo = [[LibraryAPI sharedInstance] getSelectedCompanyData];
    NSDictionary *catDict = selectedCo.coibtpanel;
    //NSLog(@"%@", catDict);
    
    UIImage *img = [UIImage imageNamed:catDict[@"selectedlogo"]];
    _uiiv_logo.frame = CGRectMake(_uiiv_logo.frame.origin.x, _uiiv_logo.frame.origin.y, img.size.width , img.size.height);
    self.uiiv_logo.center = CGPointMake(CGRectGetMidX(_uiv_detail.bounds), 40);

    _uiiv_logo.image = [UIImage imageNamed:catDict[@"selectedlogo"]];
    _uiiv_arrow.image = [UIImage imageNamed:catDict[@"arrow"]];

    //_uitv_connectText.text = catDict[@"text"];

    NSAttributedString *t = [[NSAttributedString alloc] initWithString:catDict[@"text"]];
    NSAttributedString *g = [t addRegisteredTrademarkTo:catDict[@"text"] withColor:[UIColor utcSmokeGray] fnt:[UIFont fontWithName:@"Helvetica" size:14]];
    _uitv_connectText.attributedText = g;

    NSArray *connectedLogos = [catDict objectForKey:@"connections"];
    NSLog(@"logos %lu", (unsigned long)[connectedLogos count]);
    if (connectedLogos.count == 2) {
        topBtn.frame = CGRectMake(174.0, 127.0, 99, 62);
        [topBtn setBackgroundImage:[UIImage imageNamed:connectedLogos[0]] forState:UIControlStateNormal];

        midBtn.frame = CGRectMake(289.0, 127.0, 99, 62);
        [midBtn setBackgroundImage:[UIImage imageNamed:connectedLogos[1]] forState:UIControlStateNormal];
     
        midBtn.hidden = NO;
        btmBtn.hidden = YES;

    } else if (connectedLogos.count == 3) {
        topBtn.frame = CGRectMake(115.0, 127.0, 99, 62);
        [topBtn setBackgroundImage:[UIImage imageNamed:connectedLogos[0]] forState:UIControlStateNormal];
        
        midBtn.frame = CGRectMake(226.0, 127.0, 99, 62);
        [midBtn setBackgroundImage:[UIImage imageNamed:connectedLogos[1]] forState:UIControlStateNormal];
        midBtn.hidden = NO;

        btmBtn.frame = CGRectMake(338.0, 127.0, 99, 62);
        [btmBtn setBackgroundImage:[UIImage imageNamed:connectedLogos[2]] forState:UIControlStateNormal];
        btmBtn.hidden = NO;

        
    } else {
        
        topBtn.frame = CGRectMake(226.0, 128.0, 99, 62);
        [topBtn setBackgroundImage:[UIImage imageNamed:connectedLogos[0]] forState:UIControlStateNormal];

        midBtn.hidden = YES;
        btmBtn.hidden = YES;
    }
    
    [self ibtReset];
}

-(void)scaleConnectors {
    
    _uiiv_arrow.layer.anchorPoint = CGPointMake(0.5, 0);
    _uiiv_arrow.transform = CGAffineTransformMakeScale(0.01, 0.01);
    
    [UIView animateWithDuration:1.00 delay:0
         usingSpringWithDamping:0.8 initialSpringVelocity:0.0f
                        options:0 animations:^{
                            
                            _uiiv_arrow.transform = CGAffineTransformIdentity;
                            _uiiv_arrow.alpha = 1.0;
                            
                        } completion:nil];
}

-(void)ibtReset
{
    _uiiv_arrow.alpha = 0.0;
    [ibtCompanies enumerateObjectsUsingBlock:^(UIButton *obj, NSUInteger idx, BOOL *stop) {
        obj.alpha = 0.0;
    }];
   // _uiiv_logo.alpha = 0.0;
    
    [self performSelector:@selector(popMainLogo) withObject:nil afterDelay:0.33];

    [self performSelector:@selector(scaleConnectors) withObject:nil afterDelay:0.66];
    
    [self performSelector:@selector(popLogos) withObject:nil afterDelay:1.00];
}

-(void)popMainLogo
{
    [UIView animateWithDuration:0.33 delay:0
         usingSpringWithDamping:0.8 initialSpringVelocity:0.0f
                        options:0 animations:^{
                            
                            //_uiiv_logo.alpha = 1.0;

                        } completion:nil];
}

-(void)popLogos
{
    float timeDelay = 0.1;
    float duration = 0.5;
    for (int i = 0; i<(int)ibtCompanies.count; i++) {
        UIImageView *view = [ibtCompanies objectAtIndex:i];
        
        //animate the layer
        [UIView animateWithDuration:duration delay:(i+1)*timeDelay
                            options: 0
                         animations:^{
                             
                             view.alpha = 1.0;
                         } completion:^(BOOL finished){
                             
                             
                         }];
    }
    
    [self performSelector:@selector(ibtReset) withObject:nil afterDelay:10.0];

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
            [obj.layer setBorderColor:[UIColor utcBlueAlight].CGColor];
            [obj.layer setBorderWidth:5.0];
            
            //Assigning YES to the stop variable is the equivalent of calling "break" during fast enumeration
            //obj.alpha = 0.13;
            //*stop = YES;
            return ;
        } else {
            obj.alpha = 1.0;
            [obj.layer setBorderColor:[UIColor clearColor].CGColor];
            [obj.layer setBorderWidth:0.0];
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
    NSLog(@"coname%@", selectedCo.coname);

    int myTag = -1;
    
    if ([selectedCo.coname isEqualToString:@"Lenel"]) {
        myTag = (int)[sender tag];
    } else if ( ([sender tag] == 1) || ([sender tag] == 2) ){
        myTag = 1;
    } else {
        myTag = (int)[sender tag];
    }
    NSLog(@"coname tag%i", (int)[sender tag] );

    
    NSDictionary *catDict = [selectedCo.coibt objectAtIndex:myTag];
    NSLog(@"%@", catDict);

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
