//
//  OnboardingView.swift
//  LearningApp
//
//  Created by Reham Aljulayfi on 10/11/2026.
//

import SwiftUI

struct OnboardingView: View {
    
    @State private var viewModel = OnboardingViewModel()
    @State private var navigateToActivity = false
    
    
    var body: some View {
        
        NavigationStack{
            
            VStack (alignment: .center, spacing: 40){
                
                //ICON
                Image(systemName: "flame.fill")
                    .font(.system(size: 45))
                    .foregroundStyle(Color("Accent Orange"))
                
                
                VStack (alignment: .leading) {
                    
                    //HELLO TITLE
                    HStack {
                        Text("Hello")
                            .fontWeight(.regular)
                            .font(.system(size: 40))
                        
                        Text("Learner")
                            .fontWeight(.bold)
                            .font(.system(size: 40))
                        
                    }
                    
                    //Caption
                    Text("This app will help you learn everyday!")
                        .foregroundStyle(Color("Secondary Text"))
                    
                    
                    
                    //I WANT
                    Text("I want to learn")
                        .foregroundStyle(Color("Primary Text"))
                        .padding(.top)
                    
                    TextField("Swift", text: $viewModel.learningTopic)
                        .font(.system(size: 18))
                        .tint(Color("Accent Orange"))
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.sentences)
                    
                    Rectangle()
                        .fill(Color.gray.opacity(0.25))
                        .frame(height: 1)
                    
                    // Duration
                    VStack(alignment: .leading, spacing: 16) {
                        Text("I want to learn it in a")
                            .font(.system(size: 16))
                        HStack(spacing: 12) {
                            ForEach(LearningDuration.allCases) { duration in
                                Buttons(
                                    title: duration.rawValue,
                                    isSelected: viewModel.selectedDuration == duration,
                                    height: 48
                                ) {
                                    viewModel.selectedDuration = duration
                                }
                            }
                        }
                    }
                    .padding(.top)
                    
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
                        .navigationDestination(isPresented: $navigateToActivity) {
                            ActivityView()
                                .navigationBarBackButtonHidden(true)
                        }
                    
                    
                    
                    
                }.padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
            }
        }
        
        .preferredColorScheme(.dark)
    }
}

#Preview {
    OnboardingView()
}
