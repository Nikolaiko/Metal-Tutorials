//
//  ContentView.swift
//  Pipeline
//
//  Created by Nikolai Baklanov on 26.10.2024.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            MetalView()
                .border(Color.black, width: 2)
            Text("Hello, Metal!")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
