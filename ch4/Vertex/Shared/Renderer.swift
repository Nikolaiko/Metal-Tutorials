import MetalKit

// swiftlint:disable implicitly_unwrapped_optional

class Renderer: NSObject {
    static var device: MTLDevice!
    static var commandQueue: MTLCommandQueue!
    static var library: MTLLibrary!

    var pipelineState: MTLRenderPipelineState!
    var timer: Float = 0.0

    lazy var quad: Quad = {
        Quad(device: Renderer.device, scale: 0.8)
    }()

    init(metalView: MTKView) {
        guard
            let device = MTLCreateSystemDefaultDevice(),
            let commandQueue = device.makeCommandQueue() else {
            fatalError("GPU not available")
        }
        Renderer.device = device
        Renderer.commandQueue = commandQueue
        metalView.device = device

        // create the shader function library
        let library = device.makeDefaultLibrary()
        Self.library = library
        let vertexFunction = library?.makeFunction(name: "vertex_main")
        let fragmentFunction =
        library?.makeFunction(name: "fragment_main")

        // create the pipeline state object
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.colorAttachments[0].pixelFormat =
        metalView.colorPixelFormat
        do {
            //pipelineDescriptor.vertexDescriptor = MTLVertexDescriptor.defaultLayout
            pipelineState =
            try device.makeRenderPipelineState(
                descriptor: pipelineDescriptor)
        } catch let error {
            fatalError(error.localizedDescription)
        }

        super.init()
        metalView.clearColor = MTLClearColor(
            red: 1.0,
            green: 1.0,
            blue: 0.8,
            alpha: 1.0)
        metalView.delegate = self
    }
}

extension Renderer: MTKViewDelegate {
    func mtkView(
        _ view: MTKView,
        drawableSizeWillChange size: CGSize
    ) {
    }

    func draw(in view: MTKView) {
        guard
            let commandBuffer = Renderer.commandQueue.makeCommandBuffer(),
            let descriptor = view.currentRenderPassDescriptor,
            let renderEncoder =
                commandBuffer.makeRenderCommandEncoder(
                    descriptor: descriptor) else {
            return
        }

        timer += 0.005
        var currentTime = sin(timer)
        var d = 50
        renderEncoder.setVertexBytes(&currentTime, length: MemoryLayout<Float>.stride, index: 11)
        renderEncoder.setVertexBytes(&d, length: MemoryLayout<Int>.stride, index: 12)

        renderEncoder.setRenderPipelineState(pipelineState)

        // do drawing here
//        renderEncoder.setVertexBuffer(quad.buffer, offset: 0, index: 0)
//        renderEncoder.setVertexBuffer(quad.colorBuffer, offset: 0, index: 1)
//        renderEncoder.drawIndexedPrimitives(type: .point,
//                                            indexCount: quad.indices.count,
//                                            indexType: .uint16,
//                                            indexBuffer: quad.indexBuffer,
//                                            indexBufferOffset: 0)

        renderEncoder.drawPrimitives(type: .point, vertexStart: 0, vertexCount: 50)

        renderEncoder.endEncoding()
        guard let drawable = view.currentDrawable else {
            return
        }
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}
