//
//  SetGoalView.swift
//  LearningApp
//
//  Created by Reham Aljulayfi on 10/11/2026.
//

import SwiftUI

struct SetGoalView: View {

    // بيانات الهدف الجديد
    @State private var learningTopic = ""
    @State private var selectedDuration: LearningDuration = .week

    // تنفيذ الحفظ بواسطة الصفحة الأم
    var onSave: (String, LearningDuration) -> Void = { _, _ in }

    @Environment(\.dismiss) private var dismiss

    // التأكد من صحة الهدف
    private var canSave: Bool {
        LearningGoalFormViewModel.isValid(learningTopic)
    }

    var body: some View {

        VStack(alignment: .leading, spacing: 40) {

            // Header
            HStack {

                Button {
                    dismiss()
                } label: {

                    Image(systemName: "chevron.left")
                        .font(.system(size: 20))
                        .foregroundStyle(Color("Primary Text"))
                        .frame(width: 48, height: 48)
                }

                Spacer()

                Text("Set Learning Goal")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color("Primary Text"))

                Spacer()

                Color.clear
                    .frame(width: 48, height: 48)
            }

            // Shared Learning Goal Form
            LearningGoalForm(
                learningTopic: $learningTopic,
                selectedDuration: $selectedDuration,
                durationTitle: { $0.rawValue }
            )

            Spacer(minLength: 40)

            // Save Button
            Buttons(
                title: "Set Goal",
                width: 180,
                height: 52
            ) {

                let topic = LearningGoalFormViewModel.cleanTopic(
                    learningTopic
                )

                onSave(topic, selectedDuration)
                dismiss()
            }
            .disabled(!canSave)
            .opacity(canSave ? 1 : 0.6)
            .frame(maxWidth: .infinity)
            .padding(.bottom, 24)
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .toolbar(.hidden, for: .navigationBar)
        .preferredColorScheme(.dark)
    }
}

#Preview {
    SetGoalView()
}
