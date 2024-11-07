import MetalKit

struct ForwardRenderPass: RenderPass {
    let label = "Forward Render Pass"
    var descriptor: MTLRenderPassDescriptor?

    var pipelineState: MTLRenderPipelineState
    let depthStencilState: MTLDepthStencilState?
    weak var shadowTexture: MTLTexture?

    init(view: MTKView) {
        pipelineState = PipelineStates.createForwardPSO(
            colorPixelFormat: view.colorPixelFormat)
        depthStencilState = Self.buildDepthStencilState()
    }

    mutating func resize(view: MTKView, size: CGSize) {
    }

    func draw(
        commandBuffer: MTLCommandBuffer,
        scene: GameScene,
        uniforms: Uniforms,
        params: Params
    ) {
        guard let descriptor = descriptor,
              let renderEncoder =
                commandBuffer.makeRenderCommandEncoder(
                    descriptor: descriptor) else {
            return
        }
        renderEncoder.label = label
        renderEncoder.setDepthStencilState(depthStencilState)
        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.setFrontFacing(.counterClockwise)
        renderEncoder.setCullMode(.back)
        
        renderEncoder.setFragmentBuffer(
            scene.lighting.lightsBuffer,
            offset: 0,
            index: LightBuffer.index)
        renderEncoder.setFragmentTexture(shadowTexture, index: ShadowTexture.index)
        for model in scene.models {
            model.render(
                encoder: renderEncoder,
                uniforms: uniforms,
                params: params)
        }
        renderEncoder.endEncoding()
    }
}
