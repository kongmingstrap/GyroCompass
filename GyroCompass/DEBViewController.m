//
//  DEBViewController.m
//  GyroCompass
//
//  Created by Takaaki Tanaka on 2014/03/31.
//  Copyright (c) 2014年 Takaaki Tanaka. All rights reserved.
//

@import AVFoundation;
#import "DEBPreviewView.h"
#import "DEBRenderer.h"
#import "DEBViewController.h"

@interface DEBViewController ()
@property(strong,nonatomic) AVCaptureDeviceInput *videoInput;
@property(strong,nonatomic) AVCaptureSession *session;
@property(strong,nonatomic) AVCaptureStillImageOutput *stillImageOutput;
@property(strong,nonatomic) AVCaptureVideoPreviewLayer *videoPreviewLayer;
//@property(strong,nonatomic) DEBOpenGLView *openGLView;
@property(strong,nonatomic) DEBPreviewView *previewView;
//@property(strong,nonatomic) UIImageView *demoImageView;
- (void)startCameraCapture;
- (void)stopCameraCapture;
- (AVCaptureConnection *)connectionWithMediaType:(NSString *)mediaType fromConnections:(NSArray *)connections;
@end

@implementation DEBViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    // openGLView
    self.previewView = [[DEBPreviewView alloc] initWithFrame:[self.videoPreviewView bounds]];
//    self.openGLView = [[DEBOpenGLView alloc] initWithFrame:[self.videoPreviewView bounds]];
//    _openGLView.contentScaleFactor = [UIScreen mainScreen].scale;
    _previewView.contentScaleFactor = [UIScreen mainScreen].scale;
    [self.videoPreviewView addSubview:_previewView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self startCameraCapture];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self stopCameraCapture];
}

#pragma mark - Anonymous category

- (void)startCameraCapture {
#if !TARGET_IPHONE_SIMULATOR
    if (!_session) {
        self.session = [[AVCaptureSession alloc] init];
        _session.sessionPreset = AVCaptureSessionPresetPhoto;
        self.videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_session];
        CALayer *viewLayer = [_videoPreviewView layer];
        [viewLayer setMasksToBounds:YES];
        CGRect bounds = [_videoPreviewView bounds];
        [_videoPreviewLayer setFrame:bounds];
        _videoPreviewLayer.backgroundColor = [UIColor blackColor].CGColor;
        [_videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
        [viewLayer insertSublayer:_videoPreviewLayer below:[[viewLayer sublayers] objectAtIndex:0]];
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        NSError *error = nil;
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
        [_session addInput:input];
        self.videoInput = input;
        AVCaptureStillImageOutput *newStillImageOutput = [[AVCaptureStillImageOutput alloc] init];
        NSDictionary *outputSettings = @{ AVVideoCodecKey: AVVideoCodecJPEG };
        [newStillImageOutput setOutputSettings:outputSettings];
        self.stillImageOutput = newStillImageOutput;
        [_session addOutput:newStillImageOutput];
        if ([device isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance]) {
            if ([device lockForConfiguration:&error]) {
                [device setWhiteBalanceMode:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance];
                [device unlockForConfiguration];
            } else {
                NSLog(@"%s: %@", __PRETTY_FUNCTION__, error);
            }
        }
        if ([device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
            if ([device lockForConfiguration:&error]) {
                [device setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
                [device unlockForConfiguration];
            } else {
                NSLog(@"%s: %@", __PRETTY_FUNCTION__, error);
            }
        }
    }
    if (!_session.running) {
        [_session startRunning];
    }
#endif
    if (_previewView) {
        [_previewView start];
    }
}

- (void)stopCameraCapture {
#if !TARGET_IPHONE_SIMULATOR
    if (_session.running) {
        [_session stopRunning];
    }
#endif
    if (_previewView) {
        [_previewView stop];
    }
}

- (AVCaptureConnection *)connectionWithMediaType:(NSString *)mediaType fromConnections:(NSArray *)connections {
    for (AVCaptureConnection *connection in connections) {
        for (AVCaptureInputPort *port in [connection inputPorts]) {
            if ([[port mediaType] isEqual:mediaType]) {
                return connection;
            }
        }
    }
    return nil;
}

@end
