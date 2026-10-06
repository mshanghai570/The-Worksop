//
//  Views/Binary/HookCreatorView.swift
//  TheWorkshop-iOS
//  Hook Creator View
//

import SwiftUI

struct HookCreatorView: View {
    @Binding var className: String
    @Binding var methodName: String
    @Binding var isClassMethod: Bool
    @Binding var hookType: HookType
    @Binding var callbackCode: String
    
    let onCreate: () -> Void

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("HOOK CONFIGURATION")) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Class Name")
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(WorkshopTheme.subtleText)
                        TextField("Enter class name", text: $className)
                            .font(.system(size: 13, design: .monospaced))
                            .textFieldStyle(.plain)
                            .padding(10)
                            .background(WorkshopTheme.darkCard)
                            .cornerRadius(8)
                            .foregroundColor(WorkshopTheme.brightText)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Method Name")
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(WorkshopTheme.subtleText)
                        TextField("Enter method name", text: $methodName)
                            .font(.system(size: 13, design: .monospaced))
                            .textFieldStyle(.plain)
                            .padding(10)
                            .background(WorkshopTheme.darkCard)
                            .cornerRadius(8)
                            .foregroundColor(WorkshopTheme.brightText)
                    }

                    Toggle("Class Method", isOn: $isClassMethod)
                        .font(.system(size: 12, design: .monospaced))
                        .tint(WorkshopTheme.neonGreen)
                }

                Section(header: Text("HOOK TYPE")) {
                    Picker("Hook Type", selection: $hookType) {
                        ForEach(HookType.allCases, id: \.self) { type in
                            Text(type.rawValue.capitalized)
                                .tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                    .tint(WorkshopTheme.neonGreen)
                }

                Section(header: Text("CALLBACK CODE")) {
                    TextEditor(text: $callbackCode)
                        .font(.system(size: 12, design: .monospaced))
                        .padding(10)
                        .background(WorkshopTheme.darkCard)
                        .cornerRadius(8)
                        .foregroundColor(WorkshopTheme.brightText)
                        .frame(minHeight: 120)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(WorkshopTheme.cardBorder, lineWidth: 1)
                        )
                }

                Section {
                    Button(action: onCreate) {
                        HStack(spacing: 6) {
                            Image(systemName: "plus.circle.fill")
                            Text("Create Hook")
                        }
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(WorkshopTheme.neonGreen)
                        .foregroundColor(.black)
                        .cornerRadius(8)
                    }
                    .disabled(className.isEmpty || methodName.isEmpty)
                }
            }
            .background(WorkshopTheme.deepBackground)
            .scrollContentBackground(.hidden)
            .navigationTitle("Create Hook")
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
