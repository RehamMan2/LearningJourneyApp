//
//  LearningPeriod.swift
//  LearningJourneyApp
//
//  Created by Reham Aljulayfi on 13/11/2026.
//

import Foundation

// Available learning durations
enum LearningDuration: String, Codable, CaseIterable, Identifiable {

    case week = "Week"
    case month = "Month"
    case year = "Year"

    var id: Self { self }
    
    // Display title for each duration
        var title: String {
            rawValue
        }

    // Freeze allowance based on selected duration
    var freezeLimit: Int {
        switch self {
        case .week: return 2
        case .month: return 8
        case .year: return 96
        }
    }
}
