//
//  DEBMultiSampleRenderer.m
//  GyroCompass
//
//  Created by Takaaki Tanaka on 2014/03/31.
//  Copyright (c) 2014年 Takaaki Tanaka. All rights reserved.
//

#import <OpenGLES/EAGL.h>
#import <OpenGLES/EAGLDrawable.h>
#import <OpenGLES/ES1/glext.h>
#import <QuartzCore/QuartzCore.h>
#import "DEBMultiSampleRenderer.h"

@interface DEBMultiSampleRenderer ()
@property(nonatomic,strong) EAGLContext *context;
@property(nonatomic,readwrite) CGFloat screenScale;
@property(nonatomic,readwrite) GLint backingWidth;
@property(nonatomic,readwrite) GLint backingHeight;
@property(nonatomic,readwrite) GLuint viewFramebuffer;
@property(nonatomic,readwrite) GLuint viewRenderbuffer;
@property(nonatomic,readwrite) GLuint multiSampleFramebuffer;
@property(nonatomic,readwrite) GLuint multiSampleRenderbuffer;
@property(nonatomic,readwrite) GLuint depthRenderbuffer;
@property(nonatomic,readwrite) CGFloat capturing;
- (void)destroyFramebuffer;
- (UIImage *)snapshot;
@end

@implementation DEBMultiSampleRenderer

- (id)init {
    self = [super init];
    if (self) {
        self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
        if (!_context || ![EAGLContext setCurrentContext:_context]) {
            self = nil;
        }
        self.screenScale = [UIScreen mainScreen].scale;
    }
    return self;
}

- (void)dealloc {
    [self destroyFramebuffer];
    self.context = nil;
}

- (void)screenCapture {
    self.capturing = YES;
}

- (void)screenCaptureComplition:(DEBMultiSampleRendererScreenCaptureComplitionHandler)complitionHandler {
    self.complitionHandler = complitionHandler;
    self.capturing = YES;
}

#pragma mark - DEBRenderer protocol

- (void)willRender {
    if ([EAGLContext currentContext] != _context) {
        [EAGLContext setCurrentContext:_context];
    }
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, _multiSampleFramebuffer);
    //glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glClear(GL_COLOR_BUFFER_BIT);
}

- (void)didRender {
    glBindFramebufferOES(GL_DRAW_FRAMEBUFFER_APPLE, _viewFramebuffer);
    glBindFramebufferOES(GL_READ_FRAMEBUFFER_APPLE, _multiSampleFramebuffer);
    glResolveMultisampleFramebufferAPPLE();
//    const GLenum discards[] = { GL_COLOR_ATTACHMENT0_OES, GL_DEPTH_ATTACHMENT_OES };
//    glDiscardFramebufferEXT(GL_READ_FRAMEBUFFER_APPLE, 2, discards);
    const GLenum discards[] = { GL_COLOR_ATTACHMENT0_OES };
    glDiscardFramebufferEXT(GL_READ_FRAMEBUFFER_APPLE, 1, discards);
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, _viewRenderbuffer);
    if (_capturing) {
        UIImage *screenshotImage = [self snapshot];
        if (_complitionHandler) {
            self.complitionHandler(screenshotImage);
        } else {
            if ([_delegate respondsToSelector:@selector(render:didCaptureScreenshotImage:)]) {
                [_delegate render:self didCaptureScreenshotImage:screenshotImage];
            }
        }
        self.capturing = YES;
    }
    [_context presentRenderbuffer:GL_RENDERBUFFER_OES];
}

- (void)render {
    // do nothing
}

- (BOOL)resizeFromLayer:(CAEAGLLayer *)layer {
#if 0
    [self destroyFramebuffer];
    glGenFramebuffersOES(1, &_viewFramebuffer);
    glGenRenderbuffersOES(1, &_viewRenderbuffer);
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, _viewFramebuffer);
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, _viewRenderbuffer);
    [_context renderbufferStorage:GL_RENDERBUFFER_OES fromDrawable:layer];
    glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER_OES, _viewRenderbuffer);
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_WIDTH_OES, &_backingWidth);
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_HEIGHT_OES, &_backingHeight);
    // Multi Sample Anti Aliasing
    glGenFramebuffersOES(1, &_multiSampleFramebuffer);
    glGenRenderbuffersOES(1, &_multiSampleRenderbuffer);
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, _multiSampleFramebuffer);
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, _multiSampleRenderbuffer);
    glRenderbufferStorageMultisampleAPPLE(GL_RENDERBUFFER_OES, 4, GL_RGB5_A1_OES, _backingWidth, _backingHeight);
    glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER_OES, _multiSampleRenderbuffer);
    glGenRenderbuffersOES(1, &_depthRenderbuffer);
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, _depthRenderbuffer);
    glRenderbufferStorageMultisampleAPPLE(GL_RENDERBUFFER_OES, 4, GL_DEPTH_COMPONENT16_OES, _backingWidth, _backingHeight);
    glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_DEPTH_ATTACHMENT_OES, GL_RENDERBUFFER_OES, _depthRenderbuffer);
    glEnable(GL_DEPTH_TEST);
    if (glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES) != GL_FRAMEBUFFER_COMPLETE_OES) {
        NSLog(@"failed to make complete framebuffer object %x", glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES));
        return NO;
    }
    glViewport(0, 0, _backingWidth, _backingHeight);
    glClearColor(0.0, 0.0, 0.0, 0.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    return  YES;
#endif
    [self destroyFramebuffer];
    glGenFramebuffersOES(1, &_viewFramebuffer);
    glGenRenderbuffersOES(1, &_viewRenderbuffer);
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, _viewFramebuffer);
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, _viewRenderbuffer);
    [_context renderbufferStorage:GL_RENDERBUFFER_OES fromDrawable:layer];
    glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER_OES, _viewRenderbuffer);
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_WIDTH_OES, &_backingWidth);
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_HEIGHT_OES, &_backingHeight);
    // Multi Sample Anti Aliasing
    glGenFramebuffersOES(1, &_multiSampleFramebuffer);
    glGenRenderbuffersOES(1, &_multiSampleRenderbuffer);
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, _multiSampleFramebuffer);
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, _multiSampleRenderbuffer);
    glRenderbufferStorageMultisampleAPPLE(GL_RENDERBUFFER_OES, 4, GL_RGB5_A1_OES, _backingWidth, _backingHeight);
    glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER_OES, _multiSampleRenderbuffer);
    if (glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES) != GL_FRAMEBUFFER_COMPLETE_OES) {
        NSLog(@"failed to make complete framebuffer object %x", glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES));
        return NO;
    }
    glViewport(0, 0, _backingWidth, _backingHeight);
    glClearColor(0.0, 0.0, 0.0, 0.0);
    glClear(GL_COLOR_BUFFER_BIT);
    return  YES;
}

#pragma mark -
#pragma mark Anonymous category

- (void)destroyFramebuffer {
    if (_viewFramebuffer) {
        glDeleteFramebuffersOES(1, &_viewFramebuffer);
        _viewFramebuffer = 0;
    }
    if (_viewRenderbuffer) {
        glDeleteRenderbuffersOES(1, &_viewRenderbuffer);
        _viewRenderbuffer = 0;
    }
    if (_multiSampleFramebuffer) {
        glDeleteFramebuffersOES(1, &_multiSampleFramebuffer);
        _multiSampleFramebuffer = 0;
    }
    if (_multiSampleRenderbuffer) {
        glDeleteRenderbuffersOES(1, &_multiSampleRenderbuffer);
        _multiSampleRenderbuffer = 0;
    }
    if (_depthRenderbuffer) {
        glDeleteRenderbuffersOES(1, &_depthRenderbuffer);
        _depthRenderbuffer = 0;
    }
}

- (UIImage *)snapshot {
    GLint backingWidth, backingHeight;
    // Bind the color renderbuffer used to render the OpenGL ES view
    // If your application only creates a single color renderbuffer which is already bound at this point,
    // this call is redundant, but it is needed if you're dealing with multiple renderbuffers.
    // Note, replace "_colorRenderbuffer" with the actual name of the renderbuffer object defined in your class.
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, _viewFramebuffer);
    // Get the size of the backing CAEAGLLayer
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_WIDTH_OES, &backingWidth);
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_HEIGHT_OES, &backingHeight);
    NSInteger x = 0, y = 0, width = backingWidth, height = backingHeight;
    NSInteger dataLength = width * height * 4;
    GLubyte *data = (GLubyte*)malloc(dataLength * sizeof(GLubyte));
    // Read pixel data from the framebuffer
    glPixelStorei(GL_PACK_ALIGNMENT, 4);
    glReadPixels(x, y, width, height, GL_RGBA, GL_UNSIGNED_BYTE, data);
    // Create a CGImage with the pixel data
    // If your OpenGL ES content is opaque, use kCGImageAlphaNoneSkipLast to ignore the alpha channel
    // otherwise, use kCGImageAlphaPremultipliedLast
    CGDataProviderRef ref = CGDataProviderCreateWithData(NULL, data, dataLength, NULL);
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    CGImageRef imageRef = CGImageCreate(width, height, 8, 32, width * 4, colorspace, kCGBitmapByteOrder32Big | kCGImageAlphaPremultipliedLast, ref, NULL, TRUE, kCGRenderingIntentDefault);
    // OpenGL ES measures data in PIXELS
    // Create a graphics context with the target size measured in POINTS
    NSInteger widthInPoints, heightInPoints;
    if (NULL != UIGraphicsBeginImageContextWithOptions) {
        // On iOS 4 and later, use UIGraphicsBeginImageContextWithOptions to take the scale into consideration
        // Set the scale parameter to your OpenGL ES view's contentScaleFactor
        // so that you get a high-resolution snapshot when its value is greater than 1.0
        CGFloat scale = _screenScale;
        widthInPoints = width / scale;
        heightInPoints = height / scale;
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(widthInPoints, heightInPoints), NO, scale);
    } else {
        // On iOS prior to 4, fall back to use UIGraphicsBeginImageContext
        widthInPoints = width;
        heightInPoints = height;
        UIGraphicsBeginImageContext(CGSizeMake(widthInPoints, heightInPoints));
    }
    CGContextRef cgcontext = UIGraphicsGetCurrentContext();
    // UIKit coordinate system is upside down to GL/Quartz coordinate system
    // Flip the CGImage by rendering it to the flipped bitmap context
    // The size of the destination area is measured in POINTS
    CGContextSetBlendMode(cgcontext, kCGBlendModeCopy);
    CGContextDrawImage(cgcontext, CGRectMake(0.0, 0.0, widthInPoints, heightInPoints), imageRef);
    // Retrieve the UIImage from the current context
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    // Clean up
    free(data);
    CFRelease(ref);
    CFRelease(colorspace);
    CGImageRelease(imageRef);
    return image;
}

@end
