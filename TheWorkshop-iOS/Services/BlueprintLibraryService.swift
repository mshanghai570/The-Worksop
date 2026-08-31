//
//  Services/BlueprintLibraryService.swift
//  TheWorkshop-iOS
//  Starter Blueprint Templates Engine
//

import Foundation

public class BlueprintLibraryService {
    public static let shared = BlueprintLibraryService()

    public private(set) var blueprints: [BlueprintTemplate] = []

    private init() {
        loadDefaultBlueprints()
    }

    private func loadDefaultBlueprints() {
        blueprints = [
            BlueprintTemplate(
                id: "bp-hook-method",
                title: "Hook Method",
                summary: "Standard Objective-C swizzling hook using Logos %hook directive",
                category: "Hooking",
                iconName: "link",
                targetType: .jailbreakTweak,
                blocks: [
                    Block(
                        id: "bp-1-hook",
                        type: .hook,
                        x: 80, y: 80,
                        targetClass: "UIViewController",
                        targetMethod: "viewWillAppear:",
                        returnType: "void",
                        childrenBlockIds: ["bp-1-orig", "bp-1-log"]
                    ),
                    Block(
                        id: "bp-1-orig",
                        type: .orig,
                        x: 80, y: 220
                    ),
                    Block(
                        id: "bp-1-log",
                        type: .log,
                        x: 80, y: 320,
                        message: "ViewController appeared!"
                    )
                ]
            ),
            BlueprintTemplate(
                id: "bp-modify-uilabel",
                title: "Modify UILabel",
                summary: "Intercept UILabel setText: to customize text color and string dynamically",
                category: "UI Swizzling",
                iconName: "textformat",
                targetType: .jailbreakTweak,
                blocks: [
                    Block(
                        id: "bp-2-hook",
                        type: .hook,
                        x: 80, y: 80,
                        targetClass: "UILabel",
                        targetMethod: "setText:",
                        returnType: "void",
                        childrenBlockIds: ["bp-2-prop", "bp-2-orig"]
                    ),
                    Block(
                        id: "bp-2-prop",
                        type: .modifyProperty,
                        x: 80, y: 220,
                        targetObject: "self",
                        propertyName: "textColor",
                        value: "[UIColor greenColor]"
                    ),
                    Block(
                        id: "bp-2-orig",
                        type: .orig,
                        x: 80, y: 320
                    )
                ]
            ),
            BlueprintTemplate(
                id: "bp-change-app-icon",
                title: "Change App Icon",
                summary: "Replace app icon PNG file inside Jailed IPA payload bundle",
                category: "Jailed Mod",
                iconName: "photo.stack",
                targetType: .jailedMod,
                blocks: [
                    Block(
                        id: "bp-3-asset",
                        type: .replaceAsset,
                        x: 80, y: 80,
                        assetPath: "AppIcon60x60@2x.png",
                        replacementUrl: "./custom_neon_icon.png"
                    )
                ]
            ),
            BlueprintTemplate(
                id: "bp-add-haptic",
                title: "Add Haptic Feedback",
                summary: "Trigger UIImpactFeedbackGenerator on button taps",
                category: "User Experience",
                iconName: "hand.tap.fill",
                targetType: .jailbreakTweak,
                blocks: [
                    Block(
                        id: "bp-4-hook",
                        type: .hook,
                        x: 80, y: 80,
                        targetClass: "UIButton",
                        targetMethod: "touchesBegan:withEvent:",
                        returnType: "void",
                        childrenBlockIds: ["bp-4-custom", "bp-4-orig"]
                    ),
                    Block(
                        id: "bp-4-custom",
                        type: .customLogos,
                        x: 80, y: 220,
                        customCode: "UIImpactFeedbackGenerator *gen = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleMedium];\n[gen impactOccurred];"
                    ),
                    Block(
                        id: "bp-4-orig",
                        type: .orig,
                        x: 80, y: 360
                    )
                ]
            ),
            BlueprintTemplate(
                id: "bp-inject-framework",
                title: "Inject Framework",
                summary: "Load custom Dynamic Library or Framework at runtime via constructor",
                category: "Low Level",
                iconName: "cube.transparent",
                targetType: .jailbreakTweak,
                blocks: [
                    Block(
                        id: "bp-5-custom",
                        type: .customLogos,
                        x: 80, y: 80,
                        customCode: "%ctor {\n    NSLog(@\"[TheWorkshop] Dynamic Constructor Initialized!\");\n    dlopen(\"/Library/MobileSubstrate/DynamicLibraries/CustomPlugin.dylib\", RTLD_NOW);\n}"
                    )
                ]
            ),
            BlueprintTemplate(
                id: "bp-edit-plist",
                title: "Edit Info.plist",
                summary: "Modify CFBundleDisplayName and custom keys in Jailed app package",
                category: "Jailed Mod",
                iconName: "doc.badge.gearshape",
                targetType: .jailedMod,
                blocks: [
                    Block(
                        id: "bp-6-plist1",
                        type: .editPlist,
                        x: 80, y: 80,
                        plistKey: "CFBundleDisplayName",
                        plistValue: "Modified YouTube Pro"
                    ),
                    Block(
                        id: "bp-6-plist2",
                        type: .editPlist,
                        x: 80, y: 220,
                        plistKey: "UIRequiresFullScreen",
                        plistValue: "YES"
                    )
                ]
            ),
            BlueprintTemplate(
                id: "bp-hook-springboard",
                title: "Hook SpringBoard",
                summary: "Intercept SpringBoard LockScreen activation events",
                category: "System Hook",
                iconName: "lock.shield",
                targetType: .jailbreakTweak,
                blocks: [
                    Block(
                        id: "bp-7-hook",
                        type: .hook,
                        x: 80, y: 80,
                        targetClass: "SBLockScreenManager",
                        targetMethod: "lockUIFromSource:withOptions:",
                        returnType: "void",
                        childrenBlockIds: ["bp-7-log", "bp-7-orig"]
                    ),
                    Block(
                        id: "bp-7-log",
                        type: .log,
                        x: 80, y: 220,
                        message: "SBLockScreenManager triggered lock event!"
                    ),
                    Block(
                        id: "bp-7-orig",
                        type: .orig,
                        x: 80, y: 320
                    )
                ]
            ),
            BlueprintTemplate(
                id: "bp-add-notification",
                title: "Add Notification",
                summary: "Display HUD banner on specific event trigger",
                category: "User Experience",
                iconName: "bell.badge.fill",
                targetType: .jailbreakTweak,
                blocks: [
                    Block(
                        id: "bp-8-hook",
                        type: .hook,
                        x: 80, y: 80,
                        targetClass: "SBApplication",
                        targetMethod: "didFinishLaunching",
                        returnType: "void",
                        childrenBlockIds: ["bp-8-notif", "bp-8-orig"]
                    ),
                    Block(
                        id: "bp-8-notif",
                        type: .notification,
                        x: 80, y: 220,
                        titleText: "The Workshop Mod",
                        bodyText: "App finished launching successfully!"
                    ),
                    Block(
                        id: "bp-8-orig",
                        type: .orig,
                        x: 80, y: 340
                    )
                ]
            ),
            BlueprintTemplate(
                id: "bp-override-return",
                title: "Override Return Value",
                summary: "Bypass check by overriding boolean method return value to YES",
                category: "Hooking",
                iconName: "arrow.turn.down.left",
                targetType: .jailbreakTweak,
                blocks: [
                    Block(
                        id: "bp-9-hook",
                        type: .hook,
                        x: 80, y: 80,
                        targetClass: "LicenseManager",
                        targetMethod: "isPremiumSubscriber",
                        returnType: "BOOL",
                        childrenBlockIds: ["bp-9-ret"]
                    ),
                    Block(
                        id: "bp-9-ret",
                        type: .returnValue,
                        x: 80, y: 220,
                        returnValue: "YES"
                    )
                ]
            )
        ]
    }
}
