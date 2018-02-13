//
//  DEBSceneRenderer.m
//  GyroCompass
//
//  Created by Takaaki Tanaka on 2014/03/31.
//  Copyright (c) 2014年 Takaaki Tanaka. All rights reserved.
//

#import <OpenGLES/ES1/glext.h>
#import "DEBDeviceOrientation.h"
#import "DEBGyroCompassScene.h"
#import "DEBSceneRenderer.h"

#define DEGREES_TO_RADIANS(__ANGLE__) ((__ANGLE__ / 180.0) * M_PI)
#define RADIANS_TO_DEGREES(__ANGLE__) ((__ANGLE__) * 180.0 / M_PI)
#define VIEWPORT_WIDTH 1.0
#define VIEWPORT_HEIGHT 1.5
#define Z_NEAR 3.0
#define Z_FAR sqrtf(pow(400, 2) + pow(400, 2))
#define DRAW_SCREEN_WIDTH VIEWPORT_WIDTH / Z_NEAR
#define DRAW_SCREEN_HEIGHT VIEWPORT_HEIGHT / Z_NEAR

@interface DEBSceneRenderer ()
@property(strong,nonatomic) DEBDeviceOrientation *deviceOrientation;
@property(nonatomic,strong) DEBGyroCompassScene *gyroCompassScene;
@end

@implementation DEBSceneRenderer

- (id)init {
    self = [super init];
    if (self) {
        self.deviceOrientation = [[DEBDeviceOrientation alloc] init];
        self.gyroCompassScene = [[DEBGyroCompassScene alloc] initWithName:@"compass"];
    }
    return self;
}

- (void)render {
    glLoadIdentity();
    // GyroCompass
    glPushMatrix();
    CGFloat angle = fabs(_deviceOrientation.pitch);
    glTranslatef(0, 0.25, -(3 + (angle < 30 ? 0 : ((angle - 30) / 10))));
    glRotatef(_deviceOrientation.yaw, 0.0, 0.0, 1.0);
    glRotatef(_deviceOrientation.pitch, 1.0, 0.0, 0.0);
    glRotatef(_deviceOrientation.roll, 0.0, 1.0, 0.0);
    glRotatef(90, 1.0, 0.0, 0.0);
    [_gyroCompassScene drawSceneCircle];
    glRotatef(90, -1.0, 0.0, 0.0);
    for (NSInteger i = 0; i < 4; i++) {
        glPushMatrix();
        CGFloat headingAngle = (i * 90);
        glRotatef(headingAngle, 0.0, -1.0, 0.0);
        glTranslatef(0, 0.5, -2.5);
        glRotatef(_deviceOrientation.pitch, -1.0, 0.0, 0.0);
        [_gyroCompassScene drawSceneHeading:headingAngle];
        glPopMatrix();
    }
    glPopMatrix();
}

- (BOOL)resizeFromLayer:(CAEAGLLayer *)layer {
    if (![super resizeFromLayer:layer]) {
        return NO;
    }
    // Set up the viewing volume and orthographic mode.
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    glFrustumf(-VIEWPORT_WIDTH, VIEWPORT_WIDTH, -VIEWPORT_HEIGHT, VIEWPORT_HEIGHT, Z_NEAR, Z_FAR);
    // Clear the modelview matrix
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    // Set up blending mode
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    return YES;
}

- (void)start {
    [_deviceOrientation start];
//    glEnable(GL_FOG);
//	glFogf(GL_FOG_MODE, GL_LINEAR);
//	glFogf(GL_FOG_START, 100);
//	glFogf(GL_FOG_END, 500);
}

- (void)stop {
    [_deviceOrientation stop];
}

@end