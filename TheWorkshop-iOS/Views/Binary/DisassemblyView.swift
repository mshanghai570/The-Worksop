//
//  Views/Binary/DisassemblyView.swift
//  TheWorkshop-iOS
//  Disassembly Viewer
//

import SwiftUI

struct DisassemblyView: View {
    let instructions: [Instruction]
    @Binding var selectedInstruction: Instruction?
    let onPatchAtAddress: (UInt64) -> Void

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "list.bullet.rectangle.fill")
                            .foregroundColor(WorkshopTheme.cyberCyan)
                        Text("DISASSEMBLY")
                            .font(.system(size: 13, weight: .bold, design: .monospaced))
                            .foregroundColor(WorkshopTheme.subtleText)
                        Spacer()
                        Text("\(instructions.count) Instructions")
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundColor(WorkshopTheme.subtleText)
                    }
                    .padding(.horizontal, 12)

                    Divider().background(WorkshopTheme.cardBorder)

                    if instructions.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "list.bullet.rectangle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(WorkshopTheme.subtleText.opacity(0.4))
                            Text("No disassembly available")
                                .font(.system(size: 12))
                                .foregroundColor(WorkshopTheme.subtleText)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        LazyVStack(spacing: 4) {
                            ForEach(instructions) { instruction in
                                InstructionRow(
                                    instruction: instruction,
                                    isSelected: selectedInstruction?.id == instruction.id,
                                    onSelect: { selectedInstruction = instruction },
                                    onPatch: { onPatchAtAddress(instruction.address) }
                                )
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                    }
                }
            }
            .background(WorkshopTheme.deepBackground)
            .navigationTitle("Disassembly")
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
}

struct InstructionRow: View {
    let instruction: Instruction
    let isSelected: Bool
    let onSelect: () -> Void
    let onPatch: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 8) {
                Text("0x\(String(format: "%llX", instruction.address))")
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(WorkshopTheme.subtleText)
                    .frame(width: 80, alignment: .trailing)

                Text(instruction.hexBytes)
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(WorkshopTheme.hotPink)
                    .frame(width: 120, alignment: .leading)

                Text(instruction.fullDisassembly)
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(WorkshopTheme.brightText)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Button(action: onPatch) {
                    Image(systemName: "hexagon.fill")
                        .foregroundColor(WorkshopTheme.warningYellow)
                }
            }
            .padding(8)
            .background(isSelected ? WorkshopTheme.cyberCyan.opacity(0.15) : WorkshopTheme.darkCard)
            .cornerRadius(6)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(isSelected ? WorkshopTheme.cyberCyan : WorkshopTheme.cardBorder, lineWidth: 1)
            )
            .onTapGesture(perform: onSelect)

            if let comment = instruction.comment, !comment.isEmpty {
                Text(comment)
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(WorkshopTheme.subtleText)
                    .padding(.leading, 8)
            }
        }
    }
}
