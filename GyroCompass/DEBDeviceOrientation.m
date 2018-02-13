//
//  DEBDeviceOrientation.m
//  GyroCompass
//
//  Created by Takaaki Tanaka on 2014/03/31.
//  Copyright (c) 2014年 Takaaki Tanaka. All rights reserved.
//

@import CoreMotion;
#import "DEBDeviceOrientation.h"

#define kUpdateFrequency 30.0
#define kCutoffFrequency  5.0
#define kTransitionDelay  0.5
#define DEGREES_TO_RADIANS(__ANGLE__) ((__ANGLE__) / 180.0 * M_PI)
#define RADIANS_TO_DEGREES(__ANGLE__) ((__ANGLE__) * (180.0 / M_PI))
#define kDT 1 / kUpdateFrequency

@interface DEBDeviceOrientation ()
@property(strong,nonatomic) CMMotionManager *motionManager;
@property(strong,nonatomic) CLLocationManager *locationManager;
@property(strong,nonatomic) NSOperationQueue *deviceMotionQueue;
@property(readwrite) UIDeviceOrientation deviceOrientation;
@property(strong,readwrite) CLLocation *location;
@property(readwrite) double filterConstant;
@property(readwrite) double x;
@property(readwrite) double y;
@property(readwrite) double z;
@property(readwrite) double roll;
@property(readwrite) double pitch;
@property(readwrite) double yaw;
@property(readwrite) double bpx;
@property(readwrite) double bpy;
@property(readwrite) double bpz;
@property(readwrite) double deviceAngle;
@property(readwrite) CLLocationDirection magneticHeading;
@property(readwrite) CLLocationDirection trueHeading;
- (void)deviceOrientationUpdate;
-(void)lowpassFilterAccelerationX:(UIAccelerationValue)aX y:(UIAccelerationValue)aY z:(UIAccelerationValue)aZ;
@end

@implementation DEBDeviceOrientation

- (id)init {
    self = [super self];
    if (self) {
        self.locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.distanceFilter = 5;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        _locationManager.headingFilter = kCLHeadingFilterNone;
        self.motionManager = [[CMMotionManager alloc] init];
        _motionManager.accelerometerUpdateInterval = 1.0 / kUpdateFrequency;
        _motionManager.deviceMotionUpdateInterval = 1.0 / kUpdateFrequency;
        self.deviceMotionQueue = [[NSOperationQueue alloc] init];
        self.trueHeading = -1.0;
        CLLocationCoordinate2D coordinate = kCLLocationCoordinate2DInvalid;
        self.location = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
        double dt = 1.0 / kUpdateFrequency;
		double RC = 1.0 / kCutoffFrequency;
        self.filterConstant = RC / (dt + RC);
    }
    return self;
}

- (void)start {
    if (_locationManager && ([CLLocationManager locationServicesEnabled])) {
        [_locationManager startUpdatingLocation];
    }
    if (_locationManager && [CLLocationManager headingAvailable]) {
        [_locationManager startUpdatingHeading];
    }
    if (_motionManager) {
        BOOL enableGyro = _motionManager.deviceMotionAvailable;
        if (enableGyro) {
            CMDeviceMotionHandler deviceMotionHandler = ^(CMDeviceMotion *motion, NSError *error) {
                if (!error) {
                    double accelerationX = motion.gravity.x;
                    double accelerationY = motion.gravity.y;
                    double accelerationZ = motion.gravity.z;
                    [self lowpassFilterAccelerationX:accelerationX y:accelerationY z:accelerationZ];
                    [self deviceOrientationUpdate];
                    // yaw
                    double angle = RADIANS_TO_DEGREES(atan2(accelerationX, -accelerationY));
                    for (;;) {
                        double gap = _yaw - angle;
                        if (gap > 180) {
                            angle += 360;
                        } else if (gap <= -180) {
                            angle -= 360;
                        } else {
                            break;
                        }
                    }
                    self.yaw = (0.94 * (_yaw + RADIANS_TO_DEGREES(-motion.rotationRate.z) * kDT)) + (0.06 * angle);
                    // pitch
                    double g = sqrt(pow(accelerationX, 2) + pow(accelerationY, 2) + pow(accelerationZ, 2));
                    double slope = -(RADIANS_TO_DEGREES(asin(accelerationZ / g)));
                    double pitch = (motion.rotationRate.x * cos(DEGREES_TO_RADIANS(_yaw))) + (motion.rotationRate.y * sin(DEGREES_TO_RADIANS(_yaw)));
                    for (;;) {
                        double gap = _pitch - slope;
                        if (gap > 180) {
                            slope += 360;
                        } else if (gap <= -180) {
                            slope -= 360;
                        } else {
                            break;
                        }
                    }
                    self.pitch = (0.94 * (_pitch + RADIANS_TO_DEGREES(-pitch) * kDT)) + (0.06 * slope);
                    // roll
                    double heading = _trueHeading;
                    double roll = (motion.rotationRate.x * -sin(DEGREES_TO_RADIANS(_yaw))) + (motion.rotationRate.y * cos(DEGREES_TO_RADIANS(_yaw)));
                    for (;;) {
                        double gap = _roll - heading;
                        if (gap > 180) {
                            heading += 360;
                        } else if (gap <= -180) {
                            heading -= 360;
                        } else {
                            break;
                        }
                    }
                    self.roll = (0.98 * (_roll + RADIANS_TO_DEGREES(-roll) * kDT)) + (0.02 * heading);
                }
            };
            [_motionManager startDeviceMotionUpdatesToQueue:_deviceMotionQueue withHandler:deviceMotionHandler];
        } else {
            if (_motionManager.accelerometerAvailable) {
                CMAccelerometerHandler accelerometerHandler = ^(CMAccelerometerData *accelerometerData, NSError *error) {
                    if (!error) {
                        double accelerationX = accelerometerData.acceleration.x;
                        double accelerationY = accelerometerData.acceleration.y;
                        double accelerationZ = accelerometerData.acceleration.z;
                        [self lowpassFilterAccelerationX:accelerationX y:accelerationY z:accelerationZ];
                        [self deviceOrientationUpdate];
                        double g = sqrt(pow(_x, 2) + pow(_y, 2) + pow(_z, 2));
                        double slope = -(RADIANS_TO_DEGREES(asin(_z / g)));
                        double angle = RADIANS_TO_DEGREES(atan2f(-_x, _y) + M_PI);
                        self.pitch = slope;
                        self.yaw = angle;
                        self.roll = _trueHeading;
                    }
                };
                [_motionManager startAccelerometerUpdatesToQueue:_deviceMotionQueue withHandler:accelerometerHandler];
            }
        }
    }
}

- (void)stop {
    if (_locationManager) {
        [_locationManager stopUpdatingLocation];
    }
    if (_locationManager) {
        [_locationManager stopUpdatingHeading];
    }
    if (_motionManager) {
        BOOL enableGyro = _motionManager.deviceMotionAvailable;
        if (enableGyro) {
            [_motionManager stopDeviceMotionUpdates];
        } else {
            if (_motionManager.accelerometerAvailable) {
                [_motionManager stopAccelerometerUpdates];
            }
        }
    }
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    if (!CLLocationCoordinate2DIsValid(newLocation.coordinate)) {
        return;
    }
    NSDate *eventDate = newLocation.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    if (abs(howRecent) < 15.0) {
        self.location = newLocation;
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"%s: %@", __PRETTY_FUNCTION__, error);
    if (error.code == kCLErrorDenied) {
        // TODO
    }
}

- (void)locationManager:(CLLocationManager*)manager didUpdateHeading:(CLHeading*)newHeading {
    if (newHeading.headingAccuracy > 0) {
        BOOL enableGyro = _motionManager ? _motionManager.deviceMotionAvailable : NO;
        // use the NED (North, East, Down) coordinate system
        // gp: phone accelerometer value
        double gpx, gpy, gpz;
        if (enableGyro) {
            CMDeviceMotion *motion = _motionManager.deviceMotion;
            gpx = -motion.gravity.z;
            gpy =  motion.gravity.x;
            gpz = -motion.gravity.y;
        } else {
            gpx = -_z;
            gpy =  _x;
            gpz = -_y;
        }
        // calculate Roll (phi) and Pitch (theta)
        double phi = atan2(gpy, gpz);
        double theta = atan2(-gpx, (gpy * sin(phi)) + (gpz * cos(phi)));
        // bp: phone magnetometer value
        if (enableGyro) {
            _bpx = -newHeading.z;
            _bpy =  newHeading.x;
            _bpz = -newHeading.y;
        } else {
            double bpx, bpy, bpz;
            bpx = -newHeading.z;
            bpy =  newHeading.x;
            bpz = -newHeading.y;
            double alpha = 0.1;
            _bpx = bpx * alpha + _bpx * (1.0 - alpha);
            _bpy = bpy * alpha + _bpy * (1.0 - alpha);
            _bpz = bpz * alpha + _bpz * (1.0 - alpha);
        }
        // bf: corrected magnetometer value
        double bfy, bfx;
        bfy = (_bpy * cos(phi)) - (_bpz * sin(phi));
        bfx = (_bpx * cos(theta)) + (_bpy * sin(theta) * sin(phi)) + (_bpz * sin(theta) * cos(phi));
        // calculate Yaw (psi)
        double psi = atan2(-bfy, bfx);
        double magneticHeading = psi / M_PI * 180.0;
        double magneticDeclination = newHeading.trueHeading < 0.0 ? 0.0 : newHeading.trueHeading - newHeading.magneticHeading;
        if (magneticDeclination > 180.0) {
            magneticDeclination -= 360.0;
        }
        double trueHeading = magneticHeading + magneticDeclination;
        _magneticHeading = (magneticHeading < 0.0) ? (magneticHeading + 360.0) : magneticHeading;
        if (enableGyro) {
            _trueHeading = trueHeading;
        } else {
            _trueHeading = (trueHeading < 0.0) ? (trueHeading + 360.0) : trueHeading;
        }
    }
}

- (BOOL)locationManagerShouldDisplayHeadingCalibration:(CLLocationManager *)manager {
    return YES;
}

#pragma mark - Anonymous category

- (void)deviceOrientationUpdate {
    double angle = atan2f(-_x , _y);
    self.deviceAngle = RADIANS_TO_DEGREES(angle + M_PI);
    if ((_deviceAngle >= 330) || (_deviceAngle <= 30)) {
        self.deviceOrientation = UIDeviceOrientationPortrait;
    } else if ((_deviceAngle >= 60) && (_deviceAngle <= 120)) {
        self.deviceOrientation = UIDeviceOrientationLandscapeRight;
    } else if ((_deviceAngle >= 150) && (_deviceAngle <= 210)) {
        self.deviceOrientation = UIDeviceOrientationPortraitUpsideDown;
    } else if ((_deviceAngle >= 240) && (_deviceAngle <= 300)) {
        self.deviceOrientation = UIDeviceOrientationLandscapeLeft;
    }
}

-(void)lowpassFilterAccelerationX:(UIAccelerationValue)aX y:(UIAccelerationValue)aY z:(UIAccelerationValue)aZ {
	double alpha = _filterConstant;
	self.x = aX * alpha + _x * (1.0 - alpha);
	self.y = aY * alpha + _y * (1.0 - alpha);
	self.z = aZ * alpha + _z * (1.0 - alpha);
}

@end
