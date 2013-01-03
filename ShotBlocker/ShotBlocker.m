//
//  ShotBlocker.m
//  ShotBlocker
//
//  Created by Clay Allsopp on 12/26/12.
//  Copyright (c) 2012 Clay Allsopp. All rights reserved.
//

#import "ShotBlocker.h"
#import <AssetsLibrary/AssetsLibrary.h>

static NSTimeInterval const kShotBlockerUpdateInterval = 1.0;

@interface ShotBlocker() {
  dispatch_source_t _timer;
}
@property (readwrite, nonatomic, strong) NSMutableDictionary *groupCounts;
@property (readwrite, nonatomic, copy) ShotBlockerScreenshotBlock screenshotBlock;
@property (readwrite, nonatomic, copy) ShotBlockerScreenshotImageBlock imageBlock;
@property (readwrite, nonatomic, copy) ShotBlockerScreenshotErrorBlock errorBlock;

+ (ALAssetsLibrary *)assetsLibrary;

- (void)startTimer;
- (void)checkForNewScreenshot;
+ (BOOL)isScreenshot:(UIImage *)image;
@end

@implementation ShotBlocker
@synthesize groupCounts = _groupCounts;
@synthesize screenshotBlock = _screenshotBlock;
@synthesize imageBlock = _imageBlock;
@synthesize errorBlock = _errorBlock;

+ (ShotBlocker *)sharedManager {
  static ShotBlocker *_sharedManager = nil;
  static dispatch_once_t oncePredicate;
  dispatch_once(&oncePredicate, ^{
    _sharedManager = [[self alloc] init];
  });
  
  return _sharedManager;
}

+ (ALAssetsLibrary *)assetsLibrary {
  static dispatch_once_t oncePredicate;
  static ALAssetsLibrary *_library = nil;
  dispatch_once(&oncePredicate, ^{
    _library = [[ALAssetsLibrary alloc] init];
  });
  return _library;
}

- (void)detectScreenshotWithBlock:(ShotBlockerScreenshotBlock)block {
  self.screenshotBlock = block;
  
  [self startTimer];
}

- (void)detectScreenshotWithBlock:(ShotBlockerScreenshotBlock)block andErrorBlock:(ShotBlockerScreenshotErrorBlock)errorBlock {
  self.screenshotBlock = block;
  self.errorBlock = errorBlock;
  
  [self startTimer];
}

- (void)detectScreenshotWithImageBlock:(ShotBlockerScreenshotImageBlock)block {
  self.imageBlock = block;
  
  [self startTimer];
}

- (void)detectScreenshotWithImageBlock:(ShotBlockerScreenshotImageBlock)block andErrorBlock:(ShotBlockerScreenshotErrorBlock)errorBlock {
  self.imageBlock = block;
  self.errorBlock = errorBlock;
  
  [self startTimer];
}

- (void)stopDetectingScreenshots {
  if (_timer) {
    dispatch_suspend(_timer);
    dispatch_resume(_timer);
    _timer = nil;
  }
  self.groupCounts = nil;
  self.screenshotBlock = nil;
  self.imageBlock = nil;
  self.errorBlock = nil;
}

- (void)startTimer {
  uint64_t interval = kShotBlockerUpdateInterval * NSEC_PER_SEC;
  uint64_t leeway = 0.3 * interval; // 30% tolerance
  dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
  self.groupCounts = [NSMutableDictionary dictionary];
  
  if (_timer) {
    [self stopDetectingScreenshots];
  }
  
  _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
  if (_timer)
  {
    dispatch_source_set_timer(_timer, dispatch_walltime(NULL, 0), interval, leeway);
    dispatch_source_set_event_handler(_timer, ^(){
      [self checkForNewScreenshot];
    });
    dispatch_resume(_timer);
  }
}

- (void)checkForNewScreenshot {
  ALAssetsLibrary *library = [[self class] assetsLibrary];

  [library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
    
    if (group) {
      NSString *groupName = (NSString *)[group valueForProperty:ALAssetsGroupPropertyPersistentID];
      [group setAssetsFilter:[ALAssetsFilter allPhotos]];

      if ([self.groupCounts objectForKey:groupName] == nil) {
        [self.groupCounts setObject:[NSNumber numberWithInt:group.numberOfAssets] forKey:groupName];
      }

      if (group.numberOfAssets > [[self.groupCounts objectForKey:groupName] intValue]) {
        // Chooses the photo at the last index
        [group enumerateAssetsAtIndexes:[NSIndexSet indexSetWithIndex:([group numberOfAssets] - 1)] options:0 usingBlock:^(ALAsset *alAsset, NSUInteger index, BOOL *innerStop) {
          
          // The end of the enumeration is signaled by asset == nil.
          if (alAsset) {
            ALAssetRepresentation *representation = [alAsset defaultRepresentation];
            UIImage *latestPhoto = [UIImage imageWithCGImage:[representation fullScreenImage]];
            
            if ([[self class] isScreenshot:latestPhoto]) {
              dispatch_async(dispatch_get_main_queue(), ^() {
                if (self.screenshotBlock) {
                  self.screenshotBlock();
                }
                if (self.imageBlock) {
                  self.imageBlock(latestPhoto);
                }
              });
            }
            
            [self.groupCounts setObject:[NSNumber numberWithInt:group.numberOfAssets] forKey:groupName];
          }
        }];
      }
    }
  } failureBlock: ^(NSError *error) {
    if (self.errorBlock) {
      dispatch_async(dispatch_get_main_queue(), ^() {
        self.errorBlock(error);
      });
    }
    else {
      NSLog(@"Failed to access ALAssetsLibrary %@ with error: %@", library, error.localizedDescription);
    }

    [self stopDetectingScreenshots];
  }];
}

+ (BOOL)isScreenshot:(UIImage *)image {
  CGFloat imageWidth = image.size.width;
  CGFloat imageHeight = image.size.height;
  CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
  CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
  // imageWidth/Height is in points; screenWidth/Height is in pixels
  // so on a retina device, screenWidth/Height is 2x.
  // fmodf takes care of the scale factor for us, so we just compare
  // widths and heights to see if either orientation matches.
  return (fmodf(imageWidth, screenWidth) == 0 && fmodf(imageHeight, screenHeight) == 0) ||
         (fmodf(imageWidth, screenHeight) == 0 && fmodf(imageHeight, screenWidth) == 0);
}

@end
