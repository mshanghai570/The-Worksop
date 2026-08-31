//
//  Views/Inspector/ExperimentValidationView.swift
//  TheWorkshop-iOS
//  Pre-Generation Diagnostic & Experiment Validation Sheet
//

import SwiftUI

public struct ExperimentValidationView: View {
    @ObservedObject var viewModel: ProjectViewModel
    @Environment(\.dismiss) private var dismiss

    public init(viewModel: ProjectViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header Summary Card
                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Experiment Diagnostic Status")
                            .font(.system(size: 13, weight: .bold, design: .monospaced))
                            .foregroundColor(WorkshopTheme.subtleText)

                        Text(viewModel.validationReport.isValid ? "PASSED & READY" : "ERRORS DETECTED")
                            .font(.system(size: 20, weight: .bold, design: .monospaced))
                            .foregroundColor(viewModel.validationReport.isValid ? WorkshopTheme.neonGreen : WorkshopTheme.errorRed)
                    }

                    Spacer()

                    HStack(spacing: 12) {
                        VStack {
                            Text("\(viewModel.validationReport.errorCount)")
                                .font(.system(size: 16, weight: .bold, design: .monospaced))
                                .foregroundColor(WorkshopTheme.errorRed)
                            Text("Errors")
                                .font(.system(size: 10, design: .monospaced))
                                .foregroundColor(WorkshopTheme.subtleText)
                        }

                        VStack {
                            Text("\(viewModel.validationReport.warningCount)")
                                .font(.system(size: 16, weight: .bold, design: .monospaced))
                                .foregroundColor(WorkshopTheme.warningYellow)
                            Text("Warnings")
                                .font(.system(size: 10, design: .monospaced))
                                .foregroundColor(WorkshopTheme.subtleText)
                        }
                    }
                }
                .padding(16)
                .background(WorkshopTheme.darkCard)
                .overlay(
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(WorkshopTheme.cardBorder),
                    alignment: .bottom
                )

                // List of Diagnostic Findings
                List {
                    ForEach(viewModel.validationReport.items) { item in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 8) {
                                Image(systemName: iconForSeverity(item.severity))
                                    .foregroundColor(colorForSeverity(item.severity))

                                Text(item.title)
                                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                                    .foregroundColor(WorkshopTheme.brightText)

                                Spacer()

                                WorkshopBadge(text: item.severity.rawValue, color: colorForSeverity(item.severity))
                            }

                            Text(item.detail)
                                .font(.system(size: 13))
                                .foregroundColor(WorkshopTheme.subtleText)

                            if let fix = item.quickFixTitle, let blockId = item.relatedBlockId {
                                Button(action: {
                                    applyQuickFix(fix: fix, blockId: blockId)
                                }) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "wrench.and.screwdriver.fill")
                                        Text("Quick Fix: \(fix)")
                                    }
                                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(colorForSeverity(item.severity).opacity(0.15))
                                    .foregroundColor(colorForSeverity(item.severity))
                                    .cornerRadius(6)
                                }
                                .padding(.top, 4)
                            }
                        }
                        .padding(.vertical, 6)
                        .listRowBackground(WorkshopTheme.darkCard)
                    }
                }
                .listStyle(.plain)

                // Generate / Dismiss Footer
                VStack(spacing: 12) {
                    Button(action: {
                        dismiss()
                        viewModel.activeTab = .code
                    }) {
                        HStack {
                            Image(systemName: "play.fill")
                            Text("Proceed to Code Generation")
                        }
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(viewModel.validationReport.isValid ? WorkshopTheme.neonGreen : WorkshopTheme.darkCard)
                        .foregroundColor(viewModel.validationReport.isValid ? .black : WorkshopTheme.subtleText)
                        .cornerRadius(10)
                    }
                }
                .padding(16)
                .background(WorkshopTheme.deepBackground)
            }
            .background(WorkshopTheme.deepBackground.ignoresSafeArea())
            .navigationTitle("Experiment Validation")
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

    private func iconForSeverity(_ severity: ValidationSeverity) -> String {
        switch severity {
        case .error: return "exclamationmark.octagon.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .suggestion: return "lightbulb.fill"
        case .pass: return "checkmark.seal.fill"
        }
    }

    private func colorForSeverity(_ severity: ValidationSeverity) -> Color {
        switch severity {
        case .error: return WorkshopTheme.errorRed
        case .warning: return WorkshopTheme.warningYellow
        case .suggestion: return WorkshopTheme.cyberCyan
        case .pass: return WorkshopTheme.neonGreen
        }
    }

    private func applyQuickFix(fix: String, blockId: String) {
        guard let index = viewModel.project.blocks.firstIndex(where: { $0.id == blockId }) else { return }

        if fix.contains("UIViewController") {
            viewModel.project.blocks[index].targetClass = "UIViewController"
        } else if fix.contains("viewWillAppear:") {
            viewModel.project.blocks[index].targetMethod = "viewWillAppear:"
        } else if fix.contains("%orig") {
            let origBlock = Block(type: .orig, x: viewModel.project.blocks[index].x, y: viewModel.project.blocks[index].y + 120)
            viewModel.project.blocks.append(origBlock)
            viewModel.project.blocks[index].childrenBlockIds.append(origBlock.id)
        } else if fix.contains("Remove") {
            viewModel.deleteBlock(id: blockId)
        } else if fix.contains("CFBundleDisplayName") {
            viewModel.project.blocks[index].plistKey = "CFBundleDisplayName"
        }

        viewModel.recordAction("Applied Quick Fix: \(fix)")
        viewModel.showToast("Quick fix applied!")
    }
}
