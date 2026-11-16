//
//  CalendarView.swift
//  LearningApp
//
//  Created by Reham Aljulayfi on 10/11/2026.
//



import SwiftUI

struct CalendarView: View {

    // ViewModel الخاص بالتقويم
    @State private var viewModel = CalendarViewModel()

    // الرجوع للصفحة السابقة
    @Environment(\.dismiss) private var dismiss

    // الألوان من Assets
    private let orange = Color("Accent Orange")
    private let blue = Color("Accent Blue")
    private let primaryText = Color("Primary Text")
    private let secondaryText = Color("Secondary Text")

    var body: some View {

        ZStack {

            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {

                // Header ثابت
                header

                // عرض الأشهر من بداية السنة
                ScrollView {

                    LazyVStack(spacing: 24) {

                        ForEach(
                            viewModel.months,
                            id: \.self
                        ) { month in

                            monthSection(month)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 24)
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .preferredColorScheme(.dark)
    }

    // عنوان الصفحة وزر الرجوع
    private var header: some View {

        ZStack {

            Text("Activities")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.white)

            HStack {

                Button {
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
                                .stroke(
                                    Color(white: 0.2),
                                    lineWidth: 1
                                )
                        }
                }

                Spacer()
            }
        }
        .frame(height: 56)
        .padding(.horizontal, 20)
    }

    // عرض شهر واحد
    private func monthSection(_ month: Date) -> some View {

        VStack(alignment: .leading, spacing: 16) {

            Text(viewModel.monthTitle(for: month))
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.white)

            // أسماء أيام الأسبوع
            LazyVGrid(
                columns: columns,
                spacing: 0
            ) {

                ForEach(
                    viewModel.weekdays,
                    id: \.self
                ) { weekday in

                    Text(weekday)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.gray)
                        .frame(maxWidth: .infinity)
                }
            }

            // أيام الشهر وحالاتها
            LazyVGrid(
                columns: columns,
                spacing: 16
            ) {

                ForEach(
                    Array(
                        viewModel.days(for: month).enumerated()
                    ),
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

    // سبعة أعمدة للتقويم
    private var columns: [GridItem] {

        Array(
            repeating: GridItem(
                .flexible(),
                spacing: 4
            ),
            count: 7
        )
    }

    // عرض رقم اليوم وحالته
    private func dayCell(_ date: Date) -> some View {

        let status = viewModel.status(for: date)
        let today = viewModel.isToday(date)

        return Text(
            "\(Calendar.current.component(.day, from: date))"
        )
        .font(.system(size: 20))
        .foregroundStyle(
            dayTextColor(status: status, today: today)
        )
        .frame(maxWidth: .infinity)
        .frame(height: 40)
        .background {

            Circle()
                .fill(
                    dayBackground(status: status, today: today)
                )
                .frame(width: 40, height: 40)
                .overlay {

                    // إطار لتمييز اليوم الحالي
                    if today {

                        Circle()
                            .stroke(
                                Color.white.opacity(0.8),
                                lineWidth: 2
                            )
                    }
                }
        }
    }

    // تحديد لون رقم اليوم
    private func dayTextColor(
        status: ActivityStatus?,
        today: Bool
    ) -> Color {

        switch status {

        case .learned, .frozen:
            return .white

        case nil:
            return today ? orange : .white
        }
    }

    // تحديد لون خلفية اليوم
    private func dayBackground(
        status: ActivityStatus?,
        today: Bool
    ) -> Color {

        switch status {

        case .learned:
            return orange

        case .frozen:
            return blue

        case nil:
            return .clear
        }
    }
}

#Preview {
    NavigationStack {
        CalendarView()
    }
}
