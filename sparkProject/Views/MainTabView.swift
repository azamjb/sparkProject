//
//  MainTabView.swift
//  sparkProject
//
//  Created by Azam Jawad on 2026-01-31.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var profileManager: UserProfileManager
    
    var body: some View {
        TabView {
            ProfileView()
                .tabItem {
                    Image(systemName: "person.circle")
                    Text("Profile")
                }
            
            AppointmentView()
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Appointments")
                }
            
            WellnessCheckView()
                .tabItem {
                    Image(systemName: "heart.circle")
                    Text("Wellness Check")
                }
        }
    }
}

struct AppointmentView: View {
    var body: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("Appointments")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.textPrimary)
                    .padding(.top, 40)
                
                Text("Coming soon...")
                    .font(.system(size: 18))
                    .foregroundColor(.textPrimary.opacity(0.7))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.contentBackground)
        }
    }
}

struct WellnessCheckView: View {
    var body: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("Wellness Check")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.textPrimary)
                    .padding(.top, 40)
                
                Text("Coming soon...")
                    .font(.system(size: 18))
                    .foregroundColor(.textPrimary.opacity(0.7))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.contentBackground)
        }
    }
}
