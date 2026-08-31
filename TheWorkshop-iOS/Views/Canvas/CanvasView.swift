//
//  Views/Canvas/CanvasView.swift
//  TheWorkshop-iOS
//  Visual Node Graph Canvas with Toolbar & Diagnostic Overlays
//

import SwiftUI

public struct CanvasView: View {
    @ObservedObject var projectVM: ProjectViewModel
    @StateObject private var canvasVM = CanvasViewModel()

    public var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Dark Background Grid
                WorkshopTheme.deepBackground
                    .ignoresSafeArea()

                CanvasGridBackground()

                // Connection Lines Layer
                Path { path in
                    for conn in projectVM.project.connections {
                        if let fromBlock = projectVM.project.blocks.first(where: { $0.id == conn.fromBlockId }),
                           let toBlock = projectVM.project.blocks.first(where: { $0.id == conn.toBlockId }) {
                            let start = CGPoint(x: CGFloat(fromBlock.x) + 110, y: CGFloat(fromBlock.y) + 60)
                            let end = CGPoint(x: CGFloat(toBlock.x) + 110, y: CGFloat(toBlock.y))

                            path.move(to: start)
                            let control1 = CGPoint(x: start.x, y: (start.y + end.y) / 2)
                            let control2 = CGPoint(x: end.x, y: (start.y + end.y) / 2)
                            path.addCurve(to: end, control1: control1, control2: control2)
                        }
                    }

                    for block in projectVM.project.blocks {
                        for childId in block.childrenBlockIds {
                            if let child = projectVM.project.blocks.first(where: { $0.id == childId }) {
                                let start = CGPoint(x: CGFloat(block.x) + 110, y: CGFloat(block.y) + 60)
                                let end = CGPoint(x: CGFloat(child.x) + 110, y: CGFloat(child.y))

                                path.move(to: start)
                                let control1 = CGPoint(x: start.x, y: (start.y + end.y) / 2)
                                let control2 = CGPoint(x: end.x, y: (start.y + end.y) / 2)
                                path.addCurve(to: end, control1: control1, control2: control2)
                            }
                        }
                    }
                }
                .stroke(WorkshopTheme.neonGreen.opacity(0.8), style: StrokeStyle(lineWidth: 2, lineCap: .round, dash: [4, 4]))

                // Block Nodes Layer
                ForEach(projectVM.project.blocks) { block in
                    BlockNodeView(
                        block: block,
                        isSelected: projectVM.selectedBlockId == block.id,
                        onSelect: {
                            projectVM.selectedBlockId = block.id
                        },
                        onDragChange: { translation in
                            let newX = max(20, Double(block.x) + Double(translation.width))
                            let newY = max(20, Double(block.y) + Double(translation.height))
                            projectVM.updateBlockPosition(id: block.id, newX: newX, newY: newY)
                        }
                    )
                }
            }
            .scaleEffect(canvasVM.scale)
            .offset(canvasVM.offset)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        canvasVM.offset = CGSize(
                            width: canvasVM.offset.width + value.translation.width * 0.05,
                            height: canvasVM.offset.height + value.translation.height * 0.05
                        )
                    }
            )
            .overlay(
                // Top Action Toolbar (Blueprints, Experiment Validation, History Timeline)
                HStack(spacing: 8) {
                    Button(action: { projectVM.isShowingBlueprintLibrary = true }) {
                        HStack(spacing: 4) {
                            Image(systemName: "square.stack.3d.up.fill")
                            Text("Blueprints")
                        }
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(WorkshopTheme.darkCard)
                        .foregroundColor(WorkshopTheme.neonGreen)
                        .cornerRadius(6)
                        .overlay(RoundedRectangle(cornerRadius: 6).stroke(WorkshopTheme.neonGreen.opacity(0.4), lineWidth: 1))
                    }

                    Button(action: { projectVM.isShowingExperimentValidation = true }) {
                        HStack(spacing: 4) {
                            Image(systemName: projectVM.validationReport.isValid ? "checkmark.seal.fill" : "exclamationmark.triangle.fill")
                            Text("Validation")
                            if projectVM.validationReport.errorCount > 0 {
                                Text("(\(projectVM.validationReport.errorCount))")
                                    .foregroundColor(WorkshopTheme.errorRed)
                            }
                        }
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(WorkshopTheme.darkCard)
                        .foregroundColor(projectVM.validationReport.isValid ? WorkshopTheme.cyberCyan : WorkshopTheme.warningYellow)
                        .cornerRadius(6)
                        .overlay(RoundedRectangle(cornerRadius: 6).stroke(projectVM.validationReport.isValid ? WorkshopTheme.cyberCyan.opacity(0.4) : WorkshopTheme.warningYellow.opacity(0.4), lineWidth: 1))
                    }

                    Button(action: { projectVM.isShowingTimelineDrawer = true }) {
                        HStack(spacing: 4) {
                            Image(systemName: "clock.arrow.circlepath")
                            Text("Timeline")
                        }
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(WorkshopTheme.darkCard)
                        .foregroundColor(WorkshopTheme.brightText)
                        .cornerRadius(6)
                        .overlay(RoundedRectangle(cornerRadius: 6).stroke(WorkshopTheme.cardBorder, lineWidth: 1))
                    }

                    Spacer()

                    // Undo / Redo
                    Button(action: { projectVM.undo() }) {
                        Image(systemName: "arrow.uturn.backward")
                            .font(.system(size: 11, weight: .bold))
                            .padding(6)
                            .background(WorkshopTheme.darkCard)
                            .foregroundColor(projectVM.timelineService.canUndo ? WorkshopTheme.brightText : WorkshopTheme.subtleText)
                            .cornerRadius(6)
                    }
                    .disabled(!projectVM.timelineService.canUndo)

                    Button(action: { projectVM.redo() }) {
                        Image(systemName: "arrow.uturn.forward")
                            .font(.system(size: 11, weight: .bold))
                            .padding(6)
                            .background(WorkshopTheme.darkCard)
                            .foregroundColor(projectVM.timelineService.canRedo ? WorkshopTheme.brightText : WorkshopTheme.subtleText)
                            .cornerRadius(6)
                    }
                    .disabled(!projectVM.timelineService.canRedo)
                }
                .padding(10),
                alignment: .top
            )
            .overlay(
                // Bottom Zoom Controls
                HStack(spacing: 8) {
                    Button { canvasVM.zoomIn() } label: { Image(systemName: "plus.magnifyingglass") }
                    Button { canvasVM.zoomOut() } label: { Image(systemName: "minus.magnifyingglass") }
                    Button { canvasVM.resetView() } label: { Image(systemName: "arrow.counterclockwise") }
                }
                .font(.system(size: 11, weight: .bold))
                .padding(8)
                .background(WorkshopTheme.darkCard)
                .cornerRadius(8)
                .foregroundColor(WorkshopTheme.brightText)
                .padding(12),
                alignment: .bottomTrailing
            )
            .sheet(isPresented: $projectVM.isShowingBlueprintLibrary) {
                BlueprintLibraryView(viewModel: projectVM)
            }
            .sheet(isPresented: $projectVM.isShowingExperimentValidation) {
                ExperimentValidationView(viewModel: projectVM)
            }
            .sheet(isPresented: $projectVM.isShowingTimelineDrawer) {
                TimelineDrawerView(viewModel: projectVM)
            }
        }
    }
}

struct CanvasGridBackground: View {
    var body: some View {
        GeometryReader { geo in
            Path { path in
                let step: CGFloat = 30
                for x in stride(from: 0, to: geo.size.width, by: step) {
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x, y: geo.size.height))
                }
                for y in stride(from: 0, to: geo.size.height, by: step) {
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: geo.size.width, y: y))
                }
            }
            .stroke(WorkshopTheme.cardBorder.opacity(0.3), lineWidth: 1)
        }
    }
}
