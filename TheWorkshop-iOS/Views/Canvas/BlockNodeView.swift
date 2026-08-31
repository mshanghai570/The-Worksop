//
//  Views/Canvas/BlockNodeView.swift
//  TheWorkshop-iOS
//  Render node element on canvas
//

import SwiftUI

public struct BlockNodeView: View {
    public let block: Block
    public let isSelected: Bool
    public let onSelect: () -> Void
    public let onDragChange: (CGSize) -> Void

    @State private var dragOffset: CGSize = .zero

    public var definition: BlockDefinition? {
        BlockRegistryService.shared.definitions[block.type]
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Header Bar
            HStack {
                Image(systemName: definition?.iconName ?? "cube.fill")
                    .font(.caption)
                    .foregroundStyle(definition?.badgeColor ?? WorkshopTheme.neonGreen)

                Text(definition?.name ?? block.type.rawValue)
                    .font(.caption)
                    .bold()
                    .foregroundStyle(.white)

                Spacer()

                WorkshopBadge(
                    text: block.type.categoryName,
                    color: definition?.badgeColor ?? WorkshopTheme.neonGreen
                )
            }

            Divider().background(WorkshopTheme.borderGray)

            // Body Preview Summary
            VStack(alignment: .leading, spacing: 4) {
                switch block.type {
                case .hook:
                    Text("\(block.targetClass ?? "Class").\(block.targetMethod ?? "method")")
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundStyle(WorkshopTheme.neonGreen)
                case .log:
                    Text(block.message ?? "Log message")
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundStyle(WorkshopTheme.cyberCyan)
                case .delay:
                    Text("Delay: \(String(format: "%.1fs", block.durationSeconds ?? 1.0))")
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundStyle(WorkshopTheme.warningYellow)
                case .replaceAsset:
                    Text("Path: \(block.assetPath ?? "Asset")")
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundStyle(WorkshopTheme.hotPink)
                case .editPlist:
                    Text("\(block.plistKey ?? "Key") = \(block.plistValue ?? "Val")")
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundStyle(WorkshopTheme.cyberCyan)
                case .swiftuiView:
                    Text(block.viewTitle ?? "SwiftUIView")
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundStyle(WorkshopTheme.neonGreen)
                default:
                    Text("Configured node")
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundStyle(WorkshopTheme.subtleText)
                }
            }
        }
        .padding(10)
        .frame(width: 220)
        .background(WorkshopTheme.cardBackground)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isSelected ? (definition?.badgeColor ?? WorkshopTheme.neonGreen) : WorkshopTheme.borderGray, lineWidth: isSelected ? 2 : 1)
        )
        .shadow(color: isSelected ? (definition?.badgeColor.opacity(0.4) ?? .clear) : .black.opacity(0.4), radius: 6)
        .position(x: CGFloat(block.x) + dragOffset.width, y: CGFloat(block.y) + dragOffset.height)
        .onTapGesture {
            onSelect()
        }
        .gesture(
            DragGesture()
                .onChanged { value in
                    dragOffset = value.translation
                }
                .onEnded { value in
                    onDragChange(value.translation)
                    dragOffset = .zero
                }
        )
    }
}
