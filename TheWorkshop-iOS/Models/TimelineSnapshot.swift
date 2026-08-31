//
//  Models/TimelineSnapshot.swift
//  TheWorkshop-iOS
//  Undo/Redo History Snapshot
//

import Foundation

public struct TimelineSnapshot: Identifiable, Codable {
    public let id: String
    public let actionDescription: String
    public let timestamp: Date
    public let project: Project

    public init(
        id: String = "snap-\(UUID().uuidString.prefix(8))",
        actionDescription: String,
        timestamp: Date = Date(),
        project: Project
    ) {
        self.id = id
        self.actionDescription = actionDescription
        self.timestamp = timestamp
        self.project = project
    }
}
