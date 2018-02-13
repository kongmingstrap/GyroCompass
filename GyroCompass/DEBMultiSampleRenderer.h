//
//  DEBMultiSampleRenderer.h
//  GyroCompass
//
//  Created by Takaaki Tanaka on 2014/03/31.
//  Copyright (c) 2014年 Takaaki Tanaka. All rights reserved.
//

#import <OpenGLES/ES1/gl.h>
#import "DEBRenderer.h"

@protocol DEBMultiSampleRendererDelegate;

typedef void (^DEBMultiSampleRendererScreenCaptureComplitionHandler)(UIImage *image);

@class EAGLContext;

@interface DEBMultiSampleRenderer : NSObject <DEBRenderer>
@property(weak,nonatomic) id <DEBMultiSampleRendererDelegate> delegate;
@property(nonatomic,readonly) CGFloat screenScale;
@property(nonatomic,copy) DEBMultiSampleRendererScreenCaptureComplitionHandler complitionHandler;
- (void)screenCapture;
- (void)screenCaptureComplition:(DEBMultiSampleRendererScreenCaptureComplitionHandler)complitionHandler;
@end

@protocol DEBMultiSampleRendererDelegate <NSObject>
@optional
- (void)render:(DEBMultiSampleRenderer *)render didCaptureScreenshotImage:(UIImage *)image;
@end
