//
//  OnboardingView.swift
//  LearningApp
//
//  Created by Reham Aljulayfi on 10/11/2026.
//

import SwiftUI

struct OnboardingView: View {

    // ViewModel الخاص بالصفحة
    @State private var viewModel = OnboardingViewModel()

    // التحكم في الانتقال إلى Activity
    @State private var navigateToActivity = false

    var body: some View {

        NavigationStack {

            VStack(alignment: .center, spacing: 40) {

                // Icon
                Image(systemName: "flame.fill")
                    .font(.system(size: 45))
                    .foregroundStyle(Color("Accent Orange"))

                VStack(alignment: .leading) {

                    // Hello Title
                    HStack {

                        Text("Hello")
                            .fontWeight(.regular)
                            .font(.system(size: 40))

                        Text("Learner")
                            .fontWeight(.bold)
                            .font(.system(size: 40))
                    }

                    // Caption
                    Text("This app will help you learn everyday!")
                        .foregroundStyle(Color("Secondary Text"))

                    // Shared Learning Goal Form
                    LearningGoalForm(
                        learningTopic: $viewModel.learningTopic,
                        selectedDuration: $viewModel.selectedDuration,
                        durationTitle: { $0.rawValue }
                    )
                    .padding(.top, 16)

                    Spacer(minLength: 40)

                    // Start Button
                    VStack(spacing: 12) {

                        Buttons(
                            title: "Start Learning",
                            width: 180,
                            height: 52
                        ) {
                            viewModel.startLearning()
                            navigateToActivity = true
                        }
                        .disabled(!viewModel.canStart)
                        .opacity(viewModel.canStart ? 1 : 0.6)

                        Text("You can edit your desire later")
                            .font(.system(size: 12))
                            .foregroundStyle(.gray)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 24)
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .navigationDestination(
                isPresented: $navigateToActivity
            ) {
                ActivityView()
                    .navigationBarBackButtonHidden(true)
            }
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    OnboardingView()
}
