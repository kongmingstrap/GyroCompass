//
//  DEBOpenGLView.m
//  GyroCompass
//
//  Created by Takaaki Tanaka on 2014/03/31.
//  Copyright (c) 2014年 Takaaki Tanaka. All rights reserved.
//

@import QuartzCore;
#import "DEBOpenGLView.h"

@interface DEBOpenGLView ()
@property(weak,nonatomic) NSTimer *animationTimer;
@property(weak,nonatomic) id displayLink;
@property NSInteger animationFrameInterval;
@property BOOL displayLinkSupported;
@end

@implementation DEBOpenGLView

+ (Class)layerClass {
    return [CAEAGLLayer class];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
        eaglLayer.opaque = NO;
        eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
        eaglLayer.contentsScale = [UIScreen mainScreen].scale;
        _animationFrameInterval = 1.0;
        NSString *reqSysVer = @"3.1";
        NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
        if ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending) {
            _displayLinkSupported = YES;
        }
    }
    return self;
}

- (void)layoutSubviews {
    [_renderer resizeFromLayer:(CAEAGLLayer*)self.layer];
    [self drawView:nil];
}

- (void)dealloc {
    self.renderer = nil;
    self.displayLink = nil;
    self.animationTimer = nil;
}

- (void)setAnimationTimer:(NSTimer *)timer {
    if (_animationTimer) {
        [_animationTimer invalidate];
    }
    _animationTimer = timer;
}

- (void)setDisplayLink:(id)displayLink {
    if (_displayLink) {
        [_displayLink invalidate];
    }
    _displayLink = displayLink;
}

- (void)startAnimation {
    if (!_animating) {
        if (_displayLinkSupported) {
            self.displayLink = [NSClassFromString(@"CADisplayLink") displayLinkWithTarget:self selector:@selector(drawView:)];
            [_displayLink setFrameInterval:_animationFrameInterval];
            [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        } else {
            self.animationTimer = [NSTimer scheduledTimerWithTimeInterval:((1.0 / 60.0) * _animationFrameInterval) target:self selector:@selector(drawView:) userInfo:nil repeats:YES];
        }
        _animating = YES;
    }
}

- (void)stopAnimation {
    if (_animating) {
        if (_displayLinkSupported) {
            self.displayLink = nil;
        } else {
            self.animationTimer = nil;
        }
        _animating = NO;
    }
}

- (void)drawView:(id)sender {
    if (_renderer) {
        [_renderer willRender];
        [_renderer render];
        [_renderer didRender];
    }
}

@end
