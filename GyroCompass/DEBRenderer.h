//
//  DEBRenderer.h
//  GyroCompass
//
//  Created by Takaaki Tanaka on 2014/03/31.
//  Copyright (c) 2014年 Takaaki Tanaka. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DEBRenderer <NSObject>
- (void)willRender;
- (void)didRender;
- (void)render;
- (BOOL)resizeFromLayer:(CAEAGLLayer *)layer;
@end
