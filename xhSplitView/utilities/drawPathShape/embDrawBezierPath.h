//
//  embDrawPath.h
//  embAnimatedPath
//
//  Created by Evan Buxton on 12/12/13.
//  Copyright (c) 2013 neoscape. All rights reserved.
//  (UIBezierPath *)buildPath from Sean Tierney

#import <UIKit/UIKit.h>
#import "embBezierPathItem.h"

@class embDrawBezierPath;

@protocol embDrawBezierPathDelegate <NSObject>
@optional
-(void)embDrawBezierPath:(embDrawBezierPath *)path indexOfTapped:(int)i;
-(void)pathAnimating:(embDrawBezierPath*)animating;
-(void)didFinishAnimatingPath:(embDrawBezierPath*)finished;
-(void)didFinishAllAnimations:(embDrawBezierPath*)finished;
@end

@interface embDrawBezierPath : UIView <UIGestureRecognizerDelegate> {
	__weak id <embDrawBezierPathDelegate> delegate;
	NSUInteger cPath;
	NSMutableArray *polyPaths;
	NSMutableArray *arr_shapeLayers;
	embBezierPathItem *pathItem;
	NSUInteger pathCompleted;
	BOOL           isTapped;
	BOOL           isCleared;
    BOOL           canBeCanceled;
	
}

@property (nonatomic, retain) CAShapeLayer *pathLayer;
@property (nonatomic, retain) NSString *pathString;
@property (nonatomic, assign) CGFloat animationSpeed;
@property (nonatomic, assign) CGFloat pathLineWidth;
@property (nonatomic, assign) CGFloat pathOpacity;
@property (nonatomic, assign) UIColor *pathStrokeColor;
@property (nonatomic, assign) UIColor *pathFillColor;
@property (nonatomic, assign) UIImage *pathCapImage;
@property (nonatomic, strong) CALayer *penLayer;
@property (nonatomic, strong) UIBezierPath *myPath;
@property (nonatomic, strong) NSMutableArray *arr_tappedArray;

@property (assign) BOOL animated;
@property (assign) BOOL isTappable;
@property (assign) BOOL shouldHighlight;
@property (assign) BOOL allowsMultipleSelection;

@property __weak id <embDrawBezierPathDelegate> delegate;
@property (nonatomic, readwrite) BOOL isStack;


- (id)initWithFrame:(CGRect)frame;
- (void)embDrawBezierPathShouldRemove;
- (void)didFinishAnimatingPath;
- (void)didFinishAllAnimations;
- (void)startAnimationFromIndex:(int)index afterDelay:(CGFloat)afterDelay;
- (void)pathTappedAtIndex:(int)i;
- (NSString*)pathString;
-(void)clearHighlightedPart;
-(void)clearTapped:(int)idx;
-(void)highlightFromParent:(int)index;
-(void)highlightFromParent:(int)index andTappedArray:(NSMutableArray *)tappedArray;
-(void)fadePaths;
-(void)pulseFill;
- (UIBezierPath*)myPath;
-(void)clearAllHilightedPart;
;
-(void)tmpHighlighted:(int)index;
@end
