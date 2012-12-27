//
//  CYViewController.h
//  ShotBlocker
//
//  Created by Clay Allsopp on 12/26/12.
//  Copyright (c) 2012 Clay Allsopp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CYViewController : UIViewController

@property (nonatomic, strong) IBOutlet UIButton *stopButton;
@property (nonatomic, strong) IBOutlet UIImageView *imageView;

- (IBAction)startWatch:(id)sender;
- (IBAction)endWatch:(id)sender;

@end
