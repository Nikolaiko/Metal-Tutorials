import MetalKit

// swiftlint:disable implicitly_unwrapped_optional

class Renderer: NSObject {
    static var device: MTLDevice!
    static var commandQueue: MTLCommandQueue!
    static var library: MTLLibrary!
    static var colorPixelFormat: MTLPixelFormat!
    var options: Options

    var uniforms = Uniforms()
    var params = Params()

    var forwardRenderPass: ForwardRenderPass
    var shadowRenderPass: ShadowRenderPass
    var shadowCamera = OrthographicCamera()

    init(metalView: MTKView, options: Options) {
        guard
            let device = MTLCreateSystemDefaultDevice(),
            let commandQueue = device.makeCommandQueue() else {
            fatalError("GPU not available")
        }
        Renderer.device = device
        Renderer.commandQueue = commandQueue
        Renderer.colorPixelFormat = metalView.colorPixelFormat
        metalView.device = device

        let library = device.makeDefaultLibrary()
        Self.library = library
        self.options = options
        forwardRenderPass = ForwardRenderPass()
        shadowRenderPass = ShadowRenderPass()
        super.init()
        metalView.clearColor = MTLClearColor(
            red: 0.93,
            green: 0.97,
            blue: 1.0,
            alpha: 1.0)
        metalView.depthStencilPixelFormat = .depth32Float
        mtkView(metalView, drawableSizeWillChange: metalView.bounds.size)
    }
}

extension Renderer {
    func mtkView(
        _ view: MTKView,
        drawableSizeWillChange size: CGSize
    ) {
        params.width = UInt32(size.width)
        params.height = UInt32(size.height)
        forwardRenderPass.resize(view: view, size: size)
        shadowRenderPass.resize(view: view, size: size)
    }

    func updateUniforms(scene: GameScene) {
        params.alphaTesting = options.alphaTesting
        params.scissorTesting = options.scissorTesting
        params.alphaBlending = options.alphaBlending
        params.antialiasing = options.antialiasing
        params.fog = options.fog

        uniforms.viewMatrix = scene.camera.viewMatrix
        uniforms.projectionMatrix = scene.camera.projectionMatrix
        params.lightCount = UInt32(scene.lighting.lights.count)
        params.cameraPosition = scene.camera.position
        let sun = scene.lighting.lights[0]
        shadowCamera = OrthographicCamera.createShadowCamera(
            using: scene.camera,
            lightPosition: sun.position)
        uniforms.shadowProjectionMatrix = shadowCamera.projectionMatrix
        uniforms.shadowViewMatrix = float4x4(
            eye: shadowCamera.position,
            center: shadowCamera.center,
            up: [0, 1, 0])
    }

    func draw(scene: GameScene, in view: MTKView) {
        view.sampleCount = options.antialiasing ? 4 : 1

        guard
            let commandBuffer = Renderer.commandQueue.makeCommandBuffer(),
            let descriptor = view.currentRenderPassDescriptor else {
            return
        }

        updateUniforms(scene: scene)

        shadowRenderPass.draw(
            commandBuffer: commandBuffer,
            scene: scene,
            uniforms: uniforms,
            params: params)

        forwardRenderPass.descriptor = descriptor
        forwardRenderPass.shadowTexture = shadowRenderPass.shadowTexture
        forwardRenderPass.draw(
            commandBuffer: commandBuffer,
            scene: scene,
            uniforms: uniforms,
            params: params)
        guard let drawable = view.currentDrawable else {
            return
        }
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}
