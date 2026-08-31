//
//  Views/Canvas/BlockPaletteView.swift
//  TheWorkshop-iOS
//  Category-filtered Block Palette
//

import SwiftUI

public struct BlockPaletteView: View {
    @ObservedObject var projectVM: ProjectViewModel
    @State private var selectedCategory: String = "All"

    let categories = ["All", "Hooking", "Actions", "Control Flow", "Jailed Modifications", "Native Extension"]

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("BLOCK PALETTE")
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundStyle(WorkshopTheme.subtleText)
                .padding(.horizontal, 12)
                .padding(.top, 8)

            // Category Picker
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(categories, id: \.self) { cat in
                        Button {
                            selectedCategory = cat
                        } label: {
                            Text(cat)
                                .font(.system(size: 10, weight: .medium, design: .monospaced))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(selectedCategory == cat ? WorkshopTheme.neonGreen.opacity(0.2) : Color.black)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 4)
                                        .stroke(selectedCategory == cat ? WorkshopTheme.neonGreen : WorkshopTheme.borderGray, lineWidth: 1)
                                )
                                .foregroundStyle(selectedCategory == cat ? WorkshopTheme.neonGreen : Color.gray)
                        }
                    }
                }
                .padding(.horizontal, 12)
            }

            // Available Blocks
            ScrollView {
                VStack(spacing: 6) {
                    ForEach(filteredDefinitions, id: \.type) { def in
                        Button {
                            projectVM.addBlock(type: def.type)
                        } label: {
                            HStack {
                                Image(systemName: def.iconName)
                                    .foregroundStyle(def.badgeColor)
                                    .frame(width: 20)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(def.name)
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundStyle(.white)
                                    Text(def.description)
                                        .font(.system(size: 9))
                                        .foregroundStyle(WorkshopTheme.subtleText)
                                        .lineLimit(1)
                                }

                                Spacer()

                                Image(systemName: "plus.circle")
                                    .font(.caption)
                                    .foregroundStyle(WorkshopTheme.subtleText)
                            }
                            .padding(8)
                            .background(WorkshopTheme.cardBackground)
                            .cornerRadius(6)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(WorkshopTheme.borderGray, lineWidth: 1)
                            )
                        }
                    }
                }
                .padding(.horizontal, 12)
            }
        }
        .background(WorkshopTheme.darkCharcoal)
    }

    private var filteredDefinitions: [BlockDefinition] {
        let all = Array(BlockRegistryService.shared.definitions.values)
        let targetType = projectVM.project.projectType

        return all.filter { def in
            let matchesTarget = def.supportedTargetTypes.contains(targetType)
            if !matchesTarget { return false }

            if selectedCategory == "All" { return true }
            return def.type.categoryName == selectedCategory
        }
    }
}
