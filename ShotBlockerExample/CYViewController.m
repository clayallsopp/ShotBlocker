//
//  CYViewController.m
//  ShotBlocker
//
//  Created by Clay Allsopp on 12/26/12.
//  Copyright (c) 2012 Clay Allsopp. All rights reserved.
//

#import "CYViewController.h"

#import "ShotBlocker.h"

@interface CYViewController ()

@end

@implementation CYViewController
@synthesize imageView=_imageView;
@synthesize stopButton=_stopButton;

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.imageView.contentMode = UIViewContentModeScaleAspectFit;
  self.imageView.backgroundColor = UIColor.whiteColor;
  self.stopButton.enabled = NO;
}

- (IBAction)startWatch:(id)sender {
  NSLog(@"Starting...");
  [[ShotBlocker sharedManager] detectScreenshotWithImageBlock:^(UIImage *screenshot) {
    NSLog(@"Screenshot! %@", screenshot);
    self.imageView.image = screenshot;
    [self.imageView setNeedsDisplay];
  }];
  self.stopButton.enabled = YES;
}

- (IBAction)endWatch:(id)sender {
  NSLog(@"Ending...");
  [[ShotBlocker sharedManager] stopDetectingScreenshots];
  self.stopButton.enabled = NO;
}

@end
