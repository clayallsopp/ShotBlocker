//
//  ShotBlocker.h
//  ShotBlocker
//
//  Created by Clay Allsopp on 12/26/12.
//  Copyright (c) 2012 Clay Allsopp. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^ShotBlockerScreenshotBlock)();
typedef void (^ShotBlockerScreenshotImageBlock)(UIImage *screenshot);
typedef void (^ShotBlockerScreenshotErrorBlock)(NSError *error);

@interface ShotBlocker : NSObject

+ (ShotBlocker *)sharedManager;

// Callbacks run on the main thread.
- (void)detectScreenshotWithBlock:(ShotBlockerScreenshotBlock)block;
- (void)detectScreenshotWithBlock:(ShotBlockerScreenshotBlock)block andErrorBlock:(ShotBlockerScreenshotErrorBlock)errorBlock;
- (void)detectScreenshotWithImageBlock:(ShotBlockerScreenshotImageBlock)block;
- (void)detectScreenshotWithImageBlock:(ShotBlockerScreenshotImageBlock)block andErrorBlock:(ShotBlockerScreenshotErrorBlock)errorBlock;
;

- (void)stopDetectingScreenshots;

@end
