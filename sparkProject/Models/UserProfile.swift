//
//  UserProfile.swift
//  sparkProject
//
//  Created by Azam Jawad on 2026-01-31.
//

import Foundation
import Combine

struct UserProfile: Codable {
    var name: String
    var age: Int
    var gender: String
    var height: String // e.g., "5'9""
    var weight: String // e.g., "160lbs"
    var medicalBackground: String
    var chronicConditions: String
    var currentMedications: String
    var hereditaryRiskPatterns: String
    var profileImageName: String? // For storing profile image
    
    var hasCompletedOnboarding: Bool {
        return !name.isEmpty && age > 0 && !height.isEmpty && !weight.isEmpty
    }
}

class UserProfileManager: ObservableObject {
    @Published var userProfile: UserProfile?
    
    private let userDefaultsKey = "userProfile"
    
    init() {
        loadProfile()
    }
    
    func saveProfile(_ profile: UserProfile) {
        self.userProfile = profile
        if let encoded = try? JSONEncoder().encode(profile) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }
    
    func loadProfile() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let profile = try? JSONDecoder().decode(UserProfile.self, from: data) {
            self.userProfile = profile
        }
    }
    
    func hasCompletedOnboarding() -> Bool {
        return userProfile?.hasCompletedOnboarding ?? false
    }
    
    func clearProfile() {
        self.userProfile = nil
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
    }
}
