//
//  ViewController.h
//  TestOpenCV
//
//  Created by Hai Luong Quang on 2/21/17.
//  Copyright © 2017 Hai Luong Quang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <opencv2/core.hpp>
#import <opencv2/imgproc.hpp>
#import <opencv2/videoio/cap_ios.h>

using namespace cv;

@interface ViewController : UIViewController<CvVideoCameraDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic) UIView *drawView;

@property (nonatomic, retain) CvVideoCamera *videoCamera;

@end

