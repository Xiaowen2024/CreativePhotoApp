//
//  StyleTransfer.cpp
//  CreativePhoto
//
//  Created by Xiaowen Yuan on 3/13/24.
//  Copyright © 2024 Anurag Ajwani. All rights reserved.
//

#include "StyleTransfer.hpp"
#include <opencv2/opencv.hpp>

using namespace cv;

cv::Mat getBlobFromImage(const std::vector<int>& inputSize, const std::vector<int>& mean, float std, bool swapRB, Mat image) {
    
    cv::Mat matC3;
    cv::cvtColor(image, matC3, cv::COLOR_RGBA2BGR);
    cv::Mat input = cv::dnn::blobFromImage(matC3, std, cv::Size(inputSize[0], inputSize[1]), cv::Scalar(mean[0], mean[1], mean[2]), swapRB, false);
    return input;
}

cv::Mat postProcess(const cv::Mat& result, const std::vector<int>& mean) {
    std::vector<float> normData;
    const float* resultData = reinterpret_cast<float*>(result.data);
    const int C = result.size[1];
    const int H = result.size[2];
    const int W = result.size[3];
    
    for (int h = 0; h < H; ++h) {
        for (int w = 0; w < W; ++w) {
            for (int c = 0; c < C; ++c) {
                normData.push_back(resultData[c * H * W + h * W + w] + mean[c]);
            }
            normData.push_back(255);
        }
    }
    
    cv::Mat output(H, W, CV_8UC4);
//    std::memcpy(output.data, normData.data(), normData.size() * sizeof(float));
    return output;
}

cv::Mat performInference(cv::dnn::Net& net, const cv::Mat& inputBlob) {
    net.setInput(inputBlob);
    cv::Mat result = net.forward();
    return result;
}

Mat StyleTransfer::tranferImage(Mat image){
    std::vector<int> inputSize = {224, 224};
    std::vector<int> mean = {104, 117, 123};
    float std = 1.0;
    bool swapRB = false;
    
//    cv::dnn::Net net = cv::dnn::readNet("starry_night.t7");
//    cv::Mat matC3;
//    cv::cvtColor(image, matC3, cv::COLOR_RGBA2BGR);
//    cv::Mat input = cv::dnn::blobFromImage(matC3, /*scale factor*/ 1.0,
//                                                cv::Size(inputSize[0], inputSize[1]),
//                                                cv::Scalar(mean[0], mean[1], mean[2]),
//                                                swapRB,
//                                                /*crop*/ false);
//    cv::Mat output = net.forward();
    cv::dnn::Net net = cv::dnn::readNet("starry_night.t7");
    image = getBlobFromImage(inputSize, mean, std, swapRB, image);
    cv::Mat result = performInference(net, image);
    return result;
    
}




