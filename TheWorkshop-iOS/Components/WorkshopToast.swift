//
//  Components/WorkshopToast.swift
//  TheWorkshop-iOS
//

import SwiftUI

public struct WorkshopToast: View {
    public let message: String

    public var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(WorkshopTheme.neonGreen)
            Text(message)
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(WorkshopTheme.oledBlack)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(WorkshopTheme.neonGreen, lineWidth: 1)
        )
        .shadow(color: WorkshopTheme.neonGreen.opacity(0.3), radius: 10)
    }
}
