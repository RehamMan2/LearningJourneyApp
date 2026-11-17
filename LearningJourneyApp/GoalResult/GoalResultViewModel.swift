//
//  GoalResultViewModel.swift
//  LearningJourneyApp
//
//  Created by Reham Aljulayfi on 17/11/2026.
//


import SwiftUI
import Observation

// Possible goal results
enum GoalResult {
    case completed
    case notMet
}

@Observable
final class GoalResultViewModel {

    let result: GoalResult

    init(result: GoalResult) {
        self.result = result
    }

    // Result title
    var title: String {

        switch result {
        case .completed:
            return "Well done!"

        case .notMet:
            return "You didn't reach your goal this time."
        }
    }

    // Result subtitle
    var subtitle: String {

        switch result {
        case .completed:
            return "Ready for your next goal?"

        case .notMet:
            return "Want to set another goal?"
        }
    }

    // Result icon
    var icon: String {

        switch result {
        case .completed:
            return "hands.clap.fill"

        case .notMet:
            return "xmark.circle.fill"
        }
    }
}
