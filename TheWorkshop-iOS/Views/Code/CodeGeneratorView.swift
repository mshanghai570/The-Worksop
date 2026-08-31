//
//  Views/Code/CodeGeneratorView.swift
//  TheWorkshop-iOS
//  Live Code Synchronization & Split Editor View
//

import SwiftUI

public struct CodeGeneratorView: View {
    @ObservedObject var projectVM: ProjectViewModel
    @State private var selectedFileTab: CodeFile = .primaryTargetFile
    @State private var editableCodeOverride: String? = nil

    enum CodeFile: String, CaseIterable, Identifiable {
        case primaryTargetFile = "Generated Logos / Source"
        case makefile = "Makefile"
        case control = "Control File"
        case projectConfig = "Project JSON"

        var id: String { rawValue }
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Header Bar
            HStack(spacing: 6) {
                ForEach(CodeFile.allCases) { file in
                    Button {
                        selectedFileTab = file
                        editableCodeOverride = nil
                    } label: {
                        Text(file.rawValue)
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(selectedFileTab == file ? WorkshopTheme.neonGreen.opacity(0.2) : WorkshopTheme.darkCard)
                            .foregroundColor(selectedFileTab == file ? WorkshopTheme.neonGreen : WorkshopTheme.subtleText)
                            .cornerRadius(6)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(selectedFileTab == file ? WorkshopTheme.neonGreen : WorkshopTheme.cardBorder, lineWidth: 1)
                            )
                    }
                }

                Spacer()

                WorkshopBadge(text: "LIVE SYNC", color: WorkshopTheme.neonGreen)
            }
            .padding(10)
            .background(WorkshopTheme.darkCard)

            Divider().background(WorkshopTheme.cardBorder)

            // Split View Layout: Left Canvas / Right Live Code
            HStack(spacing: 0) {
                // Left: Compact Visual Canvas Blueprint
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Image(systemName: "square.grid.2x2.fill")
                            .foregroundColor(WorkshopTheme.neonGreen)
                        Text("VISUAL BLUEPRINT")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundColor(WorkshopTheme.subtleText)
                        Spacer()
                    }
                    .padding(8)
                    .background(WorkshopTheme.darkCard)

                    Divider().background(WorkshopTheme.cardBorder)

                    ScrollView([.horizontal, .vertical]) {
                        ZStack(alignment: .topLeading) {
                            // Canvas background
                            CanvasGridView()
                                .frame(width: 800, height: 600)

                            // Render blocks in split mode
                            ForEach(projectVM.project.blocks) { block in
                                MiniBlockNodeView(block: block, isSelected: projectVM.selectedBlockId == block.id) {
                                    projectVM.selectedBlockId = block.id
                                }
                                .position(x: block.x + 80, y: block.y + 40)
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .background(WorkshopTheme.deepBackground)

                Divider().background(WorkshopTheme.cardBorder)

                // Right: Generated Logos Source Code with Live Highlight
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Image(systemName: "curlybraces")
                            .foregroundColor(WorkshopTheme.cyberCyan)
                        Text("LIVE SOURCE OUTPUT")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundColor(WorkshopTheme.subtleText)

                        Spacer()

                        if let sel = projectVM.selectedBlock {
                            Text("Linked: \(sel.type.rawValue)")
                                .font(.system(size: 10, design: .monospaced))
                                .foregroundColor(WorkshopTheme.neonGreen)
                        }
                    }
                    .padding(8)
                    .background(WorkshopTheme.darkCard)

                    Divider().background(WorkshopTheme.cardBorder)

                    TextEditor(text: Binding(
                        get: {
                            editableCodeOverride ?? generatedCodeForTab(selectedFileTab)
                        },
                        set: { editableCodeOverride = $0 }
                    ))
                    .font(.system(size: 12, weight: .regular, design: .monospaced))
                    .padding(8)
                    .background(WorkshopTheme.deepBackground)
                    .foregroundColor(WorkshopTheme.brightText)
                }
                .frame(maxWidth: .infinity)
            }

            Divider().background(WorkshopTheme.cardBorder)

            // Bottom Actions Footer
            HStack {
                Button(action: {
                    #if os(iOS)
                    UIPasteboard.general.string = editableCodeOverride ?? generatedCodeForTab(selectedFileTab)
                    projectVM.showToast("Copied generated source code!")
                    #endif
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "doc.on.doc.fill")
                        Text("Copy Code")
                    }
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(WorkshopTheme.neonGreen)
                    .foregroundColor(.black)
                    .cornerRadius(6)
                }

                Spacer()

                Text("Target: \(projectVM.project.projectType.displayName)")
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(WorkshopTheme.subtleText)
            }
            .padding(10)
            .background(WorkshopTheme.darkCard)
        }
    }

    private func generatedCodeForTab(_ file: CodeFile) -> String {
        switch file {
        case .primaryTargetFile:
            return projectVM.generateCodeForCurrentTarget()
        case .makefile:
            return "TARGET := iphone:clang:latest:15.0\nINSTALL_TARGET_PROCESSES := SpringBoard\n\ninclude $(THEOS)/makefiles/common.mk\n\nTWEAK_NAME = \(projectVM.project.name.replacingOccurrences(of: " ", with: ""))\n$(TWEAK_NAME)_FILES = Tweak.x\n$(TWEAK_NAME)_CFLAGS = -fobjc-arc\n\ninclude $(THEOS_MAKE_PATH)/tweak.mk"
        case .control:
            return "Package: com.workshop.\(projectVM.project.name.lowercased().replacingOccurrences(of: " ", with: ""))\nName: \(projectVM.project.name)\nDepends: mobilesubstrate (>= 0.9.5000)\nVersion: 1.0.0\nArchitecture: iphoneos-arm\nDescription: Generated with The Workshop Studio"
        case .projectConfig:
            return ProjectStorageService.shared.exportProjectAsJSON(projectVM.project)
        }
    }
}

struct MiniBlockNodeView: View {
    let block: Block
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 6) {
                Circle()
                    .fill(isSelected ? WorkshopTheme.neonGreen : WorkshopTheme.cyberCyan)
                    .frame(width: 8, height: 8)

                Text(block.targetClass ?? block.type.rawValue.capitalized)
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundColor(WorkshopTheme.brightText)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(isSelected ? WorkshopTheme.neonGreen.opacity(0.2) : WorkshopTheme.darkCard)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? WorkshopTheme.neonGreen : WorkshopTheme.cardBorder, lineWidth: isSelected ? 2 : 1)
            )
        }
    }
}

struct CanvasGridView: View {
    var body: some View {
        GeometryReader { _ in
            Path { path in
                let step: CGFloat = 20
                for x in stride(from: 0, to: 800, by: step) {
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x, y: 600))
                }
                for y in stride(from: 0, to: 600, by: step) {
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: 800, y: y))
                }
            }
            .stroke(WorkshopTheme.cardBorder.opacity(0.4), lineWidth: 0.5)
        }
    }
}
