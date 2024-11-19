import MetalKit

// swiftlint:disable superfluous_disable_command
// swiftlint:disable identifier_name

struct ForwardRenderPass: RenderPass {
    let label = "Forward Render Pass"
    var descriptor: MTLRenderPassDescriptor?

    var transparentPSO: MTLRenderPipelineState
    var pipelineState: MTLRenderPipelineState

    var pipelineState_M: MTLRenderPipelineState
    var transparentPSO_M: MTLRenderPipelineState

    let depthStencilState: MTLDepthStencilState?

    weak var shadowTexture: MTLTexture?

    init() {
        pipelineState = PipelineStates.createForwardPSO()
        pipelineState_M = PipelineStates.createForwardPSO_M()

        depthStencilState = Self.buildDepthStencilState()

        transparentPSO = PipelineStates.createForwardTransparentPSO()
        transparentPSO_M = PipelineStates.createForwardTransparentPSO_M()
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
        let pipelineState = params.antialiasing ? pipelineState_M : pipelineState
        let transparentPSO = params.antialiasing ? transparentPSO_M : transparentPSO

        renderEncoder.label = label
        renderEncoder.setDepthStencilState(depthStencilState)
        renderEncoder.setRenderPipelineState(pipelineState)
        //renderEncoder.setRenderPipelineState(transparentPSO)

        renderEncoder.setFragmentBuffer(
            scene.lighting.lightsBuffer,
            offset: 0,
            index: LightBuffer.index)
        renderEncoder.setFragmentTexture(shadowTexture, index: ShadowTexture.index)

        if params.scissorTesting {
            let marginWidth = Int(params.width) / 4
            let marginHeight = Int(params.height) / 4
            let width = Int(params.width) / 2
            let height = Int(params.height) / 2
            let rect = MTLScissorRect(x: marginWidth, y: marginHeight, width: width, height:height)
            renderEncoder.setScissorRect(rect)
        }

        var params = params
        params.transparency = false

        for model in scene.models {
            model.render(
                encoder: renderEncoder,
                uniforms: uniforms,
                params: params)
        }

        // transparent mesh
        renderEncoder.pushDebugGroup("Transparency")
        let models = scene.models.filter { $0.hasTransparency }

        params.transparency = true
        if params.alphaBlending {
            renderEncoder.setRenderPipelineState(transparentPSO)
        }

        for model in models {
            model.render(encoder: renderEncoder, uniforms: uniforms, params: params)
        }
        renderEncoder.popDebugGroup()

        renderEncoder.endEncoding()
    }
}
