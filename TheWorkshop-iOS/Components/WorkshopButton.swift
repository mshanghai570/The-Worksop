//
//  Components/WorkshopButton.swift
//  TheWorkshop-iOS
//

import SwiftUI

public enum WorkshopButtonStyle {
    case neonGreen
    case hotPink
    case outline
}

public struct WorkshopButton: View {
    public let title: String
    public let systemImage: String?
    public let style: WorkshopButtonStyle
    public let action: () -> Void

    public init(
        title: String,
        systemImage: String? = nil,
        style: WorkshopButtonStyle = .neonGreen,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.systemImage = systemImage
        self.style = style
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let image = systemImage {
                    Image(systemName: image)
                }
                Text(title)
            }
            .font(.system(size: 11, weight: .bold, design: .monospaced))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(backgroundColor)
            .foregroundStyle(foregroundColor)
            .cornerRadius(6)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(borderColor, lineWidth: 1)
            )
        }
    }

    private var backgroundColor: Color {
        switch style {
        case .neonGreen: return WorkshopTheme.neonGreen.opacity(0.15)
        case .hotPink: return WorkshopTheme.hotPink.opacity(0.15)
        case .outline: return Color.black
        }
    }

    private var foregroundColor: Color {
        switch style {
        case .neonGreen: return WorkshopTheme.neonGreen
        case .hotPink: return WorkshopTheme.hotPink
        case .outline: return Color.white
        }
    }

    private var borderColor: Color {
        switch style {
        case .neonGreen: return WorkshopTheme.neonGreen
        case .hotPink: return WorkshopTheme.hotPink
        case .outline: return WorkshopTheme.borderGray
        }
    }
}
