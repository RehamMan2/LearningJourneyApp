//
//  Buttons.swift
//  LearningJourneyApp
//
//  Created by Reham Aljulayfi on 13/11/2026.
//

import SwiftUI

struct Buttons: View {
    let title: String
    var isSelected = true
    var width: CGFloat? = nil
    var height: CGFloat = 48
    var fontSize: CGFloat = 18
    var action: () -> Void

    private let orange = Color(red: 242/255, green: 154/255, blue: 67/255)

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: fontSize, weight: .medium))
                .foregroundStyle(isSelected ? .white : .gray)
                .frame(width: width, height: height)
                .padding(.horizontal, width == nil ? 20 : 0)
                .background {
                    Capsule()
                        .fill(
                            isSelected
                            ? orange.gradient
                            : Color(white: 0.13).gradient
                        )
                }
                .overlay {
                    Capsule()
                        .strokeBorder(
                            isSelected ? orange.opacity(0.8) : .gray.opacity(0.3),
                            lineWidth: 1
                        )
                }
        }
        .buttonStyle(.plain)
    }
}
