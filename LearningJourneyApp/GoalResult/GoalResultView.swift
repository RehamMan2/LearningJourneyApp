//
//  GoalResultView.swift
//  LearningJourneyApp
//
//  Created by Reham Aljulayfi on 17/11/2026.
//


import SwiftUI

struct GoalResultView: View {

    let result: GoalResult
    let activityViewModel: ActivityViewModel
    let now: Date
    let onSetGoal: () -> Void

    // Colors from Assets
    private let orange = Color("Accent Orange")
    private let blue = Color("Accent Blue")
    private let primaryText = Color("Primary Text")
    private let secondaryText = Color("Secondary Text")

    // Result ViewModel
    private var viewModel: GoalResultViewModel {
        GoalResultViewModel(result: result)
    }

    var body: some View {

        GeometryReader { geometry in

            ScrollView {

                VStack(spacing: 0) {

                    // Activity calendar
                    ActivityCalendar(
                        viewModel: activityViewModel,
                        now: now
                    )
                    .padding(.top, 24)

                    // Progress cards
                    HStack(spacing: 12) {

                        ProgressCard(
                            icon: "flame.fill",
                            count: activityViewModel.streak(at: now),
                            title: "Learned",
                            color: orange
                        )

                        ProgressCard(
                            icon: "snowflake",
                            count: activityViewModel.usedFreezes(at: now),
                            title: "Freezed",
                            color: blue
                        )
                    }
                    .padding(.top, 16)

                    Color.clear
                        .frame(height: 64)

                    // Result icon
                    Image(systemName: viewModel.icon)
                        .font(.system(size: 56))
                        .foregroundStyle(orange)

                    // Result messages
                    VStack(spacing: 12) {

                        Text(viewModel.title)
                            .font(
                                .system(
                                    size: 24,
                                    weight: .semibold
                                )
                            )
                            .foregroundStyle(primaryText)

                        Text(viewModel.subtitle)
                            .font(.system(size: 16))
                            .foregroundStyle(secondaryText)
                    }
                    .multilineTextAlignment(.center)
                    .padding(.top, 24)

                    Color.clear
                        .frame(height: 48)

                    // Navigate to SetGoalView
                    Buttons(
                        title: "Set a goal",
                        width: 180,
                        height: 52
                    ) {
                        onSetGoal()
                    }

                    Spacer(minLength: 32)
                }
                .padding(.horizontal, 20)
                .frame(
                    minHeight: geometry.size.height,
                    alignment: .top
                )
            }
        }
        .background(.black)
    }
}


#Preview("Goal Not Met") {
    GoalResultView(
        result: .notMet,
        activityViewModel: ActivityViewModel.shared,
        now: Date(),
        onSetGoal: {}
    )
    .preferredColorScheme(.dark)
}
