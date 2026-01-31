//
//  sparkProjectApp.swift
//  sparkProject
//
//  Created by Azam Jawad on 2026-01-31.
//

import SwiftUI

@main
struct sparkProjectApp: App {
    @StateObject private var profileManager = UserProfileManager()
    
    var body: some Scene {
        WindowGroup {
            if profileManager.hasCompletedOnboarding() {
                MainTabView()
                    .environmentObject(profileManager)
            } else {
                OnboardingView()
                    .environmentObject(profileManager)
            }
        }
    }
}
