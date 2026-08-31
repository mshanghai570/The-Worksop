//
//  ViewModels/CanvasViewModel.swift
//  TheWorkshop-iOS
//  Canvas Navigation & Connection Lines
//

import Foundation
import CoreGraphics
import SwiftUI

public class CanvasViewModel: ObservableObject {
    @Published public var scale: CGFloat = 1.0
    @Published public var offset: CGSize = .zero
    @Published public var isGridVisible: Bool = true
    @Published public var isConnectingMode: Bool = false
    @Published public var connectingStartBlockId: String? = nil

    public init() {}

    public func zoomIn() {
        scale = min(scale + 0.15, 2.5)
    }

    public func zoomOut() {
        scale = max(scale - 0.15, 0.4)
    }

    public func resetView() {
        scale = 1.0
        offset = .zero
    }
}
