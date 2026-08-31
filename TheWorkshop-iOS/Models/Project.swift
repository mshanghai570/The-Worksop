//
//  Models/Project.swift
//  TheWorkshop-iOS
//  Shared Serializable Project Schema
//

import Foundation

public struct Project: Identifiable, Codable, Equatable {
    public var id: String
    public var name: String
    public var version: String
    public var author: String
    public var bundleId: String
    public var projectType: ProjectTargetType
    public var targetProcess: String
    public var tweakFilter: String
    public var description: String
    public var createdAt: String
    public var updatedAt: String
    public var blocks: [Block]
    public var connections: [Connection]
    public var settings: ProjectSettings

    public init(
        id: String = "proj-\(UUID().uuidString.prefix(8))",
        name: String = "NeonLock Tweak",
        version: String = "1.0.0",
        author: String = "Developer",
        bundleId: String = "com.workshop.neonlock",
        projectType: ProjectTargetType = .jailbreakTweak,
        targetProcess: String = "SpringBoard",
        tweakFilter: String = "com.apple.springboard",
        description: String = "iOS Tweak & Modification Project created with The Workshop.",
        createdAt: String = ISO8601DateFormatter().string(from: Date()),
        updatedAt: String = ISO8601DateFormatter().string(from: Date()),
        blocks: [Block] = [],
        connections: [Connection] = [],
        settings: ProjectSettings = ProjectSettings()
    ) {
        self.id = id
        self.name = name
        self.version = version
        self.author = author
        self.bundleId = bundleId
        self.projectType = projectType
        self.targetProcess = targetProcess
        self.tweakFilter = tweakFilter
        self.description = description
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.blocks = blocks
        self.connections = connections
        self.settings = settings
    }
}
