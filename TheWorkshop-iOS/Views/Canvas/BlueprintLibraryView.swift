//
//  Views/Canvas/BlueprintLibraryView.swift
//  TheWorkshop-iOS
//  Starter Blueprint Templates Gallery Sheet
//

import SwiftUI

public struct BlueprintLibraryView: View {
    @ObservedObject var viewModel: ProjectViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var selectedCategory: String = "All"

    private var categories: [String] {
        let all = BlueprintLibraryService.shared.blueprints.map { $0.category }
        return ["All"] + Array(Set(all)).sorted()
    }

    private var filteredBlueprints: [BlueprintTemplate] {
        let list = BlueprintLibraryService.shared.blueprints
        if selectedCategory == "All" {
            return list
        }
        return list.filter { $0.category == selectedCategory }
    }

    public init(viewModel: ProjectViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Category Filter Bar
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(categories, id: \.self) { cat in
                            Button(action: { selectedCategory = cat }) {
                                Text(cat)
                                    .font(.system(size: 13, weight: .semibold, design: .monospaced))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(selectedCategory == cat ? WorkshopTheme.neonGreen.opacity(0.2) : WorkshopTheme.darkCard)
                                    .foregroundColor(selectedCategory == cat ? WorkshopTheme.neonGreen : WorkshopTheme.subtleText)
                                    .cornerRadius(16)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(selectedCategory == cat ? WorkshopTheme.neonGreen : WorkshopTheme.cardBorder, lineWidth: 1)
                                    )
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }

                Divider().background(WorkshopTheme.cardBorder)

                // Blueprints Grid
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(filteredBlueprints) { bp in
                            BlueprintRowView(blueprint: bp) {
                                viewModel.loadBlueprint(bp)
                                dismiss()
                            }
                        }
                    }
                    .padding(16)
                }
            }
            .background(WorkshopTheme.deepBackground.ignoresSafeArea())
            .navigationTitle("Blueprint Library")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(WorkshopTheme.subtleText)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

struct BlueprintRowView: View {
    let blueprint: BlueprintTemplate
    let onSelect: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: blueprint.iconName)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(WorkshopTheme.neonGreen)
                    .frame(width: 32, height: 32)
                    .background(WorkshopTheme.neonGreen.opacity(0.12))
                    .cornerRadius(8)

                VStack(alignment: .leading, spacing: 2) {
                    Text(blueprint.title)
                        .font(.system(size: 15, weight: .bold, design: .monospaced))
                        .foregroundColor(WorkshopTheme.brightText)

                    Text(blueprint.category)
                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                        .foregroundColor(WorkshopTheme.cyberCyan)
                }

                Spacer()

                WorkshopBadge(text: blueprint.targetType.displayName, color: blueprint.targetType == .jailbreakTweak ? WorkshopTheme.neonGreen : WorkshopTheme.hotPink)
            }

            Text(blueprint.summary)
                .font(.system(size: 13))
                .foregroundColor(WorkshopTheme.subtleText)
                .fixedSize(horizontal: false, vertical: true)

            HStack {
                HStack(spacing: 4) {
                    Image(systemName: "square.grid.2x2.fill")
                        .font(.system(size: 11))
                    Text("\(blueprint.blocks.count) Blocks")
                        .font(.system(size: 12, weight: .semibold, design: .monospaced))
                }
                .foregroundColor(WorkshopTheme.subtleText)

                Spacer()

                Button(action: onSelect) {
                    HStack(spacing: 6) {
                        Text("Load Blueprint")
                        Image(systemName: "arrow.right.circle.fill")
                    }
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(WorkshopTheme.neonGreen)
                    .foregroundColor(.black)
                    .cornerRadius(8)
                }
            }
        }
        .padding(14)
        .background(WorkshopTheme.darkCard)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(WorkshopTheme.cardBorder, lineWidth: 1)
        )
    }
}
