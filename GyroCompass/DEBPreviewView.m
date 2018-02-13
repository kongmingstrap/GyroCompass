//
//  DEBPreviewView.m
//  GyroCompass
//
//  Created by Takaaki Tanaka on 2014/03/31.
//  Copyright (c) 2014年 Takaaki Tanaka. All rights reserved.
//

#import "DEBPreviewView.h"
#import "DEBSceneRenderer.h"

@implementation DEBPreviewView

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.renderer = [[DEBSceneRenderer alloc] init];
//        animationFrameInterval_ = 2.0;
    }
    return self;
}

- (void)start {
    [(DEBSceneRenderer *)self.renderer start];
    [self startAnimation];
}

- (void)stop {
    [(DEBSceneRenderer *)self.renderer stop];
    [self stopAnimation];
}

@end