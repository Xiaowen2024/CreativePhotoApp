//
//  LaneDetector.cpp
//  SimpleLaneDetection
//
//  Created by Anurag Ajwani on 28/04/2019.
//  Copyright © 2019 Anurag Ajwani. All rights reserved.
//

#include <opencv2/opencv.hpp>
#include "EdgeDetector.hpp"

using namespace cv;
using namespace std;

Mat dst, detected_edges;
int lowThreshold = 0;
const int max_lowThreshold = 100;
const int ratio = 3;
const int kernel_size = 3;
const char* window_name = "Edge Map";



Mat colorizeEdges(Mat grayscaleImage, Mat edgeImage) {
    Mat coloredImage(grayscaleImage.size(), CV_8UC3); // Create a 3-channel image for colorization

    for (int y = 0; y < grayscaleImage.rows; y++) {
        for (int x = 0; x < grayscaleImage.cols; x++) {
            if (edgeImage.at<uchar>(y, x) > 0) { // If it's an edge pixel
                coloredImage.at<Vec3b>(y, x) = Vec3b(0, 255, 255); // Color it with yellow (BGR format)
            } else {
                coloredImage.at<Vec3b>(y, x) = Vec3b(grayscaleImage.at<uchar>(y, x), grayscaleImage.at<uchar>(y, x), grayscaleImage.at<uchar>(y, x)); // Keep the grayscale intensity
            }
        }
    }

    return coloredImage;
}
Mat EdgeDetector::detect_edge(Mat image) {
    Mat imageGray;
    int ratio = 3;
    cv::cvtColor(image, imageGray, cv::COLOR_BGR2GRAY);
    blur(imageGray, detected_edges, Size(3,3));
    Canny( detected_edges, detected_edges, lowThreshold, lowThreshold*ratio, kernel_size );
    Mat coloredEdges = colorizeEdges(imageGray, detected_edges);

     return coloredEdges;
}
