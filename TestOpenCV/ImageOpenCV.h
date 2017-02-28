//
//  ImageOpenCV.h
//  TestOpenCV
//
//  Created by Hai Luong Quang on 2/21/17.
//  Copyright © 2017 Hai Luong Quang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <opencv2/core.hpp>

@interface ImageOpenCV : NSObject

- (cv::Mat)cvMatFromUIImage:(UIImage *)image;

- (UIImage *)UIImageFromCVMat:(cv::Mat)cvMat;

@end
