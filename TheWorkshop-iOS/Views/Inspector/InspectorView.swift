//
//  Views/Inspector/InspectorView.swift
//  TheWorkshop-iOS
//  Professional IDE Property Inspector with Learn Mode
//

import SwiftUI

public struct InspectorView: View {
    @ObservedObject var projectVM: ProjectViewModel
    @State private var isLearnModeExpanded: Bool = true

    public init(projectVM: ProjectViewModel) {
        self.projectVM = projectVM
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Inspector Panel Header
            HStack {
                Image(systemName: "slider.horizontal.3")
                    .foregroundColor(WorkshopTheme.cyberCyan)
                Text("INSPECTOR PANEL")
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundColor(WorkshopTheme.subtleText)

                Spacer()

                if let block = projectVM.selectedBlock {
                    Button(role: .destructive) {
                        projectVM.deleteBlock(id: block.id)
                    } label: {
                        Image(systemName: "trash.fill")
                            .font(.system(size: 12))
                            .foregroundColor(WorkshopTheme.errorRed)
                    }
                }
            }
            .padding(12)
            .background(WorkshopTheme.darkCard)

            Divider().background(WorkshopTheme.cardBorder)

            if var block = projectVM.selectedBlock {
                let def = BlockRegistryService.shared.definitions[block.type]

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // 1. Block Header & Metadata
                        HStack(spacing: 10) {
                            Image(systemName: def?.iconName ?? "square.grid.2x2")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(def?.badgeColor ?? WorkshopTheme.neonGreen)
                                .frame(width: 36, height: 36)
                                .background((def?.badgeColor ?? WorkshopTheme.neonGreen).opacity(0.15))
                                .cornerRadius(8)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(def?.name ?? block.type.rawValue.capitalized)
                                    .font(.system(size: 15, weight: .bold, design: .monospaced))
                                    .foregroundColor(WorkshopTheme.brightText)

                                Text("ID: \(block.id)")
                                    .font(.system(size: 10, design: .monospaced))
                                    .foregroundColor(WorkshopTheme.subtleText)
                            }
                        }
                        .padding(.top, 12)

                        Divider().background(WorkshopTheme.cardBorder)

                        // 2. Editable Properties & Fields
                        VStack(alignment: .leading, spacing: 12) {
                            Text("PROPERTIES & TYPES")
                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                                .foregroundColor(WorkshopTheme.cyberCyan)

                            switch block.type {
                            case .hook:
                                PropertyField(label: "Target Class Name", text: Binding(
                                    get: { block.targetClass ?? "" },
                                    set: { block.targetClass = $0; projectVM.selectedBlock = block }
                                ))
                                PropertyField(label: "Target Method Selector", text: Binding(
                                    get: { block.targetMethod ?? "" },
                                    set: { block.targetMethod = $0; projectVM.selectedBlock = block }
                                ))
                                PropertyField(label: "Return Type", text: Binding(
                                    get: { block.returnType ?? "void" },
                                    set: { block.returnType = $0; projectVM.selectedBlock = block }
                                ))

                            case .log:
                                PropertyField(label: "Console Log Message", text: Binding(
                                    get: { block.message ?? "" },
                                    set: { block.message = $0; projectVM.selectedBlock = block }
                                ))

                            case .delay:
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Pause Duration (Seconds)")
                                        .font(.system(size: 11, weight: .semibold, design: .monospaced))
                                        .foregroundColor(WorkshopTheme.subtleText)
                                    Slider(value: Binding(
                                        get: { block.durationSeconds ?? 1.0 },
                                        set: { block.durationSeconds = $0; projectVM.selectedBlock = block }
                                    ), in: 0.1...10.0, step: 0.5)
                                    Text(String(format: "%.1f seconds", block.durationSeconds ?? 1.0))
                                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                                        .foregroundColor(WorkshopTheme.warningYellow)
                                }

                            case .replaceAsset:
                                PropertyField(label: "Target IPA Asset Path", text: Binding(
                                    get: { block.assetPath ?? "" },
                                    set: { block.assetPath = $0; projectVM.selectedBlock = block }
                                ))
                                PropertyField(label: "Replacement Source Path", text: Binding(
                                    get: { block.replacementUrl ?? "" },
                                    set: { block.replacementUrl = $0; projectVM.selectedBlock = block }
                                ))

                            case .editPlist:
                                PropertyField(label: "Plist Key Name", text: Binding(
                                    get: { block.plistKey ?? "" },
                                    set: { block.plistKey = $0; projectVM.selectedBlock = block }
                                ))
                                PropertyField(label: "Plist String Value", text: Binding(
                                    get: { block.plistValue ?? "" },
                                    set: { block.plistValue = $0; projectVM.selectedBlock = block }
                                ))

                            case .swiftuiView:
                                PropertyField(label: "SwiftUI View Struct Name", text: Binding(
                                    get: { block.viewTitle ?? "" },
                                    set: { block.viewTitle = $0; projectVM.selectedBlock = block }
                                ))

                            case .modifyProperty:
                                PropertyField(label: "Target Object", text: Binding(
                                    get: { block.targetObject ?? "self" },
                                    set: { block.targetObject = $0; projectVM.selectedBlock = block }
                                ))
                                PropertyField(label: "Property Name", text: Binding(
                                    get: { block.propertyName ?? "" },
                                    set: { block.propertyName = $0; projectVM.selectedBlock = block }
                                ))
                                PropertyField(label: "Assigned Value", text: Binding(
                                    get: { block.value ?? "" },
                                    set: { block.value = $0; projectVM.selectedBlock = block }
                                ))

                            case .notification:
                                PropertyField(label: "Banner Title", text: Binding(
                                    get: { block.titleText ?? "" },
                                    set: { block.titleText = $0; projectVM.selectedBlock = block }
                                ))
                                PropertyField(label: "Banner Body Text", text: Binding(
                                    get: { block.bodyText ?? "" },
                                    set: { block.bodyText = $0; projectVM.selectedBlock = block }
                                ))

                            case .returnValue:
                                PropertyField(label: "Override Return Value", text: Binding(
                                    get: { block.returnValue ?? "" },
                                    set: { block.returnValue = $0; projectVM.selectedBlock = block }
                                ))

                            case .customLogos:
                                Text("Raw Objective-C / Logos Snippet")
                                    .font(.system(size: 11, weight: .semibold, design: .monospaced))
                                    .foregroundColor(WorkshopTheme.subtleText)
                                TextEditor(text: Binding(
                                    get: { block.customCode ?? "" },
                                    set: { block.customCode = $0; projectVM.selectedBlock = block }
                                ))
                                .font(.system(size: 11, design: .monospaced))
                                .frame(height: 100)
                                .padding(4)
                                .background(WorkshopTheme.deepBackground)
                                .cornerRadius(6)
                                .overlay(RoundedRectangle(cornerRadius: 6).stroke(WorkshopTheme.cardBorder, lineWidth: 1))

                            default:
                                Text("Standard control node without custom properties.")
                                    .font(.system(size: 12))
                                    .foregroundColor(WorkshopTheme.subtleText)
                            }
                        }

                        Divider().background(WorkshopTheme.cardBorder)

                        // 3. Learn Mode Educational Drawer
                        if let edu = def?.education {
                            VStack(alignment: .leading, spacing: 10) {
                                Button(action: { isLearnModeExpanded.toggle() }) {
                                    HStack {
                                        Image(systemName: "academiccap.fill")
                                            .foregroundColor(WorkshopTheme.warningYellow)
                                        Text("LEARN MODE")
                                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                                            .foregroundColor(WorkshopTheme.warningYellow)
                                        Spacer()
                                        Image(systemName: isLearnModeExpanded ? "chevron.up" : "chevron.down")
                                            .foregroundColor(WorkshopTheme.subtleText)
                                    }
                                }

                                if isLearnModeExpanded {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Purpose")
                                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                                            .foregroundColor(WorkshopTheme.subtleText)
                                        Text(edu.purpose)
                                            .font(.system(size: 12))
                                            .foregroundColor(WorkshopTheme.brightText)

                                        Text("Generated Code Explanation")
                                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                                            .foregroundColor(WorkshopTheme.subtleText)
                                        Text(edu.codeExplanation)
                                            .font(.system(size: 12, design: .monospaced))
                                            .padding(8)
                                            .background(WorkshopTheme.deepBackground)
                                            .cornerRadius(6)
                                            .foregroundColor(WorkshopTheme.neonGreen)

                                        if !edu.commonMistakes.isEmpty {
                                            Text("Common Mistakes & Warnings")
                                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                                                .foregroundColor(WorkshopTheme.subtleText)
                                            ForEach(edu.commonMistakes, id: \.self) { mistake in
                                                HStack(alignment: .top, spacing: 6) {
                                                    Image(systemName: "exclamationmark.triangle.fill")
                                                        .font(.system(size: 10))
                                                        .foregroundColor(WorkshopTheme.warningYellow)
                                                    Text(mistake)
                                                        .font(.system(size: 11))
                                                        .foregroundColor(WorkshopTheme.subtleText)
                                                }
                                            }
                                        }
                                    }
                                    .padding(10)
                                    .background(WorkshopTheme.warningYellow.opacity(0.08))
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(WorkshopTheme.warningYellow.opacity(0.3), lineWidth: 1)
                                    )
                                }
                            }
                        }
                    }
                    .padding(16)
                }
            } else {
                VStack(spacing: 12) {
                    Spacer()
                    Image(systemName: "cursorarrow.click.2")
                        .font(.system(size: 32))
                        .foregroundColor(WorkshopTheme.subtleText.opacity(0.4))
                    Text("Select a node on the Visual Canvas to inspect and edit properties.")
                        .font(.system(size: 12))
                        .multilineTextAlignment(.center)
                        .foregroundColor(WorkshopTheme.subtleText)
                        .padding(.horizontal, 24)
                    Spacer()
                }
            }
        }
        .background(WorkshopTheme.deepBackground)
    }
}

struct PropertyField: View {
    let label: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                .foregroundColor(WorkshopTheme.subtleText)
            TextField("", text: $text)
                .font(.system(size: 12, design: .monospaced))
                .padding(8)
                .background(WorkshopTheme.darkCard)
                .cornerRadius(6)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(WorkshopTheme.cardBorder, lineWidth: 1)
                )
                .foregroundColor(WorkshopTheme.brightText)
        }
    }
}
