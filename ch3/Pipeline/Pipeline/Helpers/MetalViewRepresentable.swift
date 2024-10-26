//
//  MetalViewRepresentable.swift
//  Pipeline
//
//  Created by Nikolai Baklanov on 26.10.2024.
//

import SwiftUI
import MetalKit

struct MetalViewRepresentable: ViewRepresentable {
    @Binding var metalView: MTKView

    #if os(macOS)
    func makeNSView(context: Context) -> some NSView {
        metalView
    }
    func updateNSView(_ uiView: NSViewType, context: Context) {
        updateMetalView()
    }
    #elseif os(iOS)
    func makeUIView(context: Context) -> MTKView {
        metalView
    }

    func updateUIView(_ uiView: MTKView, context: Context) {
        updateMetalView()
    }
    #endif

    func updateMetalView() {
    }
}
