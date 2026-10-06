//
//  Views/Binary/BytePatchCreatorView.swift
//  TheWorkshop-iOS
//  Byte Patch Creator
//

import SwiftUI

struct BytePatchCreatorView: View {
    @Binding var address: String
    @Binding var operation: AIService.BytePatchOperation
    @Binding var operand: String
    @Binding var value: String
    @Binding var size: String
    @Binding var label: String
    
    let onCreate: () -> Void

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("BYTE PATCH CONFIGURATION")) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Address")
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(WorkshopTheme.subtleText)
                        TextField("0x", text: $address)
                            .font(.system(size: 13, design: .monospaced))
                            .textFieldStyle(.plain)
                            .padding(10)
                            .background(WorkshopTheme.darkCard)
                            .cornerRadius(8)
                            .foregroundColor(WorkshopTheme.brightText)
                            .keyboardType(.hexadecimal)
                    }

                    Picker("Operation", selection: $operation) {
                        ForEach(AIService.BytePatchOperation.allCases, id: \.self) { op in
                            Text(op.rawValue.capitalized)
                                .tag(op)
                        }
                    }
                    .pickerStyle(.segmented)
                    .tint(WorkshopTheme.neonGreen)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Operand (Hex)")
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(WorkshopTheme.subtleText)
                        TextField("Operand bytes", text: $operand)
                            .font(.system(size: 13, design: .monospaced))
                            .textFieldStyle(.plain)
                            .padding(10)
                            .background(WorkshopTheme.darkCard)
                            .cornerRadius(8)
                            .foregroundColor(WorkshopTheme.brightText)
                            .autocapitalization(.none)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Value (Hex)")
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(WorkshopTheme.subtleText)
                        TextField("Value", text: $value)
                            .font(.system(size: 13, design: .monospaced))
                            .textFieldStyle(.plain)
                            .padding(10)
                            .background(WorkshopTheme.darkCard)
                            .cornerRadius(8)
                            .foregroundColor(WorkshopTheme.brightText)
                            .keyboardType(.hexadecimal)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Size (Bytes)")
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(WorkshopTheme.subtleText)
                        TextField("1", text: $size)
                            .font(.system(size: 13, design: .monospaced))
                            .textFieldStyle(.plain)
                            .padding(10)
                            .background(WorkshopTheme.darkCard)
                            .cornerRadius(8)
                            .foregroundColor(WorkshopTheme.brightText)
                            .keyboardType(.numberPad)
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
                }

                Section {
                    Button(action: onCreate) {
                        HStack(spacing: 6) {
                            Image(systemName: "hexagon.fill")
                            Text("Create Byte Patch")
                        }
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(WorkshopTheme.warningYellow)
                        .foregroundColor(.black)
                        .cornerRadius(8)
                    }
                    .disabled(address.isEmpty)
                }
            }
            .background(WorkshopTheme.deepBackground)
            .scrollContentBackground(.hidden)
            .navigationTitle("Create Byte Patch")
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
}
