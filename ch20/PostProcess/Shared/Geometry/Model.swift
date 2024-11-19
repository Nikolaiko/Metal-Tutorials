// swiftlint:disable force_try
// swiftlint:disable vertical_whitespace_opening_braces

import MetalKit

class Model: Transformable {
    var transform = Transform()
    let meshes: [Mesh]
    var tiling: UInt32 = 1
    var name: String
    let hasTransparency: Bool

    init(name: String) {
        guard let assetURL = Bundle.main.url(
            forResource: name,
            withExtension: nil) else {
            fatalError("Model: \(name) not found")
        }
        let allocator = MTKMeshBufferAllocator(device: Renderer.device)
        let meshDescriptor = MDLVertexDescriptor.defaultLayout
        let asset = MDLAsset(
            url: assetURL,
            vertexDescriptor: meshDescriptor,
            bufferAllocator: allocator)
        asset.loadTextures()
        var mtkMeshes: [MTKMesh] = []
        let mdlMeshes =
        asset.childObjects(of: MDLMesh.self) as? [MDLMesh] ?? []
        _ = mdlMeshes.map { mdlMesh in
            mdlMesh.addTangentBasis(
                forTextureCoordinateAttributeNamed:
                    MDLVertexAttributeTextureCoordinate,
                tangentAttributeNamed: MDLVertexAttributeTangent,
                bitangentAttributeNamed: MDLVertexAttributeBitangent)
            mtkMeshes.append(
                try! MTKMesh(
                    mesh: mdlMesh,
                    device: Renderer.device))
        }
        meshes = zip(mdlMeshes, mtkMeshes).map {
            Mesh(mdlMesh: $0.0, mtkMesh: $0.1)
        }
        self.name = name

        hasTransparency = meshes.contains { mesh in
            mesh.submeshes.contains { $0.transparency }
        }
    }
}

// Rendering
extension Model {
    func render(
        encoder: MTLRenderCommandEncoder,
        uniforms vertex: Uniforms,
        params fragment: Params
    ) {
        encoder.pushDebugGroup(name)
        var uniforms = vertex
        uniforms.modelMatrix = transform.modelMatrix
        uniforms.normalMatrix = uniforms.modelMatrix.upperLeft
        var params = fragment
        params.tiling = tiling

        encoder.setVertexBytes(
            &uniforms,
            length: MemoryLayout<Uniforms>.stride,
            index: UniformsBuffer.index)

        encoder.setFragmentBytes(
            &params,
            length: MemoryLayout<Params>.stride,
            index: ParamsBuffer.index)

        for mesh in meshes {
            for (index, vertexBuffer) in mesh.vertexBuffers.enumerated() {
                encoder.setVertexBuffer(
                    vertexBuffer,
                    offset: 0,
                    index: index)
            }

            for submesh in mesh.submeshes {
                if submesh.transparency != params.transparency { continue }

                // set the fragment texture here
                encoder.setFragmentTexture(
                    submesh.textures.baseColor,
                    index: BaseColor.index)
                encoder.setFragmentTexture(
                    submesh.textures.normal,
                    index: NormalTexture.index)
                encoder.setFragmentTexture(
                    submesh.textures.roughness,
                    index: RoughnessTexture.index)
                encoder.setFragmentTexture(
                    submesh.textures.metallic,
                    index: MetallicTexture.index)
                encoder.setFragmentTexture(
                    submesh.textures.ambientOcclusion,
                    index: AOTexture.index)
                encoder.setFragmentTexture(
                    submesh.textures.opacity,
                    index: OpacityTexture.index)
                var material = submesh.material
                encoder.setFragmentBytes(
                    &material,
                    length: MemoryLayout<Material>.stride,
                    index: MaterialBuffer.index)
                encoder.drawIndexedPrimitives(
                    type: .triangle,
                    indexCount: submesh.indexCount,
                    indexType: submesh.indexType,
                    indexBuffer: submesh.indexBuffer,
                    indexBufferOffset: submesh.indexBufferOffset
                )
            }
        }
        encoder.popDebugGroup()
    }
}
