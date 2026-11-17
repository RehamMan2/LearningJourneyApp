//
//  LearningGoalForm.swift
//  LearningJourneyApp
//
//  Created by Reham Aljulayfi on 13/11/2026.
//

import SwiftUI

struct LearningGoalForm<Duration: Hashable & CaseIterable>: View {

    // البيانات المرتبطة بالصفحة الأم
    @Binding var learningTopic: String
    @Binding var selectedDuration: Duration

    // طريقة عرض اسم كل مدة
    let durationTitle: (Duration) -> String

    // التحكم في لوحة المفاتيح
    @FocusState private var isTopicFocused: Bool

    var body: some View {

        VStack(alignment: .leading, spacing: 16) {

            // Learning Topic
            Text("I want to learn")
                .foregroundStyle(Color("Primary Text"))

            TextField("Swift", text: $learningTopic)
                .font(.system(size: 18))
                .tint(Color("Accent Orange"))
                .autocorrectionDisabled()
                .textInputAutocapitalization(.sentences)
                .focused($isTopicFocused)
                .submitLabel(.done)
                .onSubmit {
                    isTopicFocused = false
                }

            Rectangle()
                .fill(Color.gray.opacity(0.25))
                .frame(height: 1)

            // Duration Selection
            VStack(alignment: .leading, spacing: 16) {

                Text("I want to learn it in a")
                    .font(.system(size: 18))
                    .foregroundStyle(Color("Primary Text"))

                HStack(spacing: 12) {

                    ForEach(
                        Array(Duration.allCases),
                        id: \.self
                    ) { duration in

                        Buttons(
                            title: durationTitle(duration),
                            isSelected: selectedDuration == duration,
                            width: 65,
                            height: 40,
                        ) {
                            selectedDuration = duration
                        }
                    }
                }
            }
            .padding(.top, 16)
        }
    }
}
