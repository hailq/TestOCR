//
//  ViewController.m
//  TestOpenCV
//
//  Created by Hai Luong Quang on 2/21/17.
//  Copyright © 2017 Hai Luong Quang. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () {
    int frameCount;
    NSMutableArray *cacheBoxes;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //    // Setup draw layer
    //    self.drawView = [[UIView alloc] init];
    //    [self.drawView setFrame:self.view.frame];
    ////    [self.drawView setBackgroundColor:[UIColor greenColor]];
    //    [self.view addSubview:self.drawView];
    
    frameCount = 0;
    cacheBoxes = [[NSMutableArray alloc] init];
    
    self.videoCamera = [[CvVideoCamera alloc] initWithParentView:self.imageView];
    self.videoCamera.delegate = self;
    self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack;
    self.videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPresetHigh;
    self.videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
    self.videoCamera.rotateVideo = YES;
    self.videoCamera.defaultFPS = 30;
    self.videoCamera.grayscaleMode = NO;
    
    [self.videoCamera start];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - CvVideoCameraDelegate methods
- (void)processImage:(Mat&)image{
    
    // Process 10 frame per second
    frameCount++;
    frameCount = (frameCount > 30) ? 0 : frameCount;
    
    if (frameCount % 3 == 0) {
        
        Mat imageCopy;
        Mat otsuCrop;
        
        /* Clear cache */
        [cacheBoxes removeAllObjects];
        
        /**
         Preprocessing image: grayscale -> blur -> binarise -> dilate
         */
        float imageWidth = image.cols;
        float imageHeight = image.rows;
        
        float newWidth = image.cols * 20 / 100;
        float newHeight = image.rows * 20 / 100;
        
        cv::resize(image, imageCopy, cv::Size((int)newWidth, (int)newHeight));
        
        cvtColor(imageCopy, imageCopy, COLOR_BGR2GRAY);
        
        GaussianBlur(imageCopy, imageCopy, cv::Size(13, 13), 0);
        adaptiveThreshold(imageCopy, imageCopy, 255, ADAPTIVE_THRESH_GAUSSIAN_C, THRESH_BINARY_INV, 15, 5);
        
        // Crop a kernel image size 100x20 for calculating otsu threshold value
        //    cv::Rect roi((int)newWidth / 2 - 50, (int)newHeight / 4 - 10, 100, 20);
        //    otsuCrop = imageCopy(roi);
        //    double threshValue = cv::threshold(otsuCrop, otsuCrop, 0, 255, THRESH_BINARY_INV+THRESH_OTSU);
        //    NSLog(@"Thresh value: %f", threshValue);
        // Apply threshold value to all image
        //    cv::threshold(imageCopy, imageCopy, 0, 255, THRESH_BINARY_INV+THRESH_OTSU);
        
        dilate(imageCopy, imageCopy, cv::Mat(5, 5, CV_8U), cv::Point(-1, -1), 1);
        dilate(imageCopy, imageCopy, cv::Mat(3, 13, CV_8U), cv::Point(-1, -1), 1);
        
        
        /**
         Main processing
         */
        std::vector<std::vector<cv::Point>> contours;
        std::vector<cv::Vec4i> hierachy;
        cv::findContours(imageCopy, contours, hierachy, cv::RETR_EXTERNAL, cv::CHAIN_APPROX_NONE);
        
        // Find max_area
        int max_area = 0;
        for (int i = 0; i < contours.size(); i++){
            cv::Rect r = cv::boundingRect(contours[i]);
            
            if (r.width < 10 && r.height < 10) {
                continue;
            }
            
            if (max_area == 0 || max_area < (r.width * r.height)) {
                max_area = r.width * r.height;
            }
        }
        
        
        for (int i = 0; i < contours.size(); i++){
            cv::Rect r = cv::boundingRect(contours[i]);
            
            if (r.width < 10 && r.height < 10) {
                continue;
            }
            
            if (r.width * r.height < (max_area / 10)) {
                continue;
            }
            
            // Convert to original image
            int orgX = (r.x / newWidth) * imageWidth;
            int orgY = (r.y / newHeight) * imageHeight;
            int orgW = (r.width / newWidth) * imageWidth;
            int orgH = (r.height / newHeight) * imageHeight;
            
            // Cache
            [cacheBoxes addObject: @{
                                     @"x": [NSNumber numberWithInt:orgX],
                                     @"y": [NSNumber numberWithInt:orgY],
                                     @"w": [NSNumber numberWithInt:orgW],
                                     @"h": [NSNumber numberWithInt:orgH]
                                     }
             ];
            
            cv::rectangle(image, cv::Point(orgX, orgY), cv::Point(orgX + orgW, orgY + orgH), cv::Scalar(0, 255, 0), 4);
        }
        
        //    cv::rectangle(image, cv::Point(0, 0), cv::Point(120, 120), cv::Scalar(0, 255, 0));
        
        //        cvtColor(imageCopy, image, COLOR_GRAY2BGRA);
        
        //    threshold(image, image, 0, 255, THRESH_BINARY_INV+THRESH_OTSU);
        
        
        //    dilate(image, image, Mat());
        
        //    Canny(image, image, 0, 0);
        
    } else {
        
        // Draw bounding boxes from cache
        for (NSDictionary* cache in cacheBoxes) {
            cv::rectangle(image,
                          cv::Point([cache[@"x"] intValue], [cache[@"y"] intValue]),
                          cv::Point([cache[@"x"] intValue] + [cache[@"w"] intValue], [cache[@"y"] intValue] + [cache[@"h"] intValue]),
                          cv::Scalar(0, 255, 0),
                          4);
        }
    }
}

@end
