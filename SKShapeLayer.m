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

@interface SKShapeLayer ()
{
    UIBezierPath* _bezierPath;
    NSMutableArray* _mPointArray;
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
}

- (void)addLineToPoint:(CGPoint)point
{
    [_bezierPath addLineToPoint:point];
    self.path = _bezierPath.CGPath;
    _mPointArray = nil;
}

- (void)endPath
{
    _bezierPath = nil;
    _mPointArray = nil;
}

- (void)reducePath
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

- (void)dealloc
{
    
}

@end
