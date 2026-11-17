//
//  OnboardingViewModel.swift
//  LearningApp
//
//  Created by Reham Aljulayfi on 10/11/2026.
//

import Foundation

@Observable
class OnboardingViewModel {

    // User input
    var learningTopic = ""
    var selectedDuration: LearningDuration = .week

    // Checks if the user entered a valid topic
    var canStart: Bool {
        !learningTopic.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    // Create and save the user's learning goal
    func startLearning() {

        let goal = LearningGoal(
            topic: learningTopic.trimmingCharacters(in: .whitespacesAndNewlines),
            duration: selectedDuration,
            startDate: Date()
        )

        // Share the goal with Activity
        ActivityViewModel.shared.setInitialGoal(goal)
    }}
