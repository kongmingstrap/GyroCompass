//
//  DEBDeviceOrientation.h
//  GyroCompass
//
//  Created by Takaaki Tanaka on 2014/03/31.
//  Copyright (c) 2014年 Takaaki Tanaka. All rights reserved.
//

@import Foundation;
@import CoreLocation;

@interface DEBDeviceOrientation : NSObject <CLLocationManagerDelegate>
@property(readonly) double roll;
@property(readonly) double pitch;
@property(readonly) double yaw;
@property(readonly) UIDeviceOrientation deviceOrientation;
@property(strong,readonly) CLLocation *location;

- (void)start;
- (void)stop;

@end
