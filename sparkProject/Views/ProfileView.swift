//
//  ProfileView.swift
//  sparkProject
//
//  Created by Azam Jawad on 2026-01-31.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var profileManager: UserProfileManager
    
    var body: some View {
        ZStack {
            // Dark background
            Color.appBackground
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        Text("Profile Page")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.eggshell)
                            .padding(.leading, 20)
                            .padding(.top, 10)
                        
                        Spacer()
                        
                        // Hamburger menu
                        Button(action: {}) {
                            Image(systemName: "line.horizontal.3")
                                .font(.title2)
                                .foregroundColor(.eggshell)
                                .padding(.trailing, 20)
                                .padding(.top, 10)
                        }
                    }
                    .padding(.bottom, 20)
                    
                    // Main content area
                    VStack(spacing: 0) {
                        // Profile picture and basic info
                        VStack(spacing: 15) {
                            // Profile picture
                            if let profile = profileManager.userProfile {
                                Image("profile")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 120, height: 120)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.eggshell, lineWidth: 3))
                                    .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
                                    .padding(.top, 30)
                                
                                // Name
                                Text(profile.name)
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(.textPrimary)
                                
                                // Gender and Age
                                Text("\(profile.gender), \(profile.age)")
                                    .font(.system(size: 16))
                                    .foregroundColor(.textPrimary)
                            }
                        }
                        .padding(.bottom, 30)
                        
                        // Physical Attributes Card
                        VStack(spacing: 0) {
                            PhysicalAttributeRow(label: "Height", value: profileManager.userProfile?.height ?? "N/A")
                            
                            Divider()
                                .background(Color.textPrimary.opacity(0.3))
                            
                            PhysicalAttributeRow(label: "Weight", value: profileManager.userProfile?.weight ?? "N/A")
                        }
                        .padding(20)
                        .background(Color.cardBackground)
                        .cornerRadius(15)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                        
                        // Medical Information Section
                        VStack(spacing: 0) {
                            MedicalInfoRow(title: "Medical Background")
                            Divider()
                                .background(Color.textPrimary.opacity(0.3))
                            MedicalInfoRow(title: "Chronic Conditions")
                            Divider()
                                .background(Color.textPrimary.opacity(0.3))
                            MedicalInfoRow(title: "Current Medications")
                            Divider()
                                .background(Color.textPrimary.opacity(0.3))
                            MedicalInfoRow(title: "Hereditary Risk Patterns")
                        }
                        .padding(20)
                        .background(Color.cardBackground)
                        .cornerRadius(15)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                        
                        // Bottom button placeholder
                        Rectangle()
                            .fill(Color.buttonPrimary)
                            .frame(height: 50)
                            .cornerRadius(12)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 30)
                    }
                    .background(Color.contentBackground)
                    .cornerRadius(25)
                    .padding(.horizontal, 15)
                    .padding(.top, 10)
                }
            }
        }
    }
}

struct PhysicalAttributeRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.textPrimary)
            Spacer()
            Text(value)
                .font(.body)
                .foregroundColor(.textPrimary)
        }
        .padding(.vertical, 12)
    }
}

struct MedicalInfoRow: View {
    let title: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.textPrimary)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.textPrimary)
        }
        .padding(.vertical, 15)
    }
}
