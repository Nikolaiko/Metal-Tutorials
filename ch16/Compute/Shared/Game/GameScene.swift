import MetalKit

struct GameScene {
    lazy var warrior: Model = {
        Model(name: "Warrior.obj")
    }()

    var models: [Model] = []
    var camera = ArcballCamera()

    var defaultView: Transform {
        Transform(
            position: [1.4, 1.9, 2.6],
            rotation: [-0.14, 9.9, 0.0])
    }

    var lighting = SceneLighting()

    init() {
        camera.transform = defaultView
        camera.target = [0, 1.5, 0]
        camera.distance = 2.7
        models = [warrior]
        //convertMesh(warrior)
        warrior.convertMesh()
    }

    mutating func update(size: CGSize) {
        camera.update(size: size)
    }

    mutating func update(deltaTime: Float) {
        let input = InputController.shared
        if input.keysPressed.contains(.one) {
            camera.transform = Transform()
        }
        if input.keysPressed.contains(.two) {
            camera.transform = defaultView
        }
        input.keysPressed.removeAll()
        camera.update(deltaTime: deltaTime)
    }

    mutating func convertMesh(_ model: Model) {
        let startTime = CFAbsoluteTimeGetCurrent()
        for mesh in model.meshes {
            let vertexBuffer = mesh.vertexBuffers[VertexBuffer.index]
            let count = vertexBuffer.length / MemoryLayout<VertexLayout>.stride
            var pointer = vertexBuffer.contents().bindMemory(to: VertexLayout.self, capacity: count)

            for _ in 0..<count {
                pointer.pointee.position.z = -pointer.pointee.position.z
                pointer = pointer.advanced(by: 1)
            }
        }
        print("CPU Time:", CFAbsoluteTimeGetCurrent() - startTime)
    }
}
