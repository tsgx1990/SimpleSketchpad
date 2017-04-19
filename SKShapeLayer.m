//
//  SKShapeLayer.m
//  SimpleSketchpad
//
//  Created by guanglong on 2017/4/8.
//  Copyright © 2017年 bjhl. All rights reserved.
//

#import "SKShapeLayer.h"

void pathFunction(void *info, const CGPathElement *element)
{
    NSMutableArray* mPathArr = (__bridge NSMutableArray*)info;
    if (element->type == kCGPathElementAddLineToPoint) {
        CGPoint p = element->points[0];
        NSLog(@"AddLineToPoint -> %lg %lg", p.x, p.y);
        [mPathArr addObject:[NSValue valueWithCGPoint:p]];
    }
    if (element->type == kCGPathElementMoveToPoint) {
        CGPoint p = element->points[0];
        NSLog(@"MoveToPoint -> %lg %lg", p.x, p.y);
        [mPathArr addObject:[NSValue valueWithCGPoint:p]];
    }
}

@interface CALayer (PauseResumeAnimation)

- (void)pauseAnimation;
- (void)resumeAnimation;

@end

@implementation CALayer (PauseResumeAnimation)

- (void)pauseAnimation
{
    CFTimeInterval pausedTime = [self convertTime:CACurrentMediaTime() fromLayer:nil];
    self.speed = 0.0;
    self.timeOffset = pausedTime;
}

- (void)resumeAnimation
{
    CFTimeInterval pausedTime = [self timeOffset];
    self.speed = 1.0;
    self.beginTime = 0.0;
    CFTimeInterval timeSincePause = [self convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
    self.beginTime = timeSincePause;
}

@end

@interface SKShapeLayerAnimationDelegate : NSObject<CAAnimationDelegate>

@property (nonatomic, copy) void(^animationDidStop)(CAAnimation* anim, BOOL finished);

@end

@implementation SKShapeLayerAnimationDelegate

#pragma mark - - CAAnimationDelegate
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    NSLog(@"%s", __func__);
    if (self.animationDidStop) {
        self.animationDidStop(anim, flag);
    }
}

@end

@interface SKShapeLayer ()
{
    UIBezierPath* _bezierPath;
    NSMutableArray* _mPointArray;
    
    CGPoint prevPoint;
    CGFloat pathLength;
}

@end

@implementation SKShapeLayer

- (void)moveToPoint:(CGPoint)point
{
    if (!_bezierPath) {
        _bezierPath = [UIBezierPath bezierPath];
    }
    [_bezierPath moveToPoint:point];
    self.path = _bezierPath.CGPath;
    _mPointArray = nil;
    prevPoint = point;
}

- (void)addLineToPoint:(CGPoint)point
{
    [_bezierPath addLineToPoint:point];
    self.path = _bezierPath.CGPath;
    _mPointArray = nil;
    
    // 计算path长度
    pathLength += sqrtf(powf(point.x-prevPoint.x, 2) + powf(point.y-prevPoint.y, 2));
    prevPoint = point;
}

- (void)addLineToPoint:(CGPoint)point offset:(CGFloat)offset
{
    [_bezierPath addLineToPoint:point];
    self.path = _bezierPath.CGPath;
    _mPointArray = nil;
    
    pathLength += offset;
    prevPoint = point;
}

- (void)endPath
{
    _bezierPath = nil;
    _mPointArray = nil;
}

- (void)reduceByLine
{
    if (!_mPointArray.count) {
        NSMutableArray* mPathArr = [NSMutableArray arrayWithCapacity:10];
        CGPathApply(self.path, (__bridge void *)(mPathArr), pathFunction);
        _mPointArray = mPathArr;
    }
    
    CGMutablePathRef mPath = CGPathCreateMutable();
    // 需要考虑到第一个点是movePoint，当还剩两个点的时候需要把这两个点都移除
    if (_mPointArray.count > 2) {
        CGPoint movePoint = [_mPointArray.firstObject CGPointValue];
        CGPathMoveToPoint(mPath, NULL, movePoint.x, movePoint.y);
        for (int i=1; i<_mPointArray.count-1; i++) {
            CGPoint addPoint = [_mPointArray[i] CGPointValue];
            CGPathAddLineToPoint(mPath, NULL, addPoint.x, addPoint.y);
        }
        [_mPointArray removeLastObject]; // 每次重新创建path后，将最后一个路径点移除
        self.path = mPath;
        CGPathRelease(mPath); // 防止内存泄漏
    }
    else {
        [self removeFromSuperlayer];
    }
}

- (void)setStopReduceByPoint:(BOOL)stopReduceByPoint
{
    static NSString* keyPath = @"strokeEnd";
    CABasicAnimation* ani = (CABasicAnimation*)[self animationForKey:keyPath];
    if (stopReduceByPoint) {
        NSLog(@"presentationLayer.strokeEnd:%f", self.presentationLayer.strokeEnd);
        NSLog(@"modelLayer.strokeEnd:%f", self.modelLayer.strokeEnd);
        NSLog(@"self.strokeEnd:%f", self.strokeEnd);
        if (ani) {
            [self pauseAnimation];
        }
    }
    else {
        if (!ani) {
            ani = [CABasicAnimation animationWithKeyPath:keyPath];
            ani.duration = 0.01*pathLength;
            ani.fromValue = @(1.0);
            ani.toValue = @(0.0);
            ani.fillMode = kCAFillModeForwards;
            ani.removedOnCompletion = NO;
            
            SKShapeLayerAnimationDelegate* delegate = [[SKShapeLayerAnimationDelegate alloc] init];
            __weak typeof(self) ws = self;
            delegate.animationDidStop = ^(CAAnimation* anim, BOOL finished) {
                [ws removeFromSuperlayer];
            };
            ani.delegate = delegate;
            [self addAnimation:ani forKey:keyPath];
        }
        else if (_stopReduceByPoint != stopReduceByPoint) {
            [self resumeAnimation];
        }
        else {
            // do nothing
        }
    }
    _stopReduceByPoint = stopReduceByPoint;
}

- (void)dealloc
{
    NSLog(@"%s", __func__);
}

@end
