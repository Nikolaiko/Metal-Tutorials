import Foundation

protocol Transformable {
    var transform: Transform { get set }
}

extension Transformable {
    var position: float3 {
        get { transform.position }
        set { transform.position = newValue }
    }

    var rotation: float3 {
        get { transform.rotation }
        set { transform.rotation = newValue }
    }

    var scale: Float {
        get { transform.scale }
        set { transform.scale = newValue }
    }
}
