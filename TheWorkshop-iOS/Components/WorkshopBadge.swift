//
//  Components/WorkshopBadge.swift
//  TheWorkshop-iOS
//

import SwiftUI

public struct WorkshopBadge: View {
    public let text: String
    public let color: Color

    public init(text: String, color: Color = WorkshopTheme.neonGreen) {
        self.text = text
        self.color = color
    }

    public var body: some View {
        Text(text)
            .font(.system(size: 8, weight: .bold, design: .monospaced))
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(color.opacity(0.18))
            .foregroundStyle(color)
            .cornerRadius(4)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(color.opacity(0.6), lineWidth: 1)
            )
    }
}
