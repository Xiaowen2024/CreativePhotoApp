//
//  LightMetalRenderer.swift
//  AVCamFilter
//
//  Created by Xiaowen Yuan on 3/15/25.
//  Copyright © 2025 Apple. All rights reserved.
//

import CoreMedia
import CoreVideo
import Metal

class LightMetalRenderer: FilterRenderer {
    
    var description: String = "Light (Metal)"
    
    var isPrepared = false
    
    private(set) var inputFormatDescription: CMFormatDescription?
    
    private(set) var outputFormatDescription: CMFormatDescription?
    
    private var outputPixelBufferPool: CVPixelBufferPool?
    
    private let metalDevice = MTLCreateSystemDefaultDevice()!
    
    private var renderPipelineState: MTLRenderPipelineState?
    
    private var textureCache: CVMetalTextureCache!
    
    private var vertexBuffer: MTLBuffer?

    private var inputTexture: MTLTexture!
    
    private lazy var commandQueue: MTLCommandQueue? = {
        return self.metalDevice.makeCommandQueue()
    }()
    
    required init() {
        let defaultLibrary = metalDevice.makeDefaultLibrary()!
        let vertexFunction = defaultLibrary.makeFunction(name: "vertexShader")
        let fragmentFunction = defaultLibrary.makeFunction(name: "fragmentShader")
        
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
           pipelineDescriptor.vertexFunction = vertexFunction
           pipelineDescriptor.fragmentFunction = fragmentFunction
           pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
           
       do {
           renderPipelineState = try metalDevice.makeRenderPipelineState(descriptor: pipelineDescriptor)
       } catch {
           print("Failed to create render pipeline state: \(error)")
       }

    }
    
    func currentRenderPassDescriptor(outputTexture: MTLTexture) -> MTLRenderPassDescriptor? {
        // Create a render pass descriptor
        let descriptor = MTLRenderPassDescriptor()
        
        // Set up the color attachment (the texture where the result will be written)
        let colorAttachment = descriptor.colorAttachments[0]
        colorAttachment?.texture = outputTexture // The output texture to render into
        colorAttachment?.loadAction = .clear  // Clear the texture before rendering (optional)
        colorAttachment?.clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 1) // Clear to black (optional)
        colorAttachment?.storeAction = .store // Store the result in the texture after rendering
        
        // You can set additional properties here if you need to handle depth or stencil attachments.
        // For example, if you had a depth texture:
        // descriptor.depthAttachment.texture = depthTexture
        // descriptor.depthAttachment.loadAction = .clear
        // descriptor.depthAttachment.storeAction = .store

        // Return the descriptor to be used for rendering
        return descriptor
    }

    
    func prepare(with formatDescription: CMFormatDescription, outputRetainedBufferCountHint: Int) {
        reset()
        
        (outputPixelBufferPool, _, outputFormatDescription) = allocateOutputBufferPool(with: formatDescription,
                                                                                       outputRetainedBufferCountHint: outputRetainedBufferCountHint)
        if outputPixelBufferPool == nil {
            return
        }
        inputFormatDescription = formatDescription
        
        var metalTextureCache: CVMetalTextureCache?
        if CVMetalTextureCacheCreate(kCFAllocatorDefault, nil, metalDevice, nil, &metalTextureCache) != kCVReturnSuccess {
            assertionFailure("Unable to allocate texture cache")
        } else {
            textureCache = metalTextureCache
        }
        
        isPrepared = true
    }
    
    func reset() {
        outputPixelBufferPool = nil
        outputFormatDescription = nil
        inputFormatDescription = nil
        textureCache = nil
        isPrepared = false
    }
    

    func render(pixelBuffer: CVPixelBuffer) -> CVPixelBuffer? {
        var newPixelBuffer: CVPixelBuffer?
        CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, outputPixelBufferPool!, &newPixelBuffer)
        guard let outputPixelBuffer = newPixelBuffer else {
            print("Allocation failure: Could not get pixel buffer from pool. (\(self.description))")
            return nil
        }
        guard let inputTexture = makeTextureFromCVPixelBuffer(pixelBuffer: pixelBuffer, textureFormat: .bgra8Unorm),
            let outputTexture = makeTextureFromCVPixelBuffer(pixelBuffer: outputPixelBuffer, textureFormat: .bgra8Unorm) else {
                return nil
        }
        
        
    
        guard let commandQueue = commandQueue,
            let commandBuffer = commandQueue.makeCommandBuffer(),
            let commandBuffer = commandQueue.makeCommandBuffer(),
            let renderPassDescriptor = currentRenderPassDescriptor(outputTexture: outputTexture),
            let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
                  return nil
              }

    
        renderEncoder.setRenderPipelineState(renderPipelineState!)
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        renderEncoder.setFragmentTexture(inputTexture, index: 0)
        
        renderEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
      
        renderEncoder.endEncoding()
        commandBuffer.commit()
        return outputPixelBuffer
    }
    
    func makeTextureFromCVPixelBuffer(pixelBuffer: CVPixelBuffer, textureFormat: MTLPixelFormat) -> MTLTexture? {
        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        
        // Create a Metal texture from the image buffer.
        var cvTextureOut: CVMetalTexture?
        CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault, textureCache, pixelBuffer, nil, textureFormat, width, height, 0, &cvTextureOut)
        
        guard let cvTexture = cvTextureOut, let texture = CVMetalTextureGetTexture(cvTexture) else {
            CVMetalTextureCacheFlush(textureCache, 0)
            
            return nil
        }
        
        return texture
    }
}
