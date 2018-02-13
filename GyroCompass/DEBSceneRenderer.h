//
//  DEBSceneRenderer.h
//  GyroCompass
//
//  Created by Takaaki Tanaka on 2014/03/31.
//  Copyright (c) 2014年 Takaaki Tanaka. All rights reserved.
//

#import "DEBMultiSampleRenderer.h"

@interface DEBSceneRenderer : DEBMultiSampleRenderer
@property double roll;
@property double pitch;
@property double yaw;
- (void)start;
- (void)stop;
@end