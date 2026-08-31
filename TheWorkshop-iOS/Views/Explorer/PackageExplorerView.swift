//
//  Views/Explorer/PackageExplorerView.swift
//  TheWorkshop-iOS
//  IDE Project Hierarchy & File Browser View
//

import SwiftUI

public struct PackageExplorerView: View {
    @ObservedObject var viewModel: ProjectViewModel

    @State private var activeFileId: String = "file-tweak-x"
    @State private var fileContents: [String: String] = [:]
    @State private var isEditingCode: Bool = false

    public init(viewModel: ProjectViewModel) {
        self.viewModel = viewModel
    }

    private var projectFiles: [PackageFileItem] {
        let currentCode = viewModel.generateCodeForCurrentTarget()

        return [
            PackageFileItem(
                id: "dir-logos",
                name: "Logos / Source",
                fileType: .folder,
                children: [
                    PackageFileItem(
                        id: "file-tweak-x",
                        name: viewModel.project.projectType == .jailbreakTweak ? "Tweak.x" : "ModInjector.m",
                        fileType: .logosSource,
                        content: currentCode
                    )
                ]
            ),
            PackageFileItem(
                id: "dir-headers",
                name: "Headers",
                fileType: .folder,
                children: [
                    PackageFileItem(
                        id: "file-bridge-h",
                        name: "WorkshopBridge.h",
                        fileType: .header,
                        content: "// WorkshopBridge.h\n// Objective-C Bridge Headers for Theos\n\n#import <UIKit/UIKit.h>\n#import <Foundation/Foundation.h>\n"
                    )
                ]
            ),
            PackageFileItem(
                id: "dir-resources",
                name: "Resources",
                fileType: .folder,
                children: [
                    PackageFileItem(
                        id: "file-info-plist",
                        name: "Info.plist",
                        fileType: .plist,
                        content: "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\">\n<plist version=\"1.0\">\n<dict>\n  <key>CFBundleDisplayName</key>\n  <string>\(viewModel.project.name)</string>\n</dict>\n</plist>"
                    )
                ]
            ),
            PackageFileItem(
                id: "file-makefile",
                name: "Makefile",
                fileType: .makefile,
                content: "TARGET := iphone:clang:latest:15.0\nINSTALL_TARGET_PROCESSES := SpringBoard\n\ninclude $(THEOS)/makefiles/common.mk\n\nTWEAK_NAME = \(viewModel.project.name.replacingOccurrences(of: " ", with: ""))\n$(TWEAK_NAME)_FILES = Tweak.x\n$(TWEAK_NAME)_CFLAGS = -fobjc-arc\n\ninclude $(THEOS_MAKE_PATH)/tweak.mk"
            ),
            PackageFileItem(
                id: "file-control",
                name: "control",
                fileType: .control,
                content: "Package: com.workshop.\(viewModel.project.name.lowercased().replacingOccurrences(of: " ", with: ""))\nName: \(viewModel.project.name)\nDepends: mobilesubstrate (>= 0.9.5000)\nVersion: 1.0.0\nArchitecture: iphoneos-arm\nDescription: Generated with The Workshop iOS Studio\nMaintainer: Developer\nAuthor: Developer\nSection: Tweaks"
            )
        ]
    }

    public var body: some View {
        HStack(spacing: 0) {
            // File Explorer Sidebar Tree
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Image(systemName: "folder.fill.badge.gearshape")
                        .foregroundColor(WorkshopTheme.neonGreen)
                    Text("PACKAGE EXPLORER")
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundColor(WorkshopTheme.subtleText)
                    Spacer()
                }
                .padding(12)
                .background(WorkshopTheme.darkCard)

                Divider().background(WorkshopTheme.cardBorder)

                ScrollView {
                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(projectFiles) { item in
                            PackageFileRow(item: item, selectedId: activeFileId) { selectedItem in
                                activeFileId = selectedItem.id
                                if fileContents[selectedItem.id] == nil {
                                    fileContents[selectedItem.id] = selectedItem.content ?? ""
                                }
                            }
                        }
                    }
                    .padding(8)
                }
            }
            .frame(width: 220)
            .background(WorkshopTheme.deepBackground)

            Divider().background(WorkshopTheme.cardBorder)

            // File Content Editor View
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Image(systemName: iconForFileId(activeFileId))
                        .foregroundColor(WorkshopTheme.cyberCyan)
                    Text(fileNameForId(activeFileId))
                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                        .foregroundColor(WorkshopTheme.brightText)

                    Spacer()

                    WorkshopBadge(text: "Editable", color: WorkshopTheme.neonGreen)
                }
                .padding(12)
                .background(WorkshopTheme.darkCard)

                Divider().background(WorkshopTheme.cardBorder)

                TextEditor(text: Binding(
                    get: {
                        if fileContents[activeFileId] == nil {
                            return contentForFileId(activeFileId)
                        }
                        return fileContents[activeFileId] ?? ""
                    },
                    set: { fileContents[activeFileId] = $0 }
                ))
                .font(.system(size: 13, weight: .regular, design: .monospaced))
                .padding(8)
                .background(WorkshopTheme.deepBackground)
                .foregroundColor(WorkshopTheme.brightText)
            }
        }
    }

    private func iconForFileId(_ id: String) -> String {
        if id.contains("tweak") { return "doc.text.fill" }
        if id.contains("bridge") { return "h.square.fill" }
        if id.contains("plist") { return "doc.badge.gearshape.fill" }
        if id.contains("makefile") { return "hammer.fill" }
        if id.contains("control") { return "slider.horizontal.3" }
        return "doc.fill"
    }

    private func fileNameForId(_ id: String) -> String {
        if id.contains("tweak") { return viewModel.project.projectType == .jailbreakTweak ? "Tweak.x" : "ModInjector.m" }
        if id.contains("bridge") { return "WorkshopBridge.h" }
        if id.contains("plist") { return "Info.plist" }
        if id.contains("makefile") { return "Makefile" }
        if id.contains("control") { return "control" }
        return "Source.m"
    }

    private func contentForFileId(_ id: String) -> String {
        if id.contains("tweak") { return viewModel.generateCodeForCurrentTarget() }
        if id.contains("bridge") { return "// WorkshopBridge.h\n#import <UIKit/UIKit.h>\n" }
        if id.contains("plist") { return "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<plist version=\"1.0\">\n<dict>\n  <key>CFBundleDisplayName</key>\n  <string>\(viewModel.project.name)</string>\n</dict>\n</plist>" }
        if id.contains("makefile") { return "TARGET := iphone:clang:latest:15.0\ninclude $(THEOS)/makefiles/common.mk\nTWEAK_NAME = \(viewModel.project.name)\ninclude $(THEOS_MAKE_PATH)/tweak.mk" }
        if id.contains("control") { return "Package: com.workshop.\(viewModel.project.name.lowercased())\nName: \(viewModel.project.name)\nVersion: 1.0.0" }
        return "// Empty source file"
    }
}

struct PackageFileRow: View {
    let item: PackageFileItem
    let selectedId: String
    let onSelect: (PackageFileItem) -> Void

    @State private var isExpanded: Bool = true

    var body: some View {
        if item.fileType == .folder {
            VStack(alignment: .leading, spacing: 4) {
                Button(action: { isExpanded.toggle() }) {
                    HStack(spacing: 6) {
                        Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(WorkshopTheme.subtleText)
                        Image(systemName: "folder.fill")
                            .font(.system(size: 13))
                            .foregroundColor(WorkshopTheme.warningYellow)
                        Text(item.name)
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                            .foregroundColor(WorkshopTheme.brightText)
                    }
                }
                .padding(.vertical, 4)

                if isExpanded, let children = item.children {
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(children) { child in
                            PackageFileRow(item: child, selectedId: selectedId, onSelect: onSelect)
                        }
                    }
                    .padding(.leading, 16)
                }
            }
        } else {
            Button(action: { onSelect(item) }) {
                HStack(spacing: 6) {
                    Image(systemName: iconForType(item.fileType))
                        .font(.system(size: 12))
                        .foregroundColor(selectedId == item.id ? WorkshopTheme.neonGreen : WorkshopTheme.cyberCyan)
                    Text(item.name)
                        .font(.system(size: 12, weight: selectedId == item.id ? .bold : .regular, design: .monospaced))
                        .foregroundColor(selectedId == item.id ? WorkshopTheme.neonGreen : WorkshopTheme.brightText)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(selectedId == item.id ? WorkshopTheme.neonGreen.opacity(0.15) : Color.clear)
                .cornerRadius(6)
            }
        }
    }

    private func iconForType(_ type: PackageFileType) -> String {
        switch type {
        case .folder: return "folder.fill"
        case .logosSource: return "doc.text.fill"
        case .header: return "h.square.fill"
        case .resource: return "cube.fill"
        case .makefile: return "hammer.fill"
        case .control: return "slider.horizontal.3"
        case .plist: return "doc.badge.gearshape.fill"
        }
    }
}
