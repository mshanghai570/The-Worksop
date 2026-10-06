//
//  Views/Binary/FunctionDetailView.swift
//  TheWorkshop-iOS
//  Function Detail View
//

import SwiftUI

struct FunctionDetailView: View {
    let function: BinaryFunction
    let onPatch: (AIService.PatchType, String) -> Void
    let onDisassemble: () -> Void
    let onCancel: () -> Void

    @State private var selectedPatchType: AIService.PatchType = .hook
    @State private var customCode: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "function")
                    .foregroundColor(WorkshopTheme.neonGreen)
                Text("FUNCTION DETAIL")
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundColor(WorkshopTheme.subtleText)
                Spacer()
                Button(action: onCancel) {
                    Image(systemName: "xmark")
                        .foregroundColor(WorkshopTheme.subtleText)
                }
            }

            Divider().background(WorkshopTheme.cardBorder)

            VStack(alignment: .leading, spacing: 8) {
                Text(function.displayName)
                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                    .foregroundColor(WorkshopTheme.neonGreen)
                
                if let methodSignature = function.methodSignature {
                    Text(methodSignature)
                        .font(.system(size: 13, design: .monospaced))
                        .foregroundColor(WorkshopTheme.cyberCyan)
                }
                
                HStack(spacing: 16) {
                    VStack(alignment: .leading) {
                        Text("Address")
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(WorkshopTheme.subtleText)
                        Text("0x\(String(format: "%llX", function.address))")
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                            .foregroundColor(WorkshopTheme.brightText)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Size")
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(WorkshopTheme.subtleText)
                        Text("\(function.size) bytes")
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                            .foregroundColor(WorkshopTheme.brightText)
                    }
                    
                    if let returnType = function.returnType {
                        VStack(alignment: .leading) {
                            Text("Returns")
                                .font(.system(size: 10, design: .monospaced))
                                .foregroundColor(WorkshopTheme.subtleText)
                            Text(returnType)
                                .font(.system(size: 12, weight: .bold, design: .monospaced))
                                .foregroundColor(WorkshopTheme.brightText)
                        }
                    }
                }
            }

            Divider().background(WorkshopTheme.cardBorder)

            HStack(spacing: 8) {
                Button(action: onDisassemble) {
                    HStack(spacing: 4) {
                        Image(systemName: "list.bullet.rectangle.fill")
                        Text("Disassemble")
                    }
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(WorkshopTheme.cyberCyan)
                    .foregroundColor(.black)
                    .cornerRadius(6)
                }

                Button(action: {}) {
                    HStack(spacing: 4) {
                        Image(systemName: "pencil")
                        Text("Inline Edit")
                    }
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(WorkshopTheme.hotPink)
                    .foregroundColor(.white)
                    .cornerRadius(6)
                }

                Button(action: {}) {
                    HStack(spacing: 4) {
                        Image(systemName: "hexagon.fill")
                        Text("Byte Patch")
                    }
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(WorkshopTheme.warningYellow)
                    .foregroundColor(.black)
                    .cornerRadius(6)
                }
            }

            Divider().background(WorkshopTheme.cardBorder)

            VStack(alignment: .leading, spacing: 8) {
                Text("CREATE PATCH")
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundColor(WorkshopTheme.subtleText)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 4) {
                        ForEach(AIService.PatchType.allCases, id: \.self) { patchType in
                            Button(action: { selectedPatchType = patchType }) {
                                Text(patchType.rawValue)
                                    .font(.system(size: 10, design: .monospaced))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(selectedPatchType == patchType ? WorkshopTheme.neonGreen : WorkshopTheme.darkCard)
                                    .foregroundColor(selectedPatchType == patchType ? .black : WorkshopTheme.brightText)
                                    .cornerRadius(4)
                            }
                        }
                    }
                }

                TextEditor(text: $customCode)
                    .font(.system(size: 12, design: .monospaced))
                    .padding(10)
                    .background(WorkshopTheme.darkCard)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(WorkshopTheme.cardBorder, lineWidth: 1)
                    )
                    .foregroundColor(WorkshopTheme.brightText)
                    .frame(minHeight: 100)

                Button(action: { onPatch(selectedPatchType, customCode) }) {
                    HStack(spacing: 6) {
                        Image(systemName: "wrench.and.screwdriver.fill")
                        Text("Generate Patch")
                    }
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(WorkshopTheme.neonGreen)
                    .foregroundColor(.black)
                    .cornerRadius(8)
                }
            }
        }
        .padding(16)
        .background(WorkshopTheme.deepBackground)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(WorkshopTheme.cardBorder, lineWidth: 1)
        )
    }
}
