//
//  ActivityView.swift
//  LearningApp
//
//  Created by Reham Aljulayfi on 10/11/2026.
//




import SwiftUI
import Combine

struct ActivityView: View {

    // Shared ViewModel
    @State private var viewModel = ActivityViewModel.shared

    @State private var now = Date()
    @State private var showSetGoal = false

    @Environment(\.scenePhase) private var scenePhase

    // Colors from Assets
    private let orange = Color("Accent Orange")
    private let blue = Color("Accent Blue")
    private let cardBackground = Color("Card Background")

    // Update current time every minute
    private let clock = Timer.publish(
        every: 60,
        on: .main,
        in: .common
    ).autoconnect()

    var body: some View {

        NavigationStack {

            Group {

                // Show goal result when the period ends
//                
//                if true {
//
//                    let result: GoalResult = .notMet
                    
                    if let result = viewModel.goalResult(at: now) {

                    VStack(spacing: 0) {

                        header
                            .padding(.horizontal, 20)
                            .padding(.top, 24)

                        GoalResultView(
                            result: result,
                            activityViewModel: viewModel,
                            now: now
                        ) {
                            showSetGoal = true
                        }
                    }

                } else {

                    // Show normal Activity page
                    activityContent
                }
            }
            .background(.black)
            .toolbar(.hidden, for: .navigationBar)

            // Open SetGoalView after goal result
            .sheet(isPresented: $showSetGoal) {

                NavigationStack {

                    SetGoalView { topic, duration in

                        // Create and save a new learning goal
                        let newGoal = LearningGoal(
                            topic: topic,
                            duration: duration,
                            startDate: Date()
                        )

                        viewModel.setInitialGoal(newGoal)

                        // Refresh page after saving
                        now = Date()
                    }
                }
            }
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

    // Normal Activity page
    private var activityContent: some View {

        GeometryReader { geometry in

            ScrollView {

                VStack(spacing: 0) {

                    // Header
                    header

                    // Activity calendar
                    ActivityCalendar(
                        viewModel: viewModel,
                        now: now
                    )
                    .padding(.top, 24)

                    // Progress cards
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

                    // Learned button
                    learnedButton

                    Spacer(minLength: 48)

                    // Freeze button
                    freezeButton

                    // Freeze usage
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
    }

    // Page header
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
                    UpdateGoalView(
                        activityViewModel: viewModel
                    )
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

    // Header icon style
    private func headerIcon(_ name: String) -> some View {

        Image(systemName: name)
            .font(.system(size: 24))
            .foregroundStyle(.white)
            .frame(width: 48, height: 48)
            .background(cardBackground)
            .clipShape(Circle())
            .overlay {
                Circle()
                    .stroke(
                        .white.opacity(0.2),
                        lineWidth: 1
                    )
            }
    }

    // Learned button without Undo
    private var learnedButton: some View {

        let canLog = viewModel.canLog(at: now)
        let isLearned = viewModel.status(on: now) == .learned

        return Button {

            let currentDate = Date()

            // Register today's learning
            viewModel.logLearned(at: currentDate)
            now = currentDate

        } label: {

            Text(
                isLearned
                ? "Logged as Learned"
                : "Log as Learned"
            )
            .font(.system(size: 20, weight: .semibold))
            .foregroundStyle(
                canLog ? Color.white : Color.gray
            )
            .frame(width: 280, height: 280)
            .background {

                Circle()
                    .fill(
                        canLog
                        ? orange
                        : cardBackground
                    )
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
        .disabled(!canLog)
    }

    // Freeze button without Undo
    private var freezeButton: some View {

        let canFreeze = viewModel.canFreeze(at: now)
        let isFrozen = viewModel.status(on: now) == .frozen

        return Button {

            let currentDate = Date()

            // Register today's Freeze
            viewModel.logFreeze(at: currentDate)
            now = currentDate

        } label: {

            Text(
                isFrozen
                ? "Day Frozen"
                : "Freeze for a day"
            )
            .font(.system(size: 20))
            .foregroundStyle(
                canFreeze ? Color.white : Color.gray
            )
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background {

                Capsule()
                    .fill(
                        canFreeze
                        ? blue
                        : cardBackground
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
        .buttonStyle(.plain)
        .disabled(!canFreeze)
    }
}

#Preview {
    ActivityView()
}

