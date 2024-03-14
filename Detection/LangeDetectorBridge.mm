//
//  LangeDetectorBridge.m
//  SimpleLaneDetection
//
//  Created by Anurag Ajwani on 28/04/2019.
//  Copyright © 2019 Anurag Ajwani. All rights reserved.
//

#import <opencv2/opencv.hpp>
#import <opencv2/imgcodecs/ios.h>
#import <Foundation/Foundation.h>
#import "DetectorBridge.h"
#include "EdgeDetector.hpp"
#include "StyleTransfer.hpp"


@implementation DetectorBridge
    
- (UIImage *) detectLaneIn: (UIImage *) image {
    
    // convert uiimage to mat
    cv::Mat opencvImage;
    UIImageToMat(image, opencvImage, true);
    
    // convert colorspace to the one expected by the lane detector algorithm (RGB)
    cv::Mat convertedColorSpaceImage;
    cv::cvtColor(opencvImage, convertedColorSpaceImage, CV_RGBA2RGB);
    
    // Run lane detection
//    EdgeDetector laneDetector;
//    cv::Mat imageWithLaneDetected = laneDetector.detect_edge(convertedColorSpaceImage);
    
    StyleTransfer st;
    cv::Mat imageDetected = st.tranferImage(convertedColorSpaceImage);
        
    // convert mat to uiimage and return it to the caller
    return MatToUIImage(imageDetected);
}
    
    @end
