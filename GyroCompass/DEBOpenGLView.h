//
//  DEBOpenGLView.h
//  GyroCompass
//
//  Created by Takaaki Tanaka on 2014/03/31.
//  Copyright (c) 2014年 Takaaki Tanaka. All rights reserved.
//

#import "DEBRenderer.h"

@interface DEBOpenGLView : UIView
@property(readonly,nonatomic,getter=isAnimating) BOOL animating;
@property(nonatomic,strong) id <DEBRenderer> renderer;
- (void)startAnimation;
- (void)stopAnimation;
- (void)drawView:(id)sender;
@end
