//
//  OnboardingView.swift
//  sparkProject
//
//  Created by Azam Jawad on 2026-01-31.
//

import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var profileManager: UserProfileManager
    @State private var currentStep = 0
    @State private var name = ""
    @State private var age = ""
    @State private var gender = "Male"
    @State private var height = ""
    @State private var weight = ""
    @State private var medicalBackground = ""
    @State private var chronicConditions = ""
    @State private var currentMedications = ""
    @State private var hereditaryRiskPatterns = ""
    
    let genders = ["Male", "Female"]
    
    // Total steps: Welcome (0), Demographics (1), Medical Background (2), Chronic Conditions (3), Medications (4), Hereditary (5), Review (6)
    private let totalSteps = 7
    
    var body: some View {
        ZStack {
            // Consistent background color
            Color.contentBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Progress indicator
                if currentStep > 0 {
                    ProgressView(value: Double(currentStep), total: Double(totalSteps - 1))
                        .progressViewStyle(LinearProgressViewStyle(tint: Color.buttonPrimary))
                        .padding(.horizontal, 30)
                        .padding(.top, 20)
                }
                
                // Content area
                VStack(spacing: 0) {
                    Group {
                        if currentStep == 0 {
                            WelcomeView(onNext: { currentStep = 1 })
                        } else if currentStep == 1 {
                            DemographicsView(
                                name: $name,
                                age: $age,
                                gender: $gender,
                                height: $height,
                                weight: $weight,
                                genders: genders,
                                onNext: { currentStep = 2 },
                                onBack: { currentStep = 0 }
                            )
                        } else if currentStep == 2 {
                            SingleQuestionView(
                                title: "Medical Background",
                                subtitle: "Tell us about your medical history",
                                text: $medicalBackground,
                                placeholder: "Enter any relevant medical background information...",
                                onNext: { currentStep = 3 },
                                onBack: { currentStep = 1 }
                            )
                        } else if currentStep == 3 {
                            SingleQuestionView(
                                title: "Chronic Conditions",
                                subtitle: "Do you have any chronic conditions?",
                                text: $chronicConditions,
                                placeholder: "List any chronic conditions you have...",
                                onNext: { currentStep = 4 },
                                onBack: { currentStep = 2 }
                            )
                        } else if currentStep == 4 {
                            SingleQuestionView(
                                title: "Current Medications",
                                subtitle: "What medications are you currently taking?",
                                text: $currentMedications,
                                placeholder: "List your current medications...",
                                onNext: { currentStep = 5 },
                                onBack: { currentStep = 3 }
                            )
                        } else if currentStep == 5 {
                            SingleQuestionView(
                                title: "Hereditary Risk Patterns",
                                subtitle: "Any family history or hereditary risks?",
                                text: $hereditaryRiskPatterns,
                                placeholder: "Describe any hereditary risk patterns...",
                                onNext: { currentStep = 6 },
                                onBack: { currentStep = 4 }
                            )
                        } else {
                            ReviewView(
                                name: name,
                                age: age,
                                gender: gender,
                                height: height,
                                weight: weight,
                                medicalBackground: medicalBackground,
                                chronicConditions: chronicConditions,
                                currentMedications: currentMedications,
                                hereditaryRiskPatterns: hereditaryRiskPatterns,
                                onComplete: completeOnboarding,
                                onBack: { currentStep = 5 }
                            )
                        }
                    }
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
                    .animation(.easeInOut(duration: 0.3), value: currentStep)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
    
    private func completeOnboarding() {
        let profile = UserProfile(
            name: name,
            age: Int(age) ?? 0,
            gender: gender,
            height: height,
            weight: weight,
            medicalBackground: medicalBackground,
            chronicConditions: chronicConditions,
            currentMedications: currentMedications,
            hereditaryRiskPatterns: hereditaryRiskPatterns
        )
        profileManager.saveProfile(profile)
    }
}

// MARK: - Welcome View
struct WelcomeView: View {
    let onNext: () -> Void
    
    var body: some View {
            VStack(spacing: 30) {
                Spacer()
                
                VStack(spacing: 20) {
                    Image(systemName: "heart.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.accentColor)
                
                Text("Welcome to Spark")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.textPrimary)
                
                Text("Let's create your personalized health profile")
                    .font(.system(size: 18))
                    .foregroundColor(.textPrimary.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Spacer()
            
            Button(action: onNext) {
                Text("Get Started")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.buttonPrimary)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 50)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.contentBackground)
    }
}

// MARK: - Demographics View
struct DemographicsView: View {
    @Binding var name: String
    @Binding var age: String
    @Binding var gender: String
    @Binding var height: String
    @Binding var weight: String
    let genders: [String]
    let onNext: () -> Void
    let onBack: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                VStack(spacing: 10) {
                    Text("Tell Us About Yourself")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.black)
                        .padding(.top, 40)
                    
                    Text("We'll start with some basic information")
                        .font(.system(size: 16))
                        .foregroundColor(.black.opacity(0.7))
                }
                
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Name")
                            .font(.headline)
                            .foregroundColor(.black)
                        TextField("Enter your name", text: $name)
                            .textFieldStyle(CustomTextFieldStyle())
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Age")
                            .font(.headline)
                            .foregroundColor(.black)
                        TextField("Enter your age", text: $age)
                            .keyboardType(.numberPad)
                            .textFieldStyle(CustomTextFieldStyle())
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Biological Sex")
                            .font(.headline)
                            .foregroundColor(.black)
                        Picker("Biological Sex", selection: $gender) {
                            ForEach(genders, id: \.self) { genderOption in
                                Text(genderOption).tag(genderOption)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .background(Color.white.opacity(0.5))
                        .cornerRadius(10)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Height")
                            .font(.headline)
                            .foregroundColor(.black)
                        TextField("e.g., 5'9\"", text: $height)
                            .textFieldStyle(CustomTextFieldStyle())
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Weight")
                            .font(.headline)
                            .foregroundColor(.black)
                        TextField("e.g., 160lbs", text: $weight)
                            .textFieldStyle(CustomTextFieldStyle())
                    }
                }
                .padding(30)
                .background(Color.cardBackground)
                .cornerRadius(20)
                .padding(.horizontal, 20)
                
                HStack(spacing: 15) {
                    Button(action: onBack) {
                        Text("Back")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray.opacity(0.5))
                            .cornerRadius(12)
                    }
                    
                    Button(action: {
                        if !name.isEmpty && !age.isEmpty && !height.isEmpty && !weight.isEmpty {
                            onNext()
                        }
                    }) {
                        Text("Continue")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(name.isEmpty || age.isEmpty || height.isEmpty || weight.isEmpty ?
                                       Color.gray.opacity(0.5) : Color.buttonPrimary)
                            .cornerRadius(12)
                    }
                    .disabled(name.isEmpty || age.isEmpty || height.isEmpty || weight.isEmpty)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.contentBackground)
    }
}

// MARK: - Single Question View
struct SingleQuestionView: View {
    let title: String
    let subtitle: String
    @Binding var text: String
    let placeholder: String
    let onNext: () -> Void
    let onBack: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                VStack(spacing: 10) {
                    Text(title)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.black)
                        .padding(.top, 40)
                    
                    Text(subtitle)
                        .font(.system(size: 18))
                        .foregroundColor(.black.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    ZStack(alignment: .topLeading) {
                        if text.isEmpty {
                            Text(placeholder)
                                .foregroundColor(.gray.opacity(0.5))
                                .padding(.horizontal, 5)
                                .padding(.vertical, 8)
                        }
                        TextEditor(text: $text)
                            .frame(minHeight: 200)
                            .scrollContentBackground(.hidden)
                    }
                    .padding(15)
                    .background(Color.white.opacity(0.9))
                    .cornerRadius(15)
                }
                .padding(.horizontal, 20)
                
                HStack(spacing: 15) {
                    Button(action: onBack) {
                        Text("Back")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray.opacity(0.5))
                            .cornerRadius(12)
                    }
                    
                    Button(action: onNext) {
                        Text("Continue")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.buttonPrimary)
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.contentBackground)
    }
}

// MARK: - Review View
struct ReviewView: View {
    let name: String
    let age: String
    let gender: String
    let height: String
    let weight: String
    let medicalBackground: String
    let chronicConditions: String
    let currentMedications: String
    let hereditaryRiskPatterns: String
    let onComplete: () -> Void
    let onBack: () -> Void
    
    private func formatWeight(_ weight: String) -> String {
        if weight.isEmpty {
            return ""
        }
        let lowerWeight = weight.lowercased()
        if lowerWeight.contains("lbs") || lowerWeight.contains("lb") {
            return weight
        }
        return "\(weight) lbs"
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                VStack(spacing: 10) {
                    Text("Review Your Information")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.black)
                        .padding(.top, 40)
                    
                    Text("Please review and confirm your details")
                        .font(.system(size: 16))
                        .foregroundColor(.black.opacity(0.7))
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Basic Information")
                        .font(.headline)
                        .foregroundColor(.black)
                    
                    // Combined rows for more compact display
                    HStack {
                        ReviewRow(label: "Name", value: name, compact: true)
                        ReviewRow(label: "Age", value: age, compact: true)
                    }
                    
                    HStack {
                        ReviewRow(label: "Biological Sex", value: gender, compact: true)
                        ReviewRow(label: "Height", value: height, compact: true)
                    }
                    
                    ReviewRow(label: "Weight", value: formatWeight(weight))
                    
                    Divider()
                        .background(Color.black.opacity(0.3))
                        .padding(.vertical, 8)
                    
                    Text("Medical Information")
                        .font(.headline)
                        .foregroundColor(.black)
                        .padding(.top, 4)
                    
                    ReviewRow(label: "Medical Background", value: medicalBackground.isEmpty ? "None" : medicalBackground)
                    ReviewRow(label: "Chronic Conditions", value: chronicConditions.isEmpty ? "None" : chronicConditions)
                    ReviewRow(label: "Current Medications", value: currentMedications.isEmpty ? "None" : currentMedications)
                    ReviewRow(label: "Hereditary Risk Patterns", value: hereditaryRiskPatterns.isEmpty ? "None" : hereditaryRiskPatterns)
                }
                .padding(20)
                .background(Color.cardBackground)
                .cornerRadius(20)
                .padding(.horizontal, 20)
                
                HStack(spacing: 15) {
                    Button(action: onBack) {
                        Text("Back")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray.opacity(0.5))
                            .cornerRadius(12)
                    }
                    
                    Button(action: onComplete) {
                        Text("Complete")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.buttonPrimary)
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.contentBackground)
    }
}

struct ReviewRow: View {
    let label: String
    let value: String
    var compact: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.black.opacity(0.7))
            Text(value)
                .font(.body)
                .foregroundColor(.black)
                .fontWeight(.medium)
        }
        .frame(maxWidth: compact ? .infinity : nil, alignment: .leading)
        .padding(.vertical, compact ? 4 : 8)
    }
}

struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color.white.opacity(0.9))
            .cornerRadius(10)
    }
}
