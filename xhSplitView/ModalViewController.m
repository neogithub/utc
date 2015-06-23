//
//  IBTViewController.m
//  utc
//
//  Created by Evan Buxton on 12/27/14.
//  Copyright (c) 2014 Neoscape. All rights reserved.
//

#import "ModalViewController.h"
#import "embHotSpotViewController.h"
#import "Company.h"
#import "LibraryAPI.h"
#import "NSAttributedString+RegisteredTrademark.h"
#import "UIColor+Extensions.h"

@interface ModalViewController () <UIGestureRecognizerDelegate, UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning>
{
    Company			*selectedCo;
    
}
@property (nonatomic, strong) NSArray* descStrings;
@property (nonatomic, strong) NSArray* descImgStrings;

@end

static NSString * const sustainDesc3 = @"Only company in the world to be a founding member of Green Building Councils on four continents\n\nCarrier was instrumental in launching the U.S. Green Building Council in 1993 and was the first company in the world to join the organization\n\nEngaged more than 60,000 building professionals around the world since 2010 in green building training and education\n\nFounding sponsor of the Center for Green Schools";

static NSString * const sustainImg1 = @"Screenshot 2015-01-06 14.53.17.png";

static NSString * const sustainDesc2 = @"Advanced research and technology development on energy efficiency, water reduction, ozone protection, natural refrigerants and material selection\n\nRigorous, formal review during product development process to minimize environmental footprint of products while maximizing environmental technologies\n\nFirst elevator manufacturer to certify its LEED: Gold factory, and first HVAC manufacturer to certify its LEED: Gold factory";

static NSString * const sustainImg2 = @"Screenshot 2015-01-06 14.53.23.png";

static NSString * const sustainDesc1 = @"Many of our products contribute toward satisfying prerequisites and credits under the Leadership in Energy and Environmental Design (LEED:) v4 rating system\n\nOtis high-efficiency regenerative drives can create energy through elevator and escalator movement\n\nCarrier advanced energy efficient HVAC technology\n\nAutomated Logic intelligent controls optimize building performance";

static NSString * const sustainImg3 = @"Screenshot 2015-01-06 14.48.22.png";


@implementation ModalViewController

#pragma mark - custom modal presentation
-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.modalPresentationStyle = UIModalPresentationCustom;
        self.transitioningDelegate = self;
    }
    return self;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //NSAttributedString *t = [[NSAttributedString alloc] initWithString: @"AdvanTE3C® Solutions" ];
    //NSAttributedString *g = [t addRegisteredTrademarkTo: @"AdvanTE3C: Solutions" withColor:[UIColor whiteColor] fnt:[UIFont fontWithName:@"Helvetica" size:17]];
    
  //   _uil_headerText.attributedText = g;
    
   UIFont *boldFont = [UIFont boldSystemFontOfSize:17];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:_uil_headerText.text
                                                                                         attributes:@{NSFontAttributeName:boldFont}];
    
    [attributedString setAttributes:@{NSFontAttributeName : [UIFont fontWithName:@"Helvetica" size:10],
                                      NSBaselineOffsetAttributeName : @8} range:NSMakeRange(7, 1)];
    
    [attributedString setAttributes:@{NSFontAttributeName : [UIFont fontWithName:@"Helvetica" size:10],
                                      NSBaselineOffsetAttributeName : @8} range:NSMakeRange(9, 1)];
    
    _uil_headerText.attributedText = attributedString;
    
    

    // gesture which dismisses if bg touched
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissView:)];
    gestureRecognizer.cancelsTouchesInView = NO;
    gestureRecognizer.delegate = self;
    [self.view addGestureRecognizer:gestureRecognizer];
    
    _uiiv_BG.alpha = 0.0;
    
    [_uiv_ibt setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.9]];
    
    _uib_learn.hidden = YES;
    //[self blurbackground];
    
    [self performSelector:@selector(fadeUpBG) withObject:nil afterDelay:0.75];
    
    self.descStrings = [NSArray arrayWithObjects:sustainDesc1,sustainDesc2, sustainDesc3 , nil];
    self.descImgStrings = [NSArray arrayWithObjects:sustainImg1,sustainImg2, sustainImg3 , nil];

    [_uitv_text setFont:[UIFont fontWithName:@"Arial" size:17]];
    
    [_uibCollection enumerateObjectsUsingBlock:^(UIButton *obj, NSUInteger idx, BOOL *stop) {
        obj.alpha = 1.0;
    }];

}

-(void)fadeUpBG
{
    [UIView animateWithDuration:0.33 animations:^{
        
        _uiiv_BG.alpha = 1.0;
        
    } completion:^(BOOL completed) {    } ];

}

-(IBAction)loadText:(id)sender
{
    NSLog(@"loadText");
    _uitv_sustain.text = self.descStrings[[sender tag]];
    
    NSAttributedString *t = [[NSAttributedString alloc] initWithString: _uitv_sustain.text ];
    NSAttributedString *g = [t addRegisteredTrademarkTo: _uitv_sustain.text withColor:[UIColor utcSmokeGray] fnt:[UIFont fontWithName:@"Helvetica" size:17]];
    _uitv_sustain.attributedText = g;
    
    //_uiiv_data.image = [UIImage imageNamed:self.descImgStrings[[sender tag]]];
   // [_uitv_sustain setFont:[UIFont fontWithName:@"Arial" size:17]];
    [self dimButtonAtIndex:(int)[sender tag]];
}

-(IBAction)loadIBT:(id)sender
{
    NSLog(@"loadIBT");
    NSLog(@"%@",NSStringFromCGRect(_uiv_ibt.frame));
    
    [_uibCollection enumerateObjectsUsingBlock:^(UIButton *obj, NSUInteger idx, BOOL *stop) {
        obj.alpha = 1.0;
    }];
    _uib_learn.hidden = YES;
    
    [self dimButtonAtIndex:-1];

    
    [UIView animateWithDuration:0.33 delay:0
         usingSpringWithDamping:0.8 initialSpringVelocity:0.0f
                        options:0 animations:^{
                            
                            _uiv_Text.frame = CGRectMake(0, -220, 620, 410);
                            _uitv_text.frame = CGRectMake(16, 20, 587, 410);
                            
                           // _uiv_detail.frame = CGRectMake(0, 410, 620, 410);
                           // _uiv_ibtData.frame = CGRectMake(0, 30, 620, 410);
                            
                            _uiv_logoBns.frame = CGRectMake(0, 285, 620, 100);

                           // _uiv_buttons.frame = CGRectMake(_uiv_buttons.frame.origin.x, _uiv_buttons.frame.origin.y-15, _uiv_buttons.frame.size.width, _uiv_buttons.frame.size.height);
                            
                        } completion:nil];
}


-(IBAction)loadIBTDetail:(id)sender
{
    NSLog(@"loadIBTDetail");
    
    NSLog(@"%@",NSStringFromCGRect(_uiv_ibt.frame));

    UIButton *btn = (UIButton*)sender;
    
    [_uiv_ibt insertSubview:_uiv_Text belowSubview:_uiv_header];
    _uiv_Text.frame = CGRectMake(0, 415, 620, 410);
    
    _uil_header.text = btn.titleLabel.text;
    
    [self loadText: sender];
    
    [UIView animateWithDuration:0.33 delay:0
         usingSpringWithDamping:0.8 initialSpringVelocity:0.0f
                        options:0 animations:^{
                            
                            _uiv_Text.frame = CGRectMake(0, 120, 620, 410);
                            _uitv_text.frame = CGRectMake(16, -250, 587, 410);
                            
                           // _uiv_detail.frame = CGRectMake(0, 140, 620, 410);
                            _uiv_logoBns.frame = CGRectMake(0, -3, 620, 100);
                            
                            //if (_uiv_buttons.frame.origin.y == 35) {
                           //     _uiv_buttons.frame = CGRectMake(_uiv_buttons.frame.origin.x, _uiv_buttons.frame.origin.y+15, _uiv_buttons.frame.size.width, _uiv_buttons.frame.size.height);
                          //  }
                            
                            _uiiv_arrow.frame = CGRectMake(btn.center.x + 10 , 9, 21, 11);

                           
                            
                        } completion:nil];
    
    _uib_learn.hidden = NO;
    
    NSLog(@"tag %li", (long)[sender tag]);
    
  //  [self dimButtonAtIndex:(int)[sender tag]];

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
    for (UIButton *btn in _uibCollection) {
        btn.layer.borderColor = [UIColor colorWithWhite:1.0 alpha:0.5].CGColor;
        btn.layer.borderWidth = 1.0;
        [btn setBackgroundColor:[UIColor colorWithRed:118.0f/255.0f green:193.0f/255.0f blue:136.0f/255.0f alpha:1.0]];
    }
    
    NSLog(@"index %i",index);
    [_uibCollection enumerateObjectsUsingBlock:^(UIButton *obj, NSUInteger idx, BOOL *stop) {
        NSLog(@"dimButtonAtIndex");
       // btn.alpha = 1.0;
        if (obj.tag == index) {
            NSLog(@"found!");

                obj.layer.borderColor = [UIColor colorWithWhite:1.0 alpha:0.0].CGColor;
                obj.layer.borderWidth = 1.0;
            [obj setBackgroundColor:[UIColor clearColor]];
            
            //Assigning YES to the stop variable is the equivalent of calling "break" during fast enumeration
            //obj.alpha = 0.35;
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

- (BOOL)hasiOS8ScreenCoordinateBehaviour {
    if ( [[[UIDevice currentDevice] systemVersion] floatValue] < 8.0 ) return NO;
    
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    if ( UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]) &&
        screenSize.width < screenSize.height ) {
        return NO;
    }
    
    return YES;
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
        
        if ([self hasiOS8ScreenCoordinateBehaviour] == YES) {
            
            self.view.center = CGPointMake(self.view.center.x, 768);
            
        } else {
            
            self.view.center = CGPointMake(768, 512);
        }
        
        v2.alpha = 0;
        v1.tintAdjustmentMode = UIViewTintAdjustmentModeDimmed;
        
        [UIView animateWithDuration:duration delay:0 usingSpringWithDamping:damping initialSpringVelocity:velocity options:option animations:^{
            v2.alpha = 1;
            v1.alpha = 0.8;
            
            CGFloat floatX = -1;
            CGFloat floatY = -1;
            
            if ([self hasiOS8ScreenCoordinateBehaviour] == YES) {
                
                self.view.center = CGPointMake(self.view.center.x, 384);
                
            } else {
                
                floatX = 384;
                floatY = 512;
                self.view.center = CGPointMake(floatX, floatY);
                
            }
            
        }completion:^(BOOL finished) {
            
            [transitionContext completeTransition:YES];
            
        }];
        
    } else { // dismissing
        [UIView animateWithDuration:0.25 animations:^{
            if ([self hasiOS8ScreenCoordinateBehaviour] == YES) {
                
                self.view.center = CGPointMake(self.view.center.x, 768);
                
            } else {
                
                self.view.center = CGPointMake(768, 512);
            }            v1.alpha = 0;
            v2.alpha=1.0;
        } completion:^(BOOL finished) {
            v2.tintAdjustmentMode = UIViewTintAdjustmentModeAutomatic;
            [transitionContext completeTransition:YES];
        }];
    }
}


@end
