//
//  Services/BlockRegistryService.swift
//  TheWorkshop-iOS
//  Data-Driven Block Registry & Definitions with Learn Mode
//

import SwiftUI

public struct BlockDefinition {
    public let type: BlockType
    public let name: String
    public let description: String
    public let badgeColor: Color
    public let iconName: String
    public let supportedTargetTypes: [ProjectTargetType]
    public let education: BlockEducation

    public init(
        type: BlockType,
        name: String,
        description: String,
        badgeColor: Color,
        iconName: String,
        supportedTargetTypes: [ProjectTargetType] = [.jailbreakTweak, .jailedMod, .nativeExtension],
        education: BlockEducation
    ) {
        self.type = type
        self.name = name
        self.description = description
        self.badgeColor = badgeColor
        self.iconName = iconName
        self.supportedTargetTypes = supportedTargetTypes
        self.education = education
    }
}

public class BlockRegistryService {
    public static let shared = BlockRegistryService()

    public private(set) var definitions: [BlockType: BlockDefinition] = [:]

    private init() {
        registerDefaultDefinitions()
    }

    private func registerDefaultDefinitions() {
        let defs: [BlockDefinition] = [
            BlockDefinition(
                type: .hook,
                name: "Hook Method",
                description: "%hook target Objective-C class and method",
                badgeColor: WorkshopTheme.neonGreen,
                iconName: "link",
                supportedTargetTypes: [.jailbreakTweak],
                education: BlockEducation(
                    purpose: "Instructs Cydia Substrate / Substitute / ElleKit to intercept invocations of the designated Objective-C selector at runtime.",
                    codeExplanation: "Translates to %hook TargetClass ... %end in Logos syntax, swizzling implementation pointers at runtime.",
                    commonMistakes: [
                        "Typo in class name or selector signature (e.g. omitting trailing colon in method names with arguments).",
                        "Forgetting to call %orig in methods that perform critical layout or initialization."
                    ],
                    documentationUrl: "https://theos.dev/docs/logos-directives#hook"
                )
            ),
            BlockDefinition(
                type: .orig,
                name: "Call %orig",
                description: "Execute original hooked method implementation",
                badgeColor: WorkshopTheme.cyberCyan,
                iconName: "arrow.triangle.2.circlepath",
                supportedTargetTypes: [.jailbreakTweak],
                education: BlockEducation(
                    purpose: "Passes control back to the original method implementation with existing or overridden arguments.",
                    codeExplanation: "%orig; invokes original method implementation. Assigning id res = %orig; captures the return value.",
                    commonMistakes: [
                        "Omitting %orig when hooking void UI methods, causing views not to render.",
                        "Passing incompatible argument counts when using %orig(arg1, arg2)."
                    ],
                    documentationUrl: "https://theos.dev/docs/logos-directives#orig"
                )
            ),
            BlockDefinition(
                type: .log,
                name: "Log Message",
                description: "Print message to system console via NSLog",
                badgeColor: WorkshopTheme.cyberCyan,
                iconName: "terminal.fill",
                supportedTargetTypes: [.jailbreakTweak],
                education: BlockEducation(
                    purpose: "Emits a diagnostic log entry into syslog or Console.app for debugging.",
                    codeExplanation: "Compiles to NSLog(@\"[TheWorkshop] ...\"); or os_log for high performance unified logging.",
                    commonMistakes: [
                        "Leaving excessive logging inside high-frequency scroll or render methods, causing UI stutter."
                    ]
                )
            ),
            BlockDefinition(
                type: .modifyProperty,
                name: "Modify Property",
                description: "Set property on target object or self",
                badgeColor: WorkshopTheme.hotPink,
                iconName: "slider.horizontal.3",
                supportedTargetTypes: [.jailbreakTweak],
                education: BlockEducation(
                    purpose: "Sets properties or calls setter methods on 'self' or target instances.",
                    codeExplanation: "Generates explicit Objective-C message sends like [self setHidden:YES];.",
                    commonMistakes: [
                        "Calling setters on deallocated self pointers without nullability checks."
                    ]
                )
            ),
            BlockDefinition(
                type: .conditional,
                name: "If Condition",
                description: "Branch execution based on boolean condition",
                badgeColor: WorkshopTheme.warningYellow,
                iconName: "arrow.triangle.branch",
                supportedTargetTypes: [.jailbreakTweak],
                education: BlockEducation(
                    purpose: "Guards execution of child blocks using an Objective-C or C boolean expression.",
                    codeExplanation: "Generates if (condition) { ... } logic blocks.",
                    commonMistakes: [
                        "Invalid boolean syntax or uninitialized state variables inside the condition."
                    ]
                )
            ),
            BlockDefinition(
                type: .delay,
                name: "Delay Thread",
                description: "Pause current thread execution for duration",
                badgeColor: WorkshopTheme.warningYellow,
                iconName: "timer",
                supportedTargetTypes: [.jailbreakTweak],
                education: BlockEducation(
                    purpose: "Pauses thread execution for specified seconds before executing subsequent blocks.",
                    codeExplanation: "Generates dispatch_after or [NSThread sleepForTimeInterval:] code.",
                    commonMistakes: [
                        "Blocking the main UI thread with long sleep calls instead of async dispatch queues."
                    ]
                )
            ),
            BlockDefinition(
                type: .notification,
                name: "Show Banner",
                description: "Display HUD notification banner to user",
                badgeColor: WorkshopTheme.neonGreen,
                iconName: "bell.badge.fill",
                supportedTargetTypes: [.jailbreakTweak],
                education: BlockEducation(
                    purpose: "Displays visual HUD banners in SpringBoard or target app processes.",
                    codeExplanation: "Invokes system notification controllers or custom HUD overlay classes.",
                    commonMistakes: [
                        "Attempting to display UI overlays on background threads without dispatch_async(dispatch_get_main_queue())."
                    ]
                )
            ),
            BlockDefinition(
                type: .returnValue,
                name: "Return Value",
                description: "Override function return value",
                badgeColor: WorkshopTheme.hotPink,
                iconName: "arrow.turn.down.left",
                supportedTargetTypes: [.jailbreakTweak],
                education: BlockEducation(
                    purpose: "Overrides and immediately returns a specific value from the hooked method.",
                    codeExplanation: "Generates return <value>; statement in Logos output.",
                    commonMistakes: [
                        "Returning an incompatible type (e.g. returning integer from an object returning selector)."
                    ]
                )
            ),
            BlockDefinition(
                type: .customLogos,
                name: "Custom Logos",
                description: "Inject raw Logos or Objective-C code snippet",
                badgeColor: WorkshopTheme.subtleText,
                iconName: "chevron.left.forwardslash.chevron.right",
                supportedTargetTypes: [.jailbreakTweak],
                education: BlockEducation(
                    purpose: "Provides an unconstrained raw code sandbox for complex Logos directives (%group, %ctor, etc.).",
                    codeExplanation: "Injected verbatim into generated Tweak.x source code.",
                    commonMistakes: [
                        "Syntax errors in raw Objective-C snippet preventing Makefile build."
                    ]
                )
            ),
            BlockDefinition(
                type: .replaceAsset,
                name: "Replace Asset",
                description: "Swap application asset file in IPA Payload",
                badgeColor: WorkshopTheme.hotPink,
                iconName: "photo.stack",
                supportedTargetTypes: [.jailedMod],
                education: BlockEducation(
                    purpose: "Replaces bundled resources inside app container during Jailed IPA patch pipeline.",
                    codeExplanation: "Generates shell copy operations: cp -f replacement.png Payload/App.app/Target.png.",
                    commonMistakes: [
                        "Incorrect relative asset path or file extension mismatched with original compiled asset."
                    ]
                )
            ),
            BlockDefinition(
                type: .editPlist,
                name: "Edit Info.plist",
                description: "Modify key-value pairs in app Info.plist",
                badgeColor: WorkshopTheme.cyberCyan,
                iconName: "doc.badge.gearshape",
                supportedTargetTypes: [.jailedMod],
                education: BlockEducation(
                    purpose: "Updates bundle configuration properties inside Info.plist without recompiling source code.",
                    codeExplanation: "Generates plutil -replace commands against Info.plist.",
                    commonMistakes: [
                        "Overwriting critical system keys leading to iOS application launch crashes."
                    ]
                )
            ),
            BlockDefinition(
                type: .swiftuiView,
                name: "SwiftUI View Node",
                description: "Create native SwiftUI UI extension view",
                badgeColor: WorkshopTheme.neonGreen,
                iconName: "paintpalette.fill",
                supportedTargetTypes: [.nativeExtension],
                education: BlockEducation(
                    purpose: "Declares modular native SwiftUI views that can be dynamically hosted in UIHostingController.",
                    codeExplanation: "Generates public struct CustomView: View declaration.",
                    commonMistakes: [
                        "Missing import SwiftUI or referencing undefined state bindings."
                    ]
                )
            )
        ]

        for def in defs {
            definitions[def.type] = def
        }
    }

    public func register(definition: BlockDefinition) {
        definitions[definition.type] = definition
    }
}
