//
//  ProjectManagement/ProjectManager.swift
//  TheWorkshop-iOS
//  Project Lifecycle, State Management & Serialization
//

import Foundation

public class ProjectManager: ObservableObject {
    @Published public var currentProject: Project

    public init(initialProject: Project = ProjectManager.defaultJailbreakPreset()) {
        self.currentProject = initialProject
    }

    public func updateTargetType(_ newType: ProjectTargetType) {
        currentProject.projectType = newType

        switch newType {
        case .jailbreakTweak:
            currentProject = ProjectManager.defaultJailbreakPreset()
        case .jailedMod:
            currentProject = ProjectManager.defaultJailedModPreset()
        case .nativeExtension:
            currentProject = ProjectManager.defaultNativeExtensionPreset()
        }
    }

    public static func defaultJailbreakPreset() -> Project {
        let hookBlock = Block(
            id: "hook-sb-01",
            type: .hook,
            x: 60,
            y: 60,
            targetClass: "SBLockScreenManager",
            targetMethod: "lockUIFromSource:withOptions:",
            returnType: "void",
            childrenBlockIds: ["log-01"]
        )

        let logBlock = Block(
            id: "log-01",
            type: .log,
            x: 60,
            y: 200,
            message: "SpringBoard lock event captured!"
        )

        let conn = Connection(fromBlockId: hookBlock.id, toBlockId: logBlock.id)

        return Project(
            name: "NeonLock Tweak",
            version: "1.0.0",
            author: "The Workshop Studio",
            bundleId: "com.workshop.neonlock",
            projectType: .jailbreakTweak,
            targetProcess: "SpringBoard",
            tweakFilter: "com.apple.springboard",
            description: "SpringBoard LockScreen Hook Tweak built with The Workshop.",
            blocks: [hookBlock, logBlock],
            connections: [conn]
        )
    }

    public static func defaultJailedModPreset() -> Project {
        let replaceBlock = Block(
            id: "asset-01",
            type: .replaceAsset,
            x: 60,
            y: 60,
            assetPath: "AppIcon60x60@2x.png",
            replacementUrl: "./custom_icon.png"
        )

        let plistBlock = Block(
            id: "plist-01",
            type: .editPlist,
            x: 60,
            y: 200,
            plistKey: "CFBundleDisplayName",
            plistValue: "Modified YouTube"
        )

        let conn = Connection(fromBlockId: replaceBlock.id, toBlockId: plistBlock.id)

        return Project(
            name: "Jailed App Customizer",
            version: "1.0.0",
            author: "The Workshop Studio",
            bundleId: "com.google.ios.youtube",
            projectType: .jailedMod,
            targetProcess: "YouTube",
            tweakFilter: "com.google.ios.youtube",
            description: "Jailed IPA asset & plist mod script.",
            blocks: [replaceBlock, plistBlock],
            connections: [conn]
        )
    }

    public static func defaultNativeExtensionPreset() -> Project {
        let extensionViewBlock = Block(
            id: "swiftui-01",
            type: .swiftuiView,
            x: 60,
            y: 60,
            viewTitle: "NeonHUDView",
            swiftuiCode: """
            VStack {
                Text("NEON HUD EXTENSION")
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundStyle(Color(red: 0.22, green: 1.0, blue: 0.08))
                Spacer()
            }
            .padding()
            .background(Color.black)
            """
        )

        return Project(
            name: "Native HUD Extension",
            version: "1.0.0",
            author: "The Workshop Studio",
            bundleId: "com.workshop.nativehud",
            projectType: .nativeExtension,
            targetProcess: "NativeApp",
            tweakFilter: "com.apple.uikit",
            description: "Native SwiftUI extension view module.",
            blocks: [extensionViewBlock],
            connections: []
        )
    }
}
