//
//  ProjectManagement/PresetManager.swift
//  TheWorkshop-iOS
//  Starter Templates & Presets
//

import Foundation

public struct PresetTemplate: Identifiable {
    public let id: String
    public let title: String
    public let subtitle: String
    public let targetType: ProjectTargetType
    public let project: Project
}

public class PresetManager {
    public static let shared = PresetManager()

    public let presets: [PresetTemplate] = [
        PresetTemplate(
            id: "preset-lockscreen",
            title: "SpringBoard LockScreen Hook",
            subtitle: "Interception hook for lockUI events with notification banner",
            targetType: .jailbreakTweak,
            project: ProjectManager.defaultJailbreakPreset()
        ),
        PresetTemplate(
            id: "preset-jailed",
            title: "IPA Asset & Plist Modifier",
            subtitle: "Modify App Icon and CFBundleDisplayName in IPA payload",
            targetType: .jailedMod,
            project: ProjectManager.defaultJailedModPreset()
        ),
        PresetTemplate(
            id: "preset-swiftui",
            title: "Native SwiftUI Overlay Extension",
            subtitle: "Render custom SwiftUI HUD over application process",
            targetType: .nativeExtension,
            project: ProjectManager.defaultNativeExtensionPreset()
        )
    ]

    private init() {}
}
