//
//  ActivityView.swift
//  LearningApp
//
//  Created by Reham Aljulayfi on 10/11/2026.
//


import SwiftUI
import Combine

struct ActivityView: View {

    // حالة الصفحة والوقت الحالي
    @State private var viewModel = ActivityViewModel.shared
    @State private var now = Date()

    @Environment(\.scenePhase) private var scenePhase

    // ألوان الصفحة
    private let orange = Color("Accent Orange")
    private let blue = Color("Accent Blue")

    // تحديث الوقت دوريًا
    private let clock = Timer.publish(
        every: 60,
        on: .main,
        in: .common
    ).autoconnect()

    var body: some View {

        NavigationStack {

            GeometryReader { geometry in

                ScrollView {

                    VStack(spacing: 0) {

                        // عنوان الصفحة وأزرار التنقل
                        header

                        // التقويم الأسبوعي
                        ActivityCalendar(
                            viewModel: viewModel,
                            now: now
                        )
                        .padding(.top, 24)

                        // بطاقات Streak وFreeze
                        HStack(spacing: 12) {

                            ProgressCard(
                                icon: "flame.fill",
                                count: viewModel.streak(at: now),
                                title: "Learned",
                                color: orange
                            )

                            ProgressCard(
                                icon: "snowflake",
                                count: viewModel.usedFreezes(at: now),
                                title: "Freezed",
                                color: blue
                            )
                        }
                        .padding(.top, 16)

                        Spacer(minLength: 56)

                        // زر تسجيل التعلم
                        learnedButton

                        Spacer(minLength: 48)

                        // زر التجميد
                        freezeButton

                        // عدد مرات التجميد المستخدمة
                        Text(
                            "\(viewModel.usedFreezes(at: now)) out of \(viewModel.duration.freezeLimit) Freezes used"
                        )
                        .font(.system(size: 16))
                        .foregroundStyle(.gray)
                        .padding(.top, 16)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                    .frame(
                        minHeight: geometry.size.height,
                        alignment: .top
                    )
                }
            }
            .background(.black)
            .toolbar(.hidden, for: .navigationBar)
        }
        .onReceive(clock) { date in
            now = date
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active {
                now = Date()
            }
        }
    }

    // عنوان الصفحة والتاريخ وأزرار التنقل
    private var header: some View {

        VStack(alignment: .leading, spacing: 8) {

            HStack {

                Text("Activity")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundStyle(.white)

                Spacer()

                NavigationLink {
                    CalendarView()
                } label: {
                    headerIcon("calendar")
                }

                NavigationLink {
                    UpdateGoalView(activityViewModel: viewModel)
                } label: {
                    headerIcon("square.and.pencil")
                }
            }

            Text(
                now.formatted(
                    .dateTime
                        .weekday(.wide)
                        .day()
                        .month(.wide)
                )
            )
            .font(.system(size: 20))
            .foregroundStyle(.gray)
        }
    }

    // شكل الأيقونات الدائرية في الأعلى
    private func headerIcon(_ name: String) -> some View {

        Image(systemName: name)
            .font(.system(size: 24))
            .foregroundStyle(.white)
            .frame(width: 48, height: 48)
            .background(Color("Card Background"))
            .clipShape(Circle())
            .overlay {
                Circle()
                    .stroke(
                        .white.opacity(0.2),
                        lineWidth: 1
                    )
            }
    }

    // زر Learned مع إمكانية التراجع
    private var learnedButton: some View {

        Button {

            let currentDate = Date()
            viewModel.toggleLearned(at: currentDate)
            now = currentDate

        } label: {

            Text(learnedButtonTitle)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 280, height: 280)
                .background {
                    Circle()
                        .fill(orange)
                }
                .frame(maxWidth: .infinity)
        }
        .disabled(!viewModel.canLog(at: now))
        .opacity(viewModel.canLog(at: now) ? 1 : 0.5)
    }

    // نص زر Learned حسب حالة اليوم
    private var learnedButtonTitle: String {

        switch viewModel.status(on: now) {
        case .learned:
            return "Undo Learned"
        case .frozen:
            return "Day Frozen"
        case nil:
            return "Log as Learned"
        }
    }

    // زر Freeze مع إمكانية التراجع
    private var freezeButton: some View {

        Button {

            let currentDate = Date()
            viewModel.toggleFreeze(at: currentDate)
            now = currentDate

        } label: {

            Text(freezeButtonTitle)
                .font(.system(size: 20))
                .foregroundStyle(
                    viewModel.canFreeze(at: now)
                    ? .white : .gray
                )
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background {
                    Capsule()
                        .fill(
                            viewModel.canFreeze(at: now)
                            ? blue
                            : Color("Card Background")
                        )
                }
                .overlay {
                    Capsule()
                        .stroke(
                            .white.opacity(0.3),
                            lineWidth: 1
                        )
                }
        }
        .disabled(!viewModel.canFreeze(at: now))
    }

    // نص زر Freeze حسب حالة اليوم
    private var freezeButtonTitle: String {

        if viewModel.status(on: now) == .frozen {
            return "Undo Freeze"
        }

        return "Freeze for a day"
    }
}

#Preview {
    ActivityView()
}
