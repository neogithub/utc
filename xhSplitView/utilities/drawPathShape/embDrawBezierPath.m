//
//  embDrawPath.m
//  embAnimatedPath
//
//  Created by Evan Buxton on 12/12/13.
//  Copyright (c) 2013 neoscape. All rights reserved.
//

#import "embDrawBezierPath.h"

@implementation embDrawBezierPath

@synthesize delegate;
@synthesize arr_tappedArray;
- (void)baseInit {
	_animationSpeed = 3.0;
	_pathLineWidth = 8.0;
	_pathFillColor = [UIColor whiteColor];
	_pathStrokeColor = [UIColor whiteColor];
	_pathCapImage = nil;
	_animated = YES;
	_isTappable = YES;
	_shouldHighlight = NO;
	_isStack = NO;
	polyPaths = [[NSMutableArray alloc] init];
	arr_shapeLayers = [[NSMutableArray alloc] init];
	arr_tappedArray = [[NSMutableArray alloc] init];
    isTapped = NO;
    isCleared = NO;
    canBeCanceled = YES;
    _pathOpacity = 0.0;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self baseInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        [self baseInit];
    }
    return self;
}

#pragma mark - DELEGATE MESSAGES
-(void)embDrawBezierPathShouldRemove
{
	[self removeFromSuperview];
}

-(void)pathTappedAtIndex:(int)i
{
	NSLog(@"should %i", i);
	if ([delegate respondsToSelector:@selector(embDrawBezierPath:indexOfTapped:)])
		[delegate embDrawBezierPath:self indexOfTapped:i];
	
}

-(void)didFinishAnimatingPath {
	if ([delegate respondsToSelector:@selector(didFinishAnimatingPath:)])
		return [delegate didFinishAnimatingPath:self];
}

-(void)didFinishAllAnimations {
	if ([delegate respondsToSelector:@selector(didFinishAllAnimations:)])
		return [delegate didFinishAllAnimations:self];
}

-(void)pathAnimating:(embDrawBezierPath*)animating {
	if ([delegate respondsToSelector:@selector(pathAnimating:)])
		return [delegate pathAnimating:self];
}

-(NSString*)pathString
{
	NSString *myStr = _pathString;
	return myStr;
}

-(UIBezierPath*)myPath
{
	UIBezierPath *myStr = _myPath;
	return myStr;
}

- (void)startAnimationFromIndex:(int)index afterDelay:(CGFloat)afterDelay
{	
	CAShapeLayer *shapeLayer = [CAShapeLayer layer];
	shapeLayer.path = [self buildPath].CGPath;
	shapeLayer.strokeColor = [_pathStrokeColor CGColor];
	shapeLayer.fillColor = [_pathFillColor CGColor];
	shapeLayer.lineWidth = _pathLineWidth;
	shapeLayer.lineJoin = kCALineJoinRound;
	shapeLayer.opacity = _pathOpacity;
	[arr_shapeLayers addObject:shapeLayer];

	if (_isTappable) {
		if (canBeCanceled == NO) {
            UITapGestureRecognizer *menuFingerTap = [[UITapGestureRecognizer alloc]
                                                     initWithTarget:self
                                                     action:@selector(mainMenuTapped:)];
            [self addGestureRecognizer:menuFingerTap];
        }
        if (canBeCanceled == YES) {
            UITapGestureRecognizer *menuFingerTap = [[UITapGestureRecognizer alloc]
                                                     initWithTarget:self
                                                     action:@selector(mainMenuTappedWhitCanceled:)];
            [self addGestureRecognizer:menuFingerTap];
        }
	}
	
	[self.layer addSublayer:shapeLayer];
	self.pathLayer = shapeLayer;
	
	if (_pathCapImage) {
		UIImage *tipImage = _pathCapImage;
		CALayer *penLayer = [CALayer layer];
		penLayer.contents = (id)tipImage.CGImage;
		penLayer.anchorPoint = CGPointMake(0.5, 0.5);
		penLayer.frame = CGRectMake(0.0f, 0.0f, tipImage.size.width, tipImage.size.height);
		[_pathLayer addSublayer:penLayer];
		self.penLayer = penLayer;
	}
	
	if (!_animated) {
		shapeLayer.opacity = 1.0;
		return;
	}

	// otherwise start DRAWING!!
	CABasicAnimation *pathOpacity = [CABasicAnimation animationWithKeyPath:@"opacity"];
    pathOpacity.duration = 0.33;
	[pathOpacity setBeginTime:CACurrentMediaTime()+afterDelay];
    pathOpacity.fromValue = @(0.0f);
    pathOpacity.toValue = @(1.0f);
	pathOpacity.fillMode = kCAFillModeForwards;
	pathOpacity.removedOnCompletion = NO;
    [self.pathLayer addAnimation:pathOpacity forKey:@"opacity"];
	
    CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
	pathAnimation.delegate=self;
    pathAnimation.duration = _animationSpeed;
	[pathAnimation setBeginTime:CACurrentMediaTime()+afterDelay];
	pathAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    pathAnimation.fromValue = @(0.0f);
    pathAnimation.toValue = @(1.0f);
	[pathAnimation setValue:@"strokeEnd" forKey:@"id"];
    [self.pathLayer addAnimation:pathAnimation forKey:@"strokeEnd"];
	
	// iOS 7 breaks this so I comment out
	// DOES NOT FUNCTION RIGHT IN iOS 7
	
//	CAKeyframeAnimation *penAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
//	[penAnimation setBeginTime:CACurrentMediaTime()];
//	penAnimation.duration = _animationSpeed;
//	[penAnimation setBeginTime:CACurrentMediaTime()+afterDelay];
//	penAnimation.path = self.pathLayer.path;
//	penAnimation.calculationMode = kCAAnimationPaced;
//	penAnimation.rotationMode = kCAAnimationRotateAuto;
//	penAnimation.fillMode = kCAFillModeForwards;
//	penAnimation.removedOnCompletion = NO;
//	penAnimation.delegate = self;
//	[self.penLayer addAnimation:penAnimation forKey:@"position"];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    if([[anim valueForKey:@"id"] isEqual:@"strokeEnd"]) {
        NSLog(@"strokeEnd finished");
		[self didFinishAnimatingPath];
		pathCompleted++;
		[self checkFinished];
    }
}

-(void)animationDidStart:(CAAnimation *)anim {
	[self pathAnimating:self];
}

-(void)checkFinished {
	NSLog(@"%i",pathCompleted);
	NSLog(@"%i",arr_shapeLayers.count);
	
	if (pathCompleted == arr_shapeLayers.count) {
		[self didFinishAllAnimations];
	}
}

-(void)fadePaths
{
	[UIView animateWithDuration:0.33
					 animations:^{
						 
						 [polyPaths enumerateObjectsUsingBlock:^(UIBezierPath *obj, NSUInteger idx, BOOL *stop) {
							 // clear already highlighted
							 for (int i=0; i<[arr_shapeLayers count]; i++) {
								 CAShapeLayer *myShapeLayer = [CAShapeLayer layer];
								 myShapeLayer = arr_shapeLayers[idx];
								 myShapeLayer.path = obj.CGPath;
								 myShapeLayer.fillColor = [[UIColor clearColor] CGColor];
								 myShapeLayer.strokeColor = [[UIColor clearColor] CGColor];
								 myShapeLayer.opacity = 1.0;
							 }
						 }];
						 
					 }
					 completion:^(BOOL  completed){
						 [UIView animateWithDuration:0.3
										  animations:^{ }
										  completion:^(BOOL  completed){  }];}];
	
}

-(void)pulseFill
{
   	[UIView animateWithDuration:0.33
                     animations:^{
                         
                         [polyPaths enumerateObjectsUsingBlock:^(UIBezierPath *obj, NSUInteger idx, BOOL *stop) {
                             // clear already highlighted
                             for (int i=0; i<[arr_shapeLayers count]; i++) {
                                 CAShapeLayer *myShapeLayer = [CAShapeLayer layer];
                                 myShapeLayer = arr_shapeLayers[idx];
                                 myShapeLayer.path = obj.CGPath;
                                // myShapeLayer.fillColor = [[UIColor clearColor] CGColor];
                                 //myShapeLayer.strokeColor = [[UIColor redColor] CGColor];
                                 myShapeLayer.opacity = 0.0;
                                 
                                 
                                    CABasicAnimation *theAnimation;
                                    // CAShapeLayer *pplayer = [CAShapeLayer alloc];
                                 //   pplayer.path = myPath.CGPath;
                                 
                                     theAnimation=[CABasicAnimation animationWithKeyPath:@"opacity"];
                                     theAnimation.duration=1.25;
                                     theAnimation.repeatCount=HUGE_VAL;
                                     theAnimation.autoreverses=YES;
                                 theAnimation.fromValue=[NSNumber numberWithFloat:0.0];
                                     theAnimation.toValue=[NSNumber numberWithFloat:0.35];
                                     [myShapeLayer addAnimation:theAnimation forKey:@"animateOpacity"];
                                 
                             }
                         }];
                         
                     }
                     completion:^(BOOL  completed){
                         [UIView animateWithDuration:0.3
                                          animations:^{ }
                                          completion:^(BOOL  completed){  }];}];
}

//-(void)highlightSingleFromParent:(int)index
//{
//	CAShapeLayer *myShapeLayer = [CAShapeLayer layer];
//	myShapeLayer = arr_shapeLayers[index];
//	UIBezierPath*patth = polyPaths[index];
//	myShapeLayer.path = patth.CGPath;
//	myShapeLayer.fillColor = [[UIColor redColor] CGColor];
//	myShapeLayer.strokeColor = _pathStrokeColor.CGColor;
//	myShapeLayer.opacity = 0.5;
//	
//	[arr_tappedArray addObject:[NSNumber numberWithInteger:index]];
//}
//
//-(void)clearSingleTapped:(int)idx
//{
//    CAShapeLayer *myShapeLayer = [CAShapeLayer layer];
//    myShapeLayer = arr_shapeLayers[idx];
//    UIBezierPath *obj = polyPaths[idx];
//    myShapeLayer.path = obj.CGPath;
//    
//	[arr_tappedArray removeObjectAtIndex:idx];
//	myShapeLayer.fillColor = [[UIColor clearColor] CGColor];
//	myShapeLayer.opacity = 0.5;
//	NSLog(@"Tapped before!!!");
//}

-(void)tmpHighlighted:(int)index
{
//	NSLog(@"The highlighted index should be %i", index);
//    [polyPaths enumerateObjectsUsingBlock:^(UIBezierPath *obj, NSUInteger idx, BOOL *stop) {
//		// clear already highlighted
//		for (int i=0; i<[arr_shapeLayers count]; i++) {
//			CAShapeLayer *myShapeLayer = [CAShapeLayer layer];
//			myShapeLayer = arr_shapeLayers[idx];
//			myShapeLayer.path = obj.CGPath;
//			myShapeLayer.fillColor = [[UIColor clearColor] CGColor];
//			myShapeLayer.strokeColor = _pathStrokeColor.CGColor;
//			myShapeLayer.opacity = 1.0;
//		}
//	}];
    
	CAShapeLayer *myShapeLayer = [CAShapeLayer layer];
	myShapeLayer = arr_shapeLayers[index];
	UIBezierPath*patth = polyPaths[index];
	myShapeLayer.path = patth.CGPath;
	myShapeLayer.fillColor = [[UIColor whiteColor] CGColor];
	myShapeLayer.strokeColor = _pathStrokeColor.CGColor;
	myShapeLayer.opacity = 0.5;
}


-(void)highlightFromParent:(int)index
{
	NSLog(@"The highlighted index should be %i", index);
    [polyPaths enumerateObjectsUsingBlock:^(UIBezierPath *obj, NSUInteger idx, BOOL *stop) {
		// clear already highlighted
		for (int i=0; i<[arr_shapeLayers count]; i++) {
			CAShapeLayer *myShapeLayer = [CAShapeLayer layer];
			myShapeLayer = arr_shapeLayers[idx];
			myShapeLayer.path = obj.CGPath;
			myShapeLayer.fillColor = [[UIColor clearColor] CGColor];
			myShapeLayer.strokeColor = _pathStrokeColor.CGColor;
			myShapeLayer.opacity = 1.0;
		}
	}];
	
	CAShapeLayer *myShapeLayer = [CAShapeLayer layer];
	myShapeLayer = arr_shapeLayers[index];
	UIBezierPath*patth = polyPaths[index];
	myShapeLayer.path = patth.CGPath;
	myShapeLayer.fillColor = [[UIColor whiteColor] CGColor];
	myShapeLayer.strokeColor = _pathStrokeColor.CGColor;
	myShapeLayer.opacity = 0.5;
}

-(void)highlightFromParent:(int)index andTappedArray:(NSMutableArray *)tappedArray
{
	[polyPaths enumerateObjectsUsingBlock:^(UIBezierPath *obj, NSUInteger idx, BOOL *stop) {
		// clear already highlighted
		for (int i=0; i<[arr_shapeLayers count]; i++) {
            
            CAShapeLayer *myShapeLayer = [CAShapeLayer layer];
			myShapeLayer = arr_shapeLayers[idx];
			myShapeLayer.path = obj.CGPath;
            myShapeLayer.opacity = 0.5;
            myShapeLayer.fillColor = [[UIColor clearColor] CGColor];
            
            for (int j = 0; j < [tappedArray count]; j++) {
                int index = [tappedArray[j] intValue];
                if ((int)idx == index) {
                    myShapeLayer.fillColor = [[UIColor whiteColor] CGColor];
//                    NSLog(@"all the items in array is %i", index);
                }
            }
		}
	}];
	
	CAShapeLayer *myShapeLayer = [CAShapeLayer layer];
	myShapeLayer = arr_shapeLayers[index];
	UIBezierPath*patth = polyPaths[index];
	myShapeLayer.path = patth.CGPath;
	myShapeLayer.fillColor = [[UIColor whiteColor] CGColor];
	myShapeLayer.opacity = 0.8;
}

-(void)clearHighlightedPart
{
    //CLEAR ALL!!!
    [polyPaths enumerateObjectsUsingBlock:^(UIBezierPath *obj, NSUInteger idx, BOOL *stop) {
		// clear already highlighted
		for (int i=0; i<[arr_shapeLayers count]; i++) {
			CAShapeLayer *myShapeLayer = [CAShapeLayer layer];
			myShapeLayer = arr_shapeLayers[idx];
			myShapeLayer.path = obj.CGPath;
			myShapeLayer.fillColor = [[UIColor clearColor] CGColor];
			myShapeLayer.opacity = 0.5;
		}
	}];
    for (int j = 0 ; j < [arr_tappedArray count]; j++) {
        CAShapeLayer *myShapeLayer = [CAShapeLayer layer];
        int index = [arr_tappedArray[j] intValue];
        myShapeLayer = arr_shapeLayers[index];
        UIBezierPath *obj = polyPaths[index];
        myShapeLayer.path = obj.CGPath;
        myShapeLayer.fillColor = [[UIColor whiteColor] CGColor];
        myShapeLayer.opacity = 0.5;
    }
	
	//[arr_tappedArray removeAllObjects];
	//isTapped = NO;
    
}
-(void)clearAllHilightedPart
{
    //CLEAR ALL!!!
    [polyPaths enumerateObjectsUsingBlock:^(UIBezierPath *obj, NSUInteger idx, BOOL *stop) {
		// clear already highlighted
		for (int i=0; i<[arr_shapeLayers count]; i++) {
			CAShapeLayer *myShapeLayer = [CAShapeLayer layer];
			myShapeLayer = arr_shapeLayers[idx];
			myShapeLayer.path = obj.CGPath;
			myShapeLayer.fillColor = [[UIColor clearColor] CGColor];
			myShapeLayer.opacity = 0.5;
		}
	}];
}
-(void)mainMenuTapped:(UIGestureRecognizer*)recognizer
{
	CGPoint touchPoint = [recognizer locationInView: self];
	//[self fadePaths];
	[polyPaths enumerateObjectsUsingBlock:^(UIBezierPath *obj, NSUInteger idx, BOOL *stop) {
		if( [obj containsPoint:touchPoint] ){
			
			[self pathTappedAtIndex:(int)idx];
			
			if (_shouldHighlight) {
				CAShapeLayer *myShapeLayer = [CAShapeLayer layer];
				myShapeLayer = arr_shapeLayers[idx];
				myShapeLayer.path = obj.CGPath;
				myShapeLayer.fillColor = [[[UIColor whiteColor] colorWithAlphaComponent:0.5] CGColor];
				myShapeLayer.strokeColor = [[UIColor whiteColor] CGColor] ;
				myShapeLayer.opacity = 1.0;
			}

			return;
		}
	}];
}

-(void)mainMenuTappedWhitCanceled:(UIGestureRecognizer*)recognizer
{
	CGPoint touchPoint = [recognizer locationInView: self];
	//NSLog(@"tapped");

	
	[polyPaths enumerateObjectsUsingBlock:^(UIBezierPath *obj, NSUInteger idx, BOOL *stop) {
		if( [obj containsPoint:touchPoint] ){
						
			// NO TAP ON LOBBY SHAPE - THERE IS A UIBUTTON
			// THAT MESSAGES DELEGATE FOR LOBBY
			if ((idx == 11) && ( _isStack == YES)) {

				NSLog(@"return");
				return;
			} else {
				
				if (!_allowsMultipleSelection) {
					[self clearAllHilightedPart];
				}
				
				[self pathTappedAtIndex:(int)idx];
				[self clearTapped:(int)idx];
				if (isCleared == NO) {
					[self hilitedTapped:(int)idx];
				}
			}
        }
	}];
}

-(void)hilitedTapped:(int)idx
{
    CAShapeLayer *myShapeLayer = [CAShapeLayer layer];
    myShapeLayer = arr_shapeLayers[idx];
    UIBezierPath *obj = polyPaths[idx];
    myShapeLayer.path = obj.CGPath;
    
	
	[arr_tappedArray addObject:[NSNumber numberWithInteger:idx]];
	myShapeLayer.fillColor = [[UIColor whiteColor] CGColor];
	myShapeLayer.opacity = 0.5;
	//            NSLog(@"First tapped!!");
}

-(void)clearTapped:(int)idx
{
    isCleared = NO;
    NSLog(@"cleartapped %i",idx);
    CAShapeLayer *myShapeLayer = [CAShapeLayer layer];
    myShapeLayer = arr_shapeLayers[idx];
    UIBezierPath *obj = polyPaths[idx];
    myShapeLayer.path = obj.CGPath;
	
    if (isTapped == YES)
    {
		NSLog(@"The tapped array is %@", arr_tappedArray);
        for (int i = 0; i < [arr_tappedArray count]; i++)
        {
            int index = [arr_tappedArray[i] intValue];
            
            if (idx == index)
            {
				if (!_allowsMultipleSelection) {
					[arr_tappedArray removeAllObjects];
				} else {
					[arr_tappedArray removeObjectAtIndex:i];
				}
				
                myShapeLayer.fillColor = [[UIColor clearColor] CGColor];
                myShapeLayer.opacity = 0.5;
				NSLog(@"Tapped before!!!");
                if ([arr_tappedArray count] == 0)
                {
                    isTapped = NO;
                }
                isCleared = YES;
            } else {
				NSLog(@"new selection made");
				// used in blockviewcontroller
				if (!_allowsMultipleSelection) {
					[arr_tappedArray removeAllObjects];
				}
			}
        }
    }
    else
    {
		//[arr_tappedArray removeAllObjects];
		[arr_tappedArray addObject:[NSNumber numberWithInteger:idx]];
        myShapeLayer.fillColor = [[UIColor whiteColor] CGColor];
        myShapeLayer.opacity = 0.5;
        isTapped = YES;
		NSLog(@"Should add the obj %@", [arr_tappedArray description]);
        isCleared = YES;
    }
}

#pragma mark - utility
- (UIBezierPath *)buildPath {

	UIBezierPath *path = nil;
	if(!path){
		path = [UIBezierPath bezierPath];
		path = _myPath;
	}
	
	[polyPaths addObject:path];
    return path;
}

@end
