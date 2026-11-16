//
//  LearningDay.swift
//  LearningJourneyApp
//
//  Created by Reham Aljulayfi on 13/11/2026.
//


import Foundation

// Represents the learning status of a day.
enum LearningDayStatus: String, Codable {
    case learned
    case freeze
}

// Stores a recorded learning day.
struct LearningDay: Codable, Identifiable {
    var date: Date
    var status: LearningDayStatus

    var id: Date {
        Calendar.current.startOfDay(for: date)
    }
}

