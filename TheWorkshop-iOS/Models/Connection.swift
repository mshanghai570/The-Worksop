//
//  Models/Connection.swift
//  TheWorkshop-iOS
//  Explicit Node Graph Connection Wire
//

import Foundation

public enum PortType: String, Codable {
    case flowIn = "flow_in"
    case flowOut = "flow_out"
    case elseOut = "else_out"
    case childIn = "child_in"
}

public struct Connection: Identifiable, Codable, Equatable {
    public var id: String
    public var fromBlockId: String
    public var fromPort: PortType
    public var toBlockId: String
    public var toPort: PortType

    public init(
        id: String = "conn-\(UUID().uuidString.prefix(8))",
        fromBlockId: String,
        fromPort: PortType = .flowOut,
        toBlockId: String,
        toPort: PortType = .flowIn
    ) {
        self.id = id
        self.fromBlockId = fromBlockId
        self.fromPort = fromPort
        self.toBlockId = toBlockId
        self.toPort = toPort
    }
}
