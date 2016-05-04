//
//  ViewController.h
//  FoosballCameraController
//
//  Created by Michael Ozeryansky on 4/27/16.
//  Copyright © 2016 Michael Ozeryansky. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <opencv2/videoio/cap_ios.h>

@interface ViewController : UIViewController<CvVideoCameraDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

