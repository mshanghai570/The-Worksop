//
//  Views/Binary/PatchDetailView.swift
//  TheWorkshop-iOS
//  Patch Detail View
//

import SwiftUI

struct PatchDetailView: View {
    let patch: PatchOperation

    @State private var isApplied: Bool

    init(patch: PatchOperation) {
        self.patch = patch
        _isApplied = State(initialValue: patch.isApplied)
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: isApplied ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(isApplied ? WorkshopTheme.neonGreen : WorkshopTheme.subtleText)
                            Text(patch.functionName)
                                .font(.system(size: 18, weight: .bold, design: .monospaced))
                                .foregroundColor(WorkshopTheme.brightText)
                        }

                        HStack(spacing: 16) {
                            WorkshopBadge(text: patch.patchType.rawValue, color: getColorForPatchType(patch.patchType))
                            if let address = patch.address {
                                Text("0x\(String(format: "%llX", address))")
                                    .font(.system(size: 11, design: .monospaced))
                                    .foregroundColor(WorkshopTheme.subtleText)
                            }
                        }
                    }

                    Divider().background(WorkshopTheme.cardBorder)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("PATCH CODE")
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(WorkshopTheme.subtleText)
                        
                        Text(patch.patchedCode)
                            .font(.system(size: 12, design: .monospaced))
                            .padding(12)
                            .background(WorkshopTheme.darkCard)
                            .cornerRadius(8)
                            .foregroundColor(WorkshopTheme.brightText)
                            .textSelection(.enabled)
                    }

                    if let original = patch.originalCode {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("ORIGINAL")
                                .font(.system(size: 11, weight: .bold, design: .monospaced))
                                .foregroundColor(WorkshopTheme.subtleText)
                            
                            Text(original)
                                .font(.system(size: 11, design: .monospaced))
                                .padding(12)
                                .background(WorkshopTheme.darkCard)
                                .cornerRadius(8)
                                .foregroundColor(WorkshopTheme.subtleText)
                        }
                    }

                    Divider().background(WorkshopTheme.cardBorder)

                    HStack(spacing: 12) {
                        Button(action: toggleApplied) {
                            HStack(spacing: 6) {
                                Image(systemName: isApplied ? "checkmark" : "arrow.clockwise")
                                Text(isApplied ? "Applied" : "Apply Patch")
                            }
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(isApplied ? WorkshopTheme.neonGreen : WorkshopTheme.cyberCyan)
                            .foregroundColor(.black)
                            .cornerRadius(8)
                        }

                        Button(action: copyCode) {
                            HStack(spacing: 6) {
                                Image(systemName: "doc.on.doc")
                                Text("Copy Code")
                            }
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(WorkshopTheme.darkCard)
                            .foregroundColor(WorkshopTheme.brightText)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(WorkshopTheme.cardBorder, lineWidth: 1)
                            )
                        }
                    }
                }
                .padding(16)
            }
            .background(WorkshopTheme.deepBackground)
            .navigationTitle("Patch Detail")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        // Dismiss
                    }
                    .foregroundColor(WorkshopTheme.subtleText)
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private func toggleApplied() {
        isApplied.toggle()
        var updatedPatch = patch
        updatedPatch.isApplied = isApplied
        updatedPatch.appliedAt = isApplied ? Date() : nil
        
        if let index = BinaryPatchingService.shared.patches.firstIndex(where: { $0.id == patch.id }) {
            BinaryPatchingService.shared.patches[index] = updatedPatch
        }
    }

    private func copyCode() {
        #if os(iOS)
        UIPasteboard.general.string = patch.patchedCode
        #endif
    }

    private func getColorForPatchType(_ type: AIService.PatchType) -> Color {
        switch type {
        case .hook: return WorkshopTheme.neonGreen
        case .replace: return WorkshopTheme.hotPink
        case .bypass: return WorkshopTheme.warningYellow
        case .log: return WorkshopTheme.cyberCyan
        case .modifyReturn: return WorkshopTheme.hotPink
        case .inlineEdit: return WorkshopTheme.warningYellow
        case .bytePatch: return WorkshopTheme.hotPink
        case .nop: return WorkshopTheme.subtleText
        case .call: return WorkshopTheme.cyberCyan
        case .jump: return WorkshopTheme.neonGreen
        }
    }
}
