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
        .overlay {
            if viewModel.showUpdateAlert {
                ZStack {
                    // تعتيم الخلفية
                    Color.black.opacity(0.55)
                        .ignoresSafeArea()

                    VStack(alignment: .leading, spacing: 0) {

                        // عنوان التنبيه
                        Text("Update goal")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(.white)

                        // وصف التنبيه
                        Text("If you update now, your streak will start over.")
                            .font(.system(size: 20))
                            .foregroundStyle(Color.gray)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.top, 12)

                        // أزرار التنبيه
                        HStack(spacing: 8) {

                            Button {
                                viewModel.showUpdateAlert = false
                            } label: {
                                Text("Dismiss")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundStyle(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(width: 140, height: 60)
                                    .background(Color(red: 0.22, green: 0.22, blue: 0.24))
                                    .clipShape(Capsule())
                            }

                            Button {
                                if viewModel.confirmUpdate() {
                                    dismiss()
                                }
                            } label: {
                                Text("Update")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundStyle(.white)
                                    .frame(width: 140, height: 60)
                                    .background(Color("Accent Orange"))
                                    .clipShape(Capsule())
                            }
                        }
                        .padding(.top, 24)
                                        }
                    .padding(20)
                    .frame(width: 320)
                    .background(
                        RoundedRectangle(cornerRadius: 32)
                            .fill(Color(red: 0.11, green: 0.11, blue: 0.12))
                    )
                    .overlay {
                        RoundedRectangle(cornerRadius: 32)
                            .strokeBorder(Color.white.opacity(0.18), lineWidth: 1)
                    }
                }
                .zIndex(1)
            }
        }    }
}
