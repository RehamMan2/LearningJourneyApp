//
//  ProgressCard.swift
//  LearningJourneyApp
//
//  Created by Reham Aljulayfi on 13/11/2026.
//



import SwiftUI

struct ProgressCard: View {

    // بيانات البطاقة
    let icon: String
    let count: Int
    let title: String
    let color: Color

    // اختيار المفرد أو الجمع
    private var dayText: String {
        "\(count) \(count == 1 ? "day" : "days")"
    }

    var body: some View {

        VStack(spacing: 8) {

            // أيقونة البطاقة
            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundStyle(color)

            // عدد الأيام
            Text(dayText)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(.white)

            // وصف البطاقة
            Text(title)
                .font(.system(size: 16))
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 116)
        .background(Color("Card Background"))
        .clipShape(
            RoundedRectangle(cornerRadius: 36)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 36)
                .stroke(
                    .white.opacity(0.2),
                    lineWidth: 1
                )
        }
    }
}
