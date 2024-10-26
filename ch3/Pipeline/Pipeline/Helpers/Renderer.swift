//
//  Renderer.swift
//  Pipeline
//
//  Created by Nikolai Baklanov on 26.10.2024.
//

import Foundation
import MetalKit

class Renderer: NSObject {
    static var mtlDevice: MTLDevice!
    static var commandQueue: MTLCommandQueue!
    static var library: MTLLibrary!

    var mesh: MTKMesh!
    var vertexBuffer: MTLBuffer!
    var pipelineState: MTLRenderPipelineState!


    init(metalView: MTKView) {
        guard let device = MTLCreateSystemDefaultDevice(),
              let commandQueue = device.makeCommandQueue() else {
            fatalError("GPU is not available!")
        }

        Renderer.mtlDevice = device
        Renderer.commandQueue = commandQueue
        metalView.device = device

        let allocator = MTKMeshBufferAllocator(device: device)
        let size: Float = 0.8

        let vertexDescriptior = MTLVertexDescriptor()
        vertexDescriptior.attributes[0].format = .float3
        vertexDescriptior.attributes[0].offset = 0
        vertexDescriptior.attributes[0].bufferIndex = 0
        vertexDescriptior.layouts[0].stride = MemoryLayout<SIMD3<Float>>.stride

        let meshDescriptor = MTKModelIOVertexDescriptorFromMetal(vertexDescriptior)
        (meshDescriptor.attributes[0] as! MDLVertexAttribute).name = MDLVertexAttributePosition

        guard let assetUrl = Bundle.main.url(forResource: "train", withExtension: "usd") else {
            fatalError()
        }
        let asset = MDLAsset(url: assetUrl, vertexDescriptor: meshDescriptor, bufferAllocator: allocator)
        let mdlMesh = asset.childObjects(of: MDLMesh.self).first as! MDLMesh
//        let mdlMesh = MDLMesh(boxWithExtent: [size, size, size],
//                              segments: [1, 1, 1],
//                              inwardNormals: false,
//                              geometryType: .triangles,
//                              allocator: allocator)

        do {
            mesh = try MTKMesh(mesh: mdlMesh, device: device)
        } catch {
            print(error.localizedDescription)
        }
        vertexBuffer = mesh.vertexBuffers[0].buffer

        let library = device.makeDefaultLibrary()
        Renderer.library = library

        let vertexFunction = library?.makeFunction(name: "vertex_main")
        let frameFunction = library?.makeFunction(name: "fragment_main")

        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = frameFunction
        pipelineDescriptor.colorAttachments[0].pixelFormat = metalView.colorPixelFormat
        pipelineDescriptor.vertexDescriptor = MTKMetalVertexDescriptorFromModelIO(mdlMesh.vertexDescriptor)
        do {
            pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch {
            fatalError(error.localizedDescription)
        }

        super.init()

        metalView.clearColor = MTLClearColor(red: 1.0, green: 1.0, blue: 0.8, alpha: 1.0)
        metalView.delegate = self
    }
}

extension Renderer: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {

    }

    func draw(in view: MTKView) {
        guard let commandBuffer = Renderer.commandQueue.makeCommandBuffer(),
              let descriptor = view.currentRenderPassDescriptor,
              let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor) else {
            return
        }

        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        for submesh in mesh.submeshes {
            renderEncoder.drawIndexedPrimitives(
                type: .triangle,
                indexCount: submesh.indexCount,
                indexType: submesh.indexType,
                indexBuffer: submesh.indexBuffer.buffer,
                indexBufferOffset: submesh.indexBuffer.offset)
        }

        renderEncoder.endEncoding()

        guard let drawable = view.currentDrawable else { return }
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}
