//
//  Views/ContentView.swift
//  TheWorkshop-iOS
//  Main Studio Dashboard Window Layout
//

import SwiftUI

public struct ContentView: View {
    @StateObject private var projectVM = ProjectViewModel()
    @State private var showPalette: Bool = true
    @State private var showInspector: Bool = true

    public var body: some View {
        VStack(spacing: 0) {
            // Top Navigation Bar
            HStack(spacing: 12) {
                // Branding
                HStack(spacing: 6) {
                    Circle()
                        .fill(WorkshopTheme.hotPink)
                        .frame(width: 10, height: 10)

                    Text("THE WORKSHOP")
                        .font(.system(size: 13, weight: .black, design: .monospaced))
                        .foregroundColor(WorkshopTheme.neonGreen)

                    WorkshopBadge(text: "iOS NATIVE", color: WorkshopTheme.neonGreen)
                }

                Spacer()

                // Workflow Target Picker
                Picker("Target Workflow", selection: Binding(
                    get: { projectVM.project.projectType },
                    set: { projectVM.updateTargetType($0) }
                )) {
                    ForEach(ProjectTargetType.allCases) { type in
                        Text(type.displayName).tag(type)
                    }
                }
                .pickerStyle(.menu)
                .tint(WorkshopTheme.neonGreen)
                .padding(.horizontal, 6)
                .background(WorkshopTheme.darkCard)
                .cornerRadius(6)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(WorkshopTheme.cardBorder, lineWidth: 1)
                )

                // Studio Navigation Tabs
                HStack(spacing: 4) {
                    TabButton(title: "Canvas", systemImage: "square.grid.2x2", isSelected: projectVM.activeTab == .canvas) {
                        projectVM.activeTab = .canvas
                    }
                    TabButton(title: "Split Code", systemImage: "curlybraces", isSelected: projectVM.activeTab == .code) {
                        projectVM.activeTab = .code
                    }
                    TabButton(title: "Explorer", systemImage: "folder.fill", isSelected: projectVM.activeTab == .explorer) {
                        projectVM.activeTab = .explorer
                    }
                    TabButton(title: "Inspector", systemImage: "slider.horizontal.3", isSelected: projectVM.activeTab == .inspector) {
                        projectVM.activeTab = .inspector
                    }
                    TabButton(title: "AI Mentor", systemImage: "sparkles", isSelected: projectVM.activeTab == .assistant) {
                        projectVM.activeTab = .assistant
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(WorkshopTheme.darkCard)

            Divider().background(WorkshopTheme.cardBorder)

            // Main Studio View Switcher
            ZStack {
                switch projectVM.activeTab {
                case .canvas:
                    HStack(spacing: 0) {
                        if showPalette {
                            BlockPaletteView(projectVM: projectVM)
                                .frame(width: 240)
                            Divider().background(WorkshopTheme.cardBorder)
                        }

                        CanvasView(projectVM: projectVM)

                        if showInspector {
                            Divider().background(WorkshopTheme.cardBorder)
                            InspectorView(projectVM: projectVM)
                                .frame(width: 270)
                        }
                    }

                case .code:
                    CodeGeneratorView(projectVM: projectVM)

                case .explorer:
                    PackageExplorerView(projectVM: projectVM)

                case .inspector:
                    InspectorView(projectVM: projectVM)

                case .assistant:
                    GeminiAssistantView(projectVM: projectVM)
                }

                // Status Toast Overlay
                if let toast = projectVM.statusToastMessage {
                    VStack {
                        Spacer()
                        WorkshopToast(message: toast)
                            .padding(.bottom, 20)
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

struct TabButton: View {
    let title: String
    let systemImage: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: systemImage)
                Text(title)
            }
            .font(.system(size: 11, weight: .bold, design: .monospaced))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(isSelected ? WorkshopTheme.neonGreen.opacity(0.2) : WorkshopTheme.darkCard)
            .foregroundColor(isSelected ? WorkshopTheme.neonGreen : WorkshopTheme.subtleText)
            .cornerRadius(6)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(isSelected ? WorkshopTheme.neonGreen : WorkshopTheme.cardBorder, lineWidth: 1)
            )
        }
    }
}
