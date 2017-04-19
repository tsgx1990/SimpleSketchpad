//
//  SKView.m
//  SimpleSketchpad
//
//  Created by guanglong on 2017/4/8.
//  Copyright © 2017年 bjhl. All rights reserved.
//

#import "SKView.h"
#import "SKShapeLayer.h"

@interface SKView ()

@property (nonatomic, strong) CALayer* contentLayer;
@property (nonatomic, readonly) SKShapeLayer* topShapeLayer;

@end

@implementation SKView
{
    CGPoint prevAddedPoint;
    CADisplayLink* rLastPathDLink;
    CADisplayLink* rByPointLink;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

//- (void)drawRect:(CGRect)rect
//{
//    
//}

- (void)removeLastPath
{
    [self.topShapeLayer removeFromSuperlayer];
}

- (void)removeByPoint
{
    [self.topShapeLayer reduceByLine];
}

- (void)removeAllPaths
{
    [self.contentLayer.sublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
}

- (void)setRemoveLastPathVelocity:(NSInteger)removeLastPathVelocity
{
    _removeLastPathVelocity = removeLastPathVelocity;
    rLastPathDLink.frameInterval = _removeLastPathVelocity;
}

- (void)setStopRemoveLastPath:(BOOL)stopRemoveLastPath
{
    _stopRemoveLastPath = stopRemoveLastPath;
    if (!stopRemoveLastPath && !rLastPathDLink) {
        rLastPathDLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(removeLastPathAutomaticallyHandler:)];
        self.removeLastPathVelocity = 30;
        [rLastPathDLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    }
    if (stopRemoveLastPath) {
        [rLastPathDLink invalidate];
        rLastPathDLink = nil;
    }
}

- (void)setStopRemoveByPoint:(BOOL)stopRemoveByPoint
{
    _stopRemoveByPoint = stopRemoveByPoint;
    if (!stopRemoveByPoint && !rByPointLink) {
        rByPointLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(removeByPointAutomaticallyHandler:)];
        rByPointLink.frameInterval = 20;
        [rByPointLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    }
    if (stopRemoveByPoint) {
        self.topShapeLayer.stopReduceByPoint = YES;
        [rByPointLink invalidate];
        rByPointLink = nil;
    }
}

- (void)removeLastPathAutomaticallyHandler:(CADisplayLink*)dLink
{
    [self removeLastPath];
    if (!self.topShapeLayer) {
        [rLastPathDLink invalidate];
        rLastPathDLink = nil;
    }
}

- (void)removeByPointAutomaticallyHandler:(CADisplayLink*)dLink
{
    self.topShapeLayer.stopReduceByPoint = NO;
    if (!self.topShapeLayer) {
        [rByPointLink invalidate];
        rByPointLink = nil;
    }
}

#pragma mark - - touch events
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self addShapeLayer];
    CGPoint curPoint = [touches.anyObject locationInView:self];
    [self.topShapeLayer moveToPoint:curPoint];
    [self.topShapeLayer addLineToPoint:curPoint];
    prevAddedPoint = curPoint;
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    CGPoint curPoint = [touches.anyObject locationInView:self];
    CGFloat moveDis = powf(curPoint.x-prevAddedPoint.x, 2) + powf(curPoint.y-prevAddedPoint.y, 2);
    if (moveDis > 6) {
        [self.topShapeLayer addLineToPoint:curPoint offset:sqrtf(moveDis)];
        prevAddedPoint = curPoint;
    }
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.topShapeLayer endPath];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.topShapeLayer endPath];
}

- (void)addShapeLayer
{
    SKShapeLayer* shapeLayer = [SKShapeLayer layer];
    UIColor* strokeColor = [UIColor colorWithRed:arc4random()%10/10.0 green:arc4random()%10/10.0 blue:arc4random()%10/10.0 alpha:1];
    shapeLayer.strokeColor = strokeColor.CGColor;
    shapeLayer.fillColor = [UIColor clearColor].CGColor;
    shapeLayer.lineWidth = 5;
    shapeLayer.lineCap = kCALineCapRound;
    shapeLayer.lineJoin = kCALineJoinRound;
    shapeLayer.frame = self.bounds;
    [self.contentLayer addSublayer:shapeLayer];
}

- (SKShapeLayer *)topShapeLayer
{
    return (SKShapeLayer*)self.contentLayer.sublayers.lastObject;
}

- (CALayer *)contentLayer
{
    if (!_contentLayer) {
        _contentLayer = [CALayer layer];
        _contentLayer.frame = self.bounds;
        _contentLayer.backgroundColor = [UIColor clearColor].CGColor;
        [self.layer addSublayer:_contentLayer];
    }
    return _contentLayer;
}

- (void)dealloc
{
    
}

@end
