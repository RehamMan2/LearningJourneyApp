//
//  ActivityCalendar.swift
//  LearningJourneyApp
//
//  Created by Reham Aljulayfi on 13/11/2026.
//

import SwiftUI

struct ActivityCalendar: View {

    let viewModel: ActivityViewModel
    let now: Date

    private let orange = Color("Accent Orange")
    private let blue = Color("Accent Blue")

    var body: some View {

        // عرض أيام الأسبوع أفقيًا
        HStack(spacing: 0) {

            ForEach(
                viewModel.weekDates(at: now),
                id: \.self
            ) { date in

                VStack(spacing: 8) {

                    // اسم اليوم
                    Text(
                        date.formatted(
                            .dateTime.weekday(.narrow)
                        )
                    )
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.white)

                    // رقم اليوم وحالته
                    Text(date.formatted(.dateTime.day()))
                        .font(.system(size: 24, weight: .medium))
                        .foregroundStyle(textColor(for: date))
                        .frame(width: 44, height: 52)
                        .background {
                            Circle()
                                .fill(backgroundColor(for: date))
                        }
                }
                .frame(maxWidth: .infinity)
            }
        }
    }

    // لون خلفية اليوم
    private func backgroundColor(for date: Date) -> Color {

        if Calendar.current.isDate(date, inSameDayAs: now) {
            return orange
        }

        switch viewModel.status(on: date) {
        case .learned:
            return orange.opacity(0.15)
        case .frozen:
            return blue.opacity(0.15)
        case nil:
            return .clear
        }
    }

    // لون رقم اليوم
    private func textColor(for date: Date) -> Color {

        if Calendar.current.isDate(date, inSameDayAs: now) {
            return .white
        }

        switch viewModel.status(on: date) {
        case .learned: return orange
        case .frozen: return blue
        case nil: return .white
        }
    }
}
