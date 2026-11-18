//
//  LearningJourneyAppApp.swift
//  LearningJourneyApp
//
//  Created by Reham Aljulayfi on 13/11/2026.
//

import SwiftUI

@main
struct LearningJourneyAppApp: App {

    @State private var viewModel = ActivityViewModel.shared

    var body: some Scene {
        WindowGroup {
            if viewModel.hasLearningGoal {
                ActivityView()
            } else {
                OnboardingView()
            }
        }
    }
}
