//
//  Views/Inspector/TimelineDrawerView.swift
//  TheWorkshop-iOS
//  Project History & Timeline State Drawer
//

import SwiftUI

public struct TimelineDrawerView: View {
    @ObservedObject var viewModel: ProjectViewModel
    @Environment(\.dismiss) private var dismiss

    public init(viewModel: ProjectViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header with Undo / Redo controls
                HStack(spacing: 16) {
                    Button(action: { viewModel.undo() }) {
                        HStack(spacing: 6) {
                            Image(systemName: "arrow.uturn.backward.circle.fill")
                            Text("Undo")
                        }
                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(viewModel.timelineService.canUndo ? WorkshopTheme.cyberCyan.opacity(0.15) : WorkshopTheme.darkCard)
                        .foregroundColor(viewModel.timelineService.canUndo ? WorkshopTheme.cyberCyan : WorkshopTheme.subtleText)
                        .cornerRadius(8)
                    }
                    .disabled(!viewModel.timelineService.canUndo)

                    Button(action: { viewModel.redo() }) {
                        HStack(spacing: 6) {
                            Text("Redo")
                            Image(systemName: "arrow.uturn.forward.circle.fill")
                        }
                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(viewModel.timelineService.canRedo ? WorkshopTheme.cyberCyan.opacity(0.15) : WorkshopTheme.darkCard)
                        .foregroundColor(viewModel.timelineService.canRedo ? WorkshopTheme.cyberCyan : WorkshopTheme.subtleText)
                        .cornerRadius(8)
                    }
                    .disabled(!viewModel.timelineService.canRedo)

                    Spacer()

                    Text("\(viewModel.timelineService.history.count) Snapshots")
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(WorkshopTheme.subtleText)
                }
                .padding(16)
                .background(WorkshopTheme.darkCard)

                Divider().background(WorkshopTheme.cardBorder)

                // Timeline History List
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        ForEach(Array(viewModel.timelineService.history.enumerated().reversed()), id: \.offset) { index, snapshot in
                            let isCurrent = index == viewModel.timelineService.currentIndex
                            
                            HStack(alignment: .top, spacing: 14) {
                                // Timeline Node Circle
                                VStack(spacing: 0) {
                                    Circle()
                                        .fill(isCurrent ? WorkshopTheme.neonGreen : WorkshopTheme.subtleText)
                                        .frame(width: 12, height: 12)
                                        .padding(.top, 4)

                                    Rectangle()
                                        .fill(WorkshopTheme.cardBorder)
                                        .frame(width: 2, height: 36)
                                }

                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        Text(snapshot.actionDescription)
                                            .font(.system(size: 14, weight: isCurrent ? .bold : .medium, design: .monospaced))
                                            .foregroundColor(isCurrent ? WorkshopTheme.neonGreen : WorkshopTheme.brightText)

                                        Spacer()

                                        Text(formattedTime(snapshot.timestamp))
                                            .font(.system(size: 11, design: .monospaced))
                                            .foregroundColor(WorkshopTheme.subtleText)
                                    }

                                    Text("\(snapshot.project.blocks.count) Blocks • Target: \(snapshot.project.targetType.displayName)")
                                        .font(.system(size: 12))
                                        .foregroundColor(WorkshopTheme.subtleText)
                                }
                                .padding(.bottom, 12)
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                if let restored = viewModel.timelineService.jumpTo(index: index) {
                                    viewModel.project = restored
                                    viewModel.showToast("Restored snapshot state")
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                    }
                    .padding(.vertical, 16)
                }
            }
            .background(WorkshopTheme.deepBackground.ignoresSafeArea())
            .navigationTitle("Project History Timeline")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                        .foregroundColor(WorkshopTheme.subtleText)
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        return formatter.string(from: date)
    }
}
