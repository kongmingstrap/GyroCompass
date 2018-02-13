//
//  DEBGyroCompassScene.h
//  GyroCompass
//
//  Created by Takaaki Tanaka on 2014/03/31.
//  Copyright (c) 2014年 Takaaki Tanaka. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DEBGyroCompassScene : NSObject
@property(strong,readonly) NSString *name;
- (id)initWithName:(NSString *)name;
- (void)drawSceneCircle;
- (void)drawSceneHeading:(GLfloat)angle;
@end
