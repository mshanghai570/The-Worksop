//
//  Services/ValidationService.swift
//  TheWorkshop-iOS
//  Diagnostic Engine & Experiment Validation Service
//

import Foundation

public class ValidationService {
    public static let shared = ValidationService()

    private init() {}

    public func validate(project: Project) -> ValidationReport {
        var items: [ValidationItem] = []

        // 1. Target Compatibility Validation
        for block in project.blocks {
            if let def = BlockRegistryService.shared.definitions[block.type] {
                if !def.supportedTargetTypes.contains(project.targetType) {
                    items.append(
                        ValidationItem(
                            severity: .error,
                            title: "Incompatible Target Block",
                            detail: "Block '\(def.name)' is not supported in \(project.targetType.displayName) projects.",
                            relatedBlockId: block.id,
                            quickFixTitle: "Remove Block"
                        )
                    )
                }
            }
        }

        // 2. Hook Block Field Validation
        let hookBlocks = project.blocks.filter { $0.type == .hook }
        for hook in hookBlocks {
            let className = hook.targetClass?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let methodName = hook.targetMethod?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

            if className.isEmpty {
                items.append(
                    ValidationItem(
                        severity: .error,
                        title: "Missing Target Class",
                        detail: "Hook block ID \(hook.id.prefix(6)) has an empty Objective-C Class name.",
                        relatedBlockId: hook.id,
                        quickFixTitle: "Set Class to UIViewController"
                    )
                )
            }

            if methodName.isEmpty {
                items.append(
                    ValidationItem(
                        severity: .error,
                        title: "Missing Target Method",
                        detail: "Hook block ID \(hook.id.prefix(6)) has an empty Method selector.",
                        relatedBlockId: hook.id,
                        quickFixTitle: "Set Method to viewWillAppear:"
                    )
                )
            }

            // Check if Hook has %orig or return value child
            let childIds = hook.childrenBlockIds
            let childBlocks = project.blocks.filter { childIds.contains($0.id) }
            let hasOrig = childBlocks.contains { $0.type == .orig }
            let hasReturn = childBlocks.contains { $0.type == .returnValue }

            if !hasOrig && !hasReturn {
                items.append(
                    ValidationItem(
                        severity: .warning,
                        title: "Missing %orig Execution",
                        detail: "Hook on '\(className) \(methodName)' does not invoke %orig or return a value. This may override original app logic and cause crashes.",
                        relatedBlockId: hook.id,
                        quickFixTitle: "Attach %orig Block"
                    )
                )
            }
        }

        // 3. Dangling Connections / Unlinked Blocks
        let allChildIds = Set(project.blocks.flatMap { $0.childrenBlockIds })
        let rootBlocks = project.blocks.filter { $0.type == .hook || $0.type == .customLogos || $0.type == .replaceAsset || $0.type == .editPlist || $0.type == .swiftuiView }

        for block in project.blocks {
            if !rootBlocks.contains(where: { $0.id == block.id }) && !allChildIds.contains(block.id) {
                items.append(
                    ValidationItem(
                        severity: .warning,
                        title: "Unlinked / Orphaned Block",
                        detail: "Block '\(block.type.rawValue)' is floating without parent hook attachment.",
                        relatedBlockId: block.id,
                        quickFixTitle: "Connect to Root Hook"
                    )
                )
            }
        }

        // 4. Check for Empty Plist & Asset entries in Jailed
        if project.targetType == .jailedMod {
            let plistBlocks = project.blocks.filter { $0.type == .editPlist }
            for plist in plistBlocks {
                if (plist.plistKey ?? "").isEmpty {
                    items.append(
                        ValidationItem(
                            severity: .error,
                            title: "Missing Plist Key",
                            detail: "Edit Info.plist block has no specified property key.",
                            relatedBlockId: plist.id,
                            quickFixTitle: "Set Key to CFBundleDisplayName"
                        )
                    )
                }
            }
        }

        // 5. Positive Validation Pass Note if clear
        if items.isEmpty {
            items.append(
                ValidationItem(
                    severity: .pass,
                    title: "Blueprint Validation Passed",
                    detail: "All \(project.blocks.count) blocks and relationships are valid. Ready for Logos build execution."
                )
            )
        }

        return ValidationReport(items: items)
    }
}
