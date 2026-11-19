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
    var fontWeight: Font.Weight = .medium
    var action: () -> Void

    var body: some View {

        if isSelected {

            buttonContent
                .buttonStyle(.glassProminent)
                .tint(Color("Accent Orange"))

        } else {

            buttonContent
                .buttonStyle(.glass)
                .tint(
                    isSelected
                        ? Color("Accent Orange")
                        : Color.gray.opacity(0.2)
                )
        }
    }

    // Shared button content
    private var buttonContent: some View {

        Button(action: action) {

            Text(title)
                .font(.system(size: fontSize, weight: fontWeight))
                .frame(width: width, height: height)
                .padding(.horizontal, width == nil ? 20 : 0)

        }
        .buttonBorderShape(.capsule)
    }
}

