//
//  Views/Binary/InlineEditCreatorView.swift
//  TheWorkshop-iOS
//  Inline Edit Patch Creator
//

import SwiftUI

struct InlineEditCreatorView: View {
    @Binding var address: String
    @Binding var originalBytes: String
    @Binding var newBytes: String
    @Binding var label: String
    @Binding var mode: AIService.PatchMode
    
    let onCreate: () -> Void
    
    @State private var isReadingFromBinary: Bool = false

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("INLINE EDIT CONFIGURATION")) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Address")
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(WorkshopTheme.subtleText)
                        
                        HStack(spacing: 8) {
                            TextField("0x", text: $address)
                                .font(.system(size: 13, design: .monospaced))
                                .textFieldStyle(.plain)
                                .padding(10)
                                .background(WorkshopTheme.darkCard)
                                .cornerRadius(8)
                                .foregroundColor(WorkshopTheme.brightText)
                                .keyboardType(.hexadecimal)

                            Button(action: readBytesFromBinary) {
                                Image(systemName: "arrow.clockwise")
                                    .foregroundColor(WorkshopTheme.cyberCyan)
                            }
                        }
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Original Bytes (Hex)")
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(WorkshopTheme.subtleText)
                        TextField("Original hex bytes", text: $originalBytes)
                            .font(.system(size: 13, design: .monospaced))
                            .textFieldStyle(.plain)
                            .padding(10)
                            .background(WorkshopTheme.darkCard)
                            .cornerRadius(8)
                            .foregroundColor(WorkshopTheme.brightText)
                            .autocapitalization(.none)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("New Bytes (Hex)")
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(WorkshopTheme.subtleText)
                        TextField("New hex bytes", text: $newBytes)
                            .font(.system(size: 13, design: .monospaced))
                            .textFieldStyle(.plain)
                            .padding(10)
                            .background(WorkshopTheme.darkCard)
                            .cornerRadius(8)
                            .foregroundColor(WorkshopTheme.brightText)
                            .autocapitalization(.none)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Label (Optional)")
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(WorkshopTheme.subtleText)
                        TextField("Patch label", text: $label)
                            .font(.system(size: 13, design: .monospaced))
                            .textFieldStyle(.plain)
                            .padding(10)
                            .background(WorkshopTheme.darkCard)
                            .cornerRadius(8)
                            .foregroundColor(WorkshopTheme.brightText)
                    }

                    Picker("Mode", selection: $mode) {
                        ForEach(AIService.PatchMode.allCases, id: \.self) { mode in
                            Text(mode.rawValue.capitalized)
                                .tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                    .tint(WorkshopTheme.neonGreen)
                }

                Section {
                    Button(action: onCreate) {
                        HStack(spacing: 6) {
                            Image(systemName: "pencil.circle.fill")
                            Text("Create Inline Edit")
                        }
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(WorkshopTheme.hotPink)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                    .disabled(address.isEmpty || newBytes.isEmpty)
                }
            }
            .background(WorkshopTheme.deepBackground)
            .scrollContentBackground(.hidden)
            .navigationTitle("Create Inline Edit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        // Dismiss
                    }
                    .foregroundColor(WorkshopTheme.subtleText)
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private func readBytesFromBinary() {
        guard let binary = BinaryPatchingService.shared.loadedBinary else { return }
        let addressValue = UInt64(address.replacingOccurrences(of: "0x", with: ""), radix: 16) ?? 0
        
        if let hex = BinaryPatchingService.shared.getBytesAsHex(at: addressValue, count: 16) {
            originalBytes = hex
        }
    }
}
