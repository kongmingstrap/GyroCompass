//
//  DEBGyroCompassScene.m
//  GyroCompass
//
//  Created by Takaaki Tanaka on 2014/03/31.
//  Copyright (c) 2014年 Takaaki Tanaka. All rights reserved.
//

#import <OpenGLES/ES1/glext.h>
#import "DEBGyroCompassScene.h"

@interface DEBGyroCompassScene ()
@property(strong,readwrite) NSString *name;
@property(nonatomic,readwrite) GLuint circleTexture;
@property(nonatomic,readwrite) GLuint northTexture;
@property(nonatomic,readwrite) GLuint eastTexture;
@property(nonatomic,readwrite) GLuint southTexture;
@property(nonatomic,readwrite) GLuint westTexture;
- (void)createTexture;
@end

@implementation DEBGyroCompassScene

- (id)initWithName:(NSString *)name {
    self = [super init];
    if (self) {
        self.name = name;
        [self createTexture];
    }
    return self;
}

- (void)dealloc {
    if (_circleTexture) {
        glDeleteTextures(1, &_circleTexture);
        _circleTexture = 0;
    }
    if (_northTexture) {
        glDeleteTextures(1, &_northTexture);
        _northTexture = 0;
    }
    if (_eastTexture) {
        glDeleteTextures(1, &_eastTexture);
        _eastTexture = 0;
    }
    if (_southTexture) {
        glDeleteTextures(1, &_southTexture);
        _southTexture = 0;
    }
    if (_westTexture) {
        glDeleteTextures(1, &_westTexture);
        _westTexture = 0;
    }
}

- (void)drawSceneCircle {
    GLfloat squareVertices[] = {
        -0.5 * 5.0, -0.5 * 5.0,
        0.5 * 5.0, -0.5 * 5.0,
        -0.5 * 5.0,  0.5 * 5.0,
        0.5 * 5.0,  0.5 * 5.0,
    };
    GLubyte squareColors[] = {
        255, 255, 255, 255,
        255, 255, 255, 255,
        255, 255, 255, 255,
        255, 255, 255, 255,
    };
    GLfloat texCoords[] = {
        0,   1.0,
        1.0, 1.0,
        0,   0,
        1.0, 0,
    };
    glEnable(GL_TEXTURE_2D);
    glBindTexture(GL_TEXTURE_2D, _circleTexture);
    glVertexPointer(2, GL_FLOAT, 0, squareVertices);
    glEnableClientState(GL_VERTEX_ARRAY);
    glColorPointer(4, GL_UNSIGNED_BYTE, 0, squareColors);
    glEnableClientState(GL_COLOR_ARRAY);
    glTexCoordPointer(2, GL_FLOAT, 0, texCoords);
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    glDisableClientState(GL_TEXTURE_COORD_ARRAY);
    glDisable(GL_TEXTURE_2D);
}

- (void)drawSceneHeading:(GLfloat)angle {
    GLuint texture = 0;
    if ((angle >= 330) || (angle <= 30)) {
        texture = _northTexture;
    } else if ((angle >= 60) && (angle <= 120)) {
        texture = _eastTexture;
    } else if ((angle >= 150) && (angle <= 210)) {
        texture = _southTexture;
    } else if ((angle >= 240) && (angle <= 300)) {
        texture = _westTexture;
    }
    if (!texture) {
        return;
    }
    GLfloat squareVertices[] = {
        -0.5 * 1.0, -0.5 * 1.0,
        0.5 * 1.0, -0.5 * 1.0,
        -0.5 * 1.0,  0.5 * 1.0,
        0.5 * 1.0,  0.5 * 1.0,
    };
    GLubyte squareColors[] = {
        255, 255, 255, 255,
        255, 255, 255, 255,
        255, 255, 255, 255,
        255, 255, 255, 255,
    };
    GLfloat texCoords[] = {
        0,   1.0,
        1.0, 1.0,
        0,   0,
        1.0, 0,
    };
    glEnable(GL_TEXTURE_2D);
    glBindTexture(GL_TEXTURE_2D, texture);
    glVertexPointer(2, GL_FLOAT, 0, squareVertices);
    glEnableClientState(GL_VERTEX_ARRAY);
    glColorPointer(4, GL_UNSIGNED_BYTE, 0, squareColors);
    glEnableClientState(GL_COLOR_ARRAY);
    glTexCoordPointer(2, GL_FLOAT, 0, texCoords);
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    glDisableClientState(GL_TEXTURE_COORD_ARRAY);
    glDisable(GL_TEXTURE_2D);
}

#pragma mark - Anonymous category

- (void)createTexture {
    for (GLuint index = 0; index < 5; index++) {
        NSString *fileName;
        switch (index) {
            case 0:
                fileName = @"CompassCricle";
                break;
            case 1:
                fileName = @"CompassNorth";
                break;
            case 2:
                fileName = @"CompassEast";
                break;
            case 3:
                fileName = @"CompassSouth";
                break;
            case 4:
                fileName = @"CompassWest";
                break;
            default:
                break;
        }
        if (fileName) {
            UIImage *image = [UIImage imageNamed:fileName];
            CGImageRef imageRef = image.CGImage;
            if (imageRef) {
                size_t width = CGImageGetWidth(imageRef);
                size_t height = CGImageGetHeight(imageRef);
                GLubyte *imageData = (GLubyte *)malloc(width * height * 4);
                CGContextRef imageContext = CGBitmapContextCreate(imageData, width, height, 8, width * 4, CGImageGetColorSpace(imageRef), kCGImageAlphaPremultipliedLast);
                CGContextDrawImage(imageContext, CGRectMake(0, 0, (CGFloat)width, (CGFloat)height), imageRef);
                CGContextRelease(imageContext);
                switch (index) {
                    case 0:
                        glGenTextures(1, &_circleTexture);
                        glBindTexture(GL_TEXTURE_2D, _circleTexture);
                        break;
                    case 1:
                        glGenTextures(1, &_northTexture);
                        glBindTexture(GL_TEXTURE_2D, _northTexture);
                        break;
                    case 2:
                        glGenTextures(1, &_eastTexture);
                        glBindTexture(GL_TEXTURE_2D, _eastTexture);
                        break;
                    case 3:
                        glGenTextures(1, &_southTexture);
                        glBindTexture(GL_TEXTURE_2D, _southTexture);
                        break;
                    case 4:
                        glGenTextures(1, &_westTexture);
                        glBindTexture(GL_TEXTURE_2D, _westTexture);
                        break;
                }
                glTexParameteri(GL_TEXTURE_2D, GL_GENERATE_MIPMAP, GL_TRUE);
                glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
                glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
                glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, imageData);
                free(imageData);
            }
        }
    }
}

@end

