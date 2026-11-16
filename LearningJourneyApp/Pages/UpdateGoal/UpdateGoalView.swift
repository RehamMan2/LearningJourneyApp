//
//  UpdateGoalView.swift
//  LearningApp
//
//  Created by Reham Aljulayfi on 10/11/2026.
//



import SwiftUI

struct UpdateGoalView: View {

    // ViewModel الخاص بتعديل الهدف
    @State private var viewModel: UpdateGoalViewModel

    // الرجوع للصفحة السابقة
    @Environment(\.dismiss) private var dismiss

    // استقبال بيانات Activity الحالية
    init(activityViewModel: ActivityViewModel) {

        _viewModel = State(
            initialValue: UpdateGoalViewModel(
                activityViewModel: activityViewModel
            )
        )
    }

    var body: some View {

        VStack(alignment: .center, spacing: 40) {

            VStack(alignment: .leading) {

                // Header
                HStack {

                    // Back Button
                    Button {
                        dismiss()
                    } label: {

                        Image(systemName: "chevron.left")
                            .font(.system(size: 20))
                            .foregroundStyle(Color("Primary Text"))
                            .frame(width: 48, height: 48)
                            .background(
                                Circle()
                                    .fill(Color.white.opacity(0.12))
                            )
                    }

                    Spacer()

                    // Title
                    Text("Learning Goal")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Color("Primary Text"))

                    Spacer()

                    // Update Button
                    Button {

                        if viewModel.hasChanges {
                            viewModel.requestUpdate()
                        } else {
                            dismiss()
                        }

                    } label: {

                        Image(systemName: "checkmark")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(width: 48, height: 48)
                            .background(
                                Circle()
                                    .fill(Color("Accent Orange"))
                            )
                    }
                    .disabled(!viewModel.isValid)
                    .opacity(viewModel.isValid ? 1 : 0.6)
                }

                // Shared Learning Goal Form
                LearningGoalForm(
                    learningTopic: $viewModel.learningTopic,
                    selectedDuration: $viewModel.selectedDuration,
                    durationTitle: { $0.title }
                )
                .padding(.top, 40)

                Spacer(minLength: 40)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .preferredColorScheme(.dark)

        // Alert عند تغيير الهدف
        .alert(
            "Update goal",
            isPresented: $viewModel.showUpdateAlert
        ) {

            Button("Dismiss", role: .cancel) {
                viewModel.showUpdateAlert = false
            }

            Button("Update") {

                if viewModel.confirmUpdate() {
                    dismiss()
                }
            }

        } message: {

            Text("If you update now, your streak will start over.")
        }
    }
}
