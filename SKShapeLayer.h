//
//  SKShapeLayer.h
//  SimpleSketchpad
//
//  Created by guanglong on 2017/4/8.
//  Copyright © 2017年 bjhl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface SKShapeLayer : CAShapeLayer

- (void)moveToPoint:(CGPoint)point;
- (void)addLineToPoint:(CGPoint)point;
- (void)addLineToPoint:(CGPoint)point offset:(CGFloat)offset;
- (void)endPath; // touch end/cancel 后调用

- (void)reduceByLine; // 逐渐缩短 bezierPath

@property (nonatomic, assign) BOOL stopReduceByPoint;

@end
