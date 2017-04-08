//
//  SKView.h
//  SimpleSketchpad
//
//  Created by guanglong on 2017/4/8.
//  Copyright © 2017年 bjhl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SKView : UIView

- (void)removeLastPath;
- (void)removeByPoint;
- (void)removeAllPaths;

- (void)removeLastPathAutomatically;
- (void)removeByPointAutomatically;

@property (nonatomic, assign) NSInteger removeLastPathVelocity;
@property (nonatomic, assign) NSInteger removeByPointVelocity;

@property (nonatomic, assign) BOOL pauseRemoveLastPath;
@property (nonatomic, assign) BOOL pauseRemoveByPoint;

- (void)stopRemoveLastPath;
- (void)stopRemoveByPoint;

@end
