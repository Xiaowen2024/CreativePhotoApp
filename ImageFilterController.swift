//
//  ImageFilterController.swift
//  PhotoJam
//
//  Created by Xiaowen Yuan on 6/9/24.
//
import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins

class FilterController {
    private let context = CIContext()
    
    func applySepiaTone(to inputImage: UIImage, intensity: Float = 1.0) -> UIImage? {
        guard let ciImage = CIImage(image: inputImage) else { return nil }
        
        let filter = CIFilter.sepiaTone()
        filter.inputImage = ciImage
        filter.intensity = intensity
        
        return processFilteredImage(filter: filter)
    }
    
    func applyGaussianBlur(to inputImage: UIImage, radius: Float = 10.0) -> UIImage? {
        guard let ciImage = CIImage(image: inputImage) else { return nil }
        
        let filter = CIFilter.gaussianBlur()
        filter.inputImage = ciImage
        filter.radius = radius
        
        return processFilteredImage(filter: filter)
    }
    
    private func processFilteredImage(filter: CIFilter) -> UIImage? {
        guard let outputImage = filter.outputImage,
              let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else {
            return nil
        }
        return UIImage(cgImage: cgImage)
    }
}
