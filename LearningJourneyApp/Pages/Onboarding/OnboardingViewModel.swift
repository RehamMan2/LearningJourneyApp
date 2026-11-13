//
//  OnboardingViewModel.swift
//  LearningApp
//
//  Created by Reham Aljulayfi on 10/11/2026.
//

import Foundation

enum LearningDuration: String, CaseIterable, Identifiable {
    case week = "Week"
    case month = "Month"
    case year = "Year"

    var id: Self { self }
}

@Observable
class OnboardingViewModel {
    var learningTopic = ""
    var selectedDuration: LearningDuration = .week

    var canStart: Bool {
        !learningTopic.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func startLearning() {
        print("Topic: \(learningTopic)")
        print("Duration: \(selectedDuration.rawValue)")
    }
}
