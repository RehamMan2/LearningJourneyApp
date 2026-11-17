//
//  UpdateGoalViewModel.swift
//  LearningJourneyApp
//
//  Created by Reham Aljulayfi on 15/11/2026.
//


import Foundation
import Observation

@MainActor
@Observable
final class UpdateGoalViewModel {

    // مصدر بيانات التعلم المشترك
    private let activityViewModel: ActivityViewModel

    // القيم التي يعدل عليها المستخدم
    var learningTopic: String
    var selectedDuration: LearningDuration

    // التحكم في ظهور رسالة التأكيد
    var showUpdateAlert = false

    // إزالة المسافات الزائدة
    var trimmedTopic: String {
        learningTopic.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
    }

    // التأكد من أن موضوع التعلم غير فارغ
    var isValid: Bool {
        !trimmedTopic.isEmpty
    }

    // مقارنة القيم الجديدة بالقيم المحفوظة
    var hasChanges: Bool {
        trimmedTopic != activityViewModel.learningTopic
        || selectedDuration != activityViewModel.duration
    }

    // تحميل بيانات الهدف الحالية
    init(activityViewModel: ActivityViewModel) {
        self.activityViewModel = activityViewModel
        self.learningTopic = activityViewModel.learningTopic
        self.selectedDuration = activityViewModel.duration
    }

    // تحديد هل يجب إظهار رسالة التأكيد
    func requestUpdate() {
        guard isValid else {
            return
        }

        showUpdateAlert = hasChanges
    }

    // حفظ الهدف بعد موافقة المستخدم
    @discardableResult
    func confirmUpdate() -> Bool {
        guard isValid, hasChanges else {
            return false
        }

        let updated = activityViewModel.updateGoal(
            topic: trimmedTopic,
            duration: selectedDuration
        )

        if updated {
            showUpdateAlert = false
        }

        return updated
    }
}
