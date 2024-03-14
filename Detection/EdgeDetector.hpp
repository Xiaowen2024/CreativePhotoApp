//
//  LaneDetector.hpp
//  SimpleLaneDetection
//
//  Created by Anurag Ajwani on 28/04/2019.
//  Copyright © 2019 Anurag Ajwani. All rights reserved.
//

#include <opencv2/opencv.hpp>

using namespace cv;
using namespace std;

class EdgeDetector {
    
    public:
    
    /*
     Returns image with lane overlay
     */
    Mat detect_edge(Mat image);
    
};
