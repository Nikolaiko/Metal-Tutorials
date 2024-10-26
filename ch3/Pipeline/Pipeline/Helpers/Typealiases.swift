//
//  Typealiases.swift
//  Pipeline
//
//  Created by Nikolai Baklanov on 26.10.2024.
//

import Foundation
import SwiftUI

#if os(macOS)
typealias ViewRepresentable = NSViewRepresentable
#elseif os(iOS)
typealias ViewRepresentable = UIViewRepresentable
#endif
