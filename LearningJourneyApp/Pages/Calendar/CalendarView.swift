//
//  CalendarView.swift
//  LearningApp
//
//  Created by Reham Aljulayfi on 10/11/2026.
//


import SwiftUI

struct CalendarView: View {

    @State private var viewModel = CalendarViewModel()

    // Calendar colors.
    // Calendar colors from Assets
    private let orange = Color("Accent Orange")
    private let blue = Color("Accent Blue")
    private let primaryText = Color("Primary Text")
    private let secondaryText = Color("Secondary Text")

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {

                // Fixed navigation header.
                header

                // Scrollable months.
                ScrollView {
                    LazyVStack(spacing: 24) {
                        ForEach(viewModel.months, id: \.self) { month in
                            monthSection(month)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 24)
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    // Navigation title and back button.
    private var header: some View {
        ZStack {
            Text("Activities")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.white)

            HStack {
                Button {
                    // Uses the navigation environment to go back.
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(.white)
                        .frame(width: 48, height: 48)
                        .background(Color(white: 0.12))
                        .clipShape(Circle())
                        .overlay {
                            Circle()
                                .stroke(Color(white: 0.2), lineWidth: 1)
                        }
                }

                Spacer()
            }
        }
        .frame(height: 56)
        .padding(.horizontal, 20)
    }

    // Dismisses the current screen.
    @Environment(\.dismiss) private var dismiss

    // Displays one month and its calendar grid.
    private func monthSection(_ month: Date) -> some View {
        VStack(alignment: .leading, spacing: 16) {

            Text(viewModel.monthTitle(for: month))
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.white)

            // Weekday names.
            LazyVGrid(
                columns: columns,
                spacing: 0
            ) {
                ForEach(viewModel.weekdays, id: \.self) { weekday in
                    Text(weekday)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.gray)
                        .frame(maxWidth: .infinity)
                }
            }

            // Read-only calendar days.
            LazyVGrid(
                columns: columns,
                spacing: 16
            ) {
                ForEach(
                    Array(viewModel.days(for: month).enumerated()),
                    id: \.offset
                ) { _, date in

                    if let date {
                        dayCell(date)
                    } else {
                        Color.clear
                            .frame(height: 40)
                    }
                }
            }

            Divider()
                .background(Color.white.opacity(0.15))
                .padding(.top, 8)
        }
    }

    // Seven equally spaced calendar columns.
    private var columns: [GridItem] {
        Array(
            repeating: GridItem(.flexible(), spacing: 4),
            count: 7
        )
    }

    // Displays the day number and its status.
    private func dayCell(_ date: Date) -> some View {
        let status = viewModel.status(for: date)
        let today = viewModel.isToday(date)

        return Text("\(Calendar.current.component(.day, from: date))")
            .font(.system(size: 20))
            .foregroundStyle(dayTextColor(status: status, today: today))
            .frame(maxWidth: .infinity)
            .frame(height: 40)
            .background {
                Circle()
                    .fill(dayBackground(status: status, today: today))
                    .frame(width: 40, height: 40)
            }
    }

    // Determines the day number color.
    private func dayTextColor(
        status: LearningDayStatus?,
        today: Bool
    ) -> Color {
        if today { return .white }

        switch status {
        case .learned: return orange
        case .freeze: return blue
        case nil: return .white
        }
    }

    // Determines the day circle background.
    private func dayBackground(
        status: LearningDayStatus?,
        today: Bool
    ) -> Color {
        if today { return orange }

        switch status {
        case .learned: return orange
        case .freeze: return blue
        case nil: return .clear
        }
    }
}

#Preview {
    NavigationStack {
        CalendarView()
    }
}
