//
//  Models/ProjectSettings.swift
//  TheWorkshop-iOS
//  Project Configuration & Build Settings
//

import Foundation

public struct ProjectSettings: Codable, Equatable {
    public var targetSDK: String
    public var minimumiOSVersion: String
    public var enableARC: Bool
    public var enableDebugLogging: Bool
    public var theosPath: String
    public var defaultIPAPath: String?

    public init(
        targetSDK: String = "iphone:clang:latest:15.0",
        minimumiOSVersion: String = "15.0",
        enableARC: Bool = true,
        enableDebugLogging: Bool = true,
        theosPath: String = "$THEOS",
        defaultIPAPath: String? = nil
    ) {
        self.targetSDK = targetSDK
        self.minimumiOSVersion = minimumiOSVersion
        self.enableARC = enableARC
        self.enableDebugLogging = enableDebugLogging
        self.theosPath = theosPath
        self.defaultIPAPath = defaultIPAPath
    }
}
