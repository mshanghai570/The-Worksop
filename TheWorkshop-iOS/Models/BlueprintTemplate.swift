//
//  Models/BlueprintTemplate.swift
//  TheWorkshop-iOS
//  Reusable Workflow Blueprint Model
//

import Foundation

public struct BlueprintTemplate: Identifiable, Codable {
    public let id: String
    public let title: String
    public let summary: String
    public let category: String
    public let iconName: String
    public let targetType: ProjectTargetType
    public let blocks: [Block]
    public let connections: [Connection]

    public init(
        id: String,
        title: String,
        summary: String,
        category: String,
        iconName: String,
        targetType: ProjectTargetType,
        blocks: [Block],
        connections: [Connection] = []
    ) {
        self.id = id
        self.title = title
        self.summary = summary
        self.category = category
        self.iconName = iconName
        self.targetType = targetType
        self.blocks = blocks
        self.connections = connections
    }
}
