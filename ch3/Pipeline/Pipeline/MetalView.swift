//
//  MetalView.swift
//  Pipeline
//
//  Created by Nikolai Baklanov on 26.10.2024.
//

import SwiftUI
import MetalKit

struct MetalView: View {
    @State private var metalView = MTKView()
    @State private var renderer: Renderer?

    var body: some View {
        MetalViewRepresentable(metalView: $metalView)
            .onAppear {
                renderer = Renderer(metalView: metalView)
            }
    }
}

struct MetalView_Previews: PreviewProvider {
  static var previews: some View {
    VStack {
      MetalView()
      Text("Metal View")
    }
  }
}
