import Foundation
import MetalKit

struct Quad {
    var oldVertices: [Float] = [
        -1, 1, 0,
         1, -1, 0,
         -1, -1, 0,

         -1, 1, 0,
         1, 1, 0,
         1, -1, 0
    ]

    var vertices: [Float] = [
        -1, 1, 0,
         1, 1, 0,
         -1, -1, 0,
         1, -1, 0,
    ]

    var indices: [UInt16] = [
        0, 3, 2,
        0, 1, 3
    ]

    var colors: [simd_float3] = [
        [1, 0, 0], // red
        [0, 1, 0], // green
        [0, 0, 1], // blue
        [1, 1, 0] // yellow
    ]

    let buffer: MTLBuffer
    let indexBuffer: MTLBuffer
    let colorBuffer: MTLBuffer

    init(device: MTLDevice, scale: Float = 1) {
        vertices = vertices.map { value in
            value * scale
        }

        guard let buffer = device.makeBuffer(
            bytes: &vertices,
            length: MemoryLayout<Float>.stride * vertices.count,
            options: []) else {
            fatalError("Unable to create quad vertex buffer")
        }
        self.buffer = buffer

        guard let indicesBuffer = device.makeBuffer(
            bytes: &indices,
            length: MemoryLayout<UInt16>.stride * indices.count,
            options: []) else {
            fatalError("Unable to create quad indicies buffer")
        }
        self.indexBuffer = indicesBuffer

        guard let colorBuffer = device.makeBuffer(
            bytes: &colors,
            length: MemoryLayout<simd_float3>.stride * colors.count,
            options: []) else {
            fatalError("Unable to create quad color buffer")
        }
        self.colorBuffer = colorBuffer
    }
}
