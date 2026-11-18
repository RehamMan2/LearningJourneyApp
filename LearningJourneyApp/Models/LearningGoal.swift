//
//  LearningGoal.swift
//  LearningJourneyApp
//
//  Created by Reham Aljulayfi on 13/11/2026.
//


import Foundation

// Represents a learning goal.
struct LearningGoal: Codable, Identifiable {

    // Unique identifier for the goal.
    var id: UUID = UUID()

    // Learning topic.
    var topic: String

    // Selected learning duration.
    var duration: LearningDuration

    // Date when the goal started.
    var startDate: Date

    // Date when the goal ended.
    var endDate: Date? = nil
}

