//
//  ViewModels/InspectorViewModel.swift
//  TheWorkshop-iOS
//  Node Inspector Logic
//

import SwiftUI
import Combine

public class InspectorViewModel: ObservableObject {
    @Published public var searchFilter: String = ""

    public init() {}
}
