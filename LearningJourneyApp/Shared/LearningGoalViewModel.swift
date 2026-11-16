//
//  LearningGoalViewModel.swift
//  LearningJourneyApp
//
//  Created by Reham Aljulayfi on 13/11/2026.
//

import Foundation

struct LearningGoalFormViewModel {

    // إزالة المسافات الزائدة من بداية ونهاية الهدف
    static func cleanTopic(_ topic: String) -> String {
        topic.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // التأكد من إدخال هدف صالح
    static func isValid(_ topic: String) -> Bool {
        !cleanTopic(topic).isEmpty
    }
}
