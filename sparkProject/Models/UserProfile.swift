//
//  UserProfile.swift
//  sparkProject
//
//  Created by Azam Jawad on 2026-01-31.
//

import Foundation
import Combine

struct UserProfile: Codable {
    var userId: Int? // Database user ID
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
    private let databaseService = DatabaseService()
    
    init() {
        loadProfile()
    }
    
    func saveProfile(_ profile: UserProfile) {
        self.userProfile = profile
        
        // Save to UserDefaults for local storage
        if let encoded = try? JSONEncoder().encode(profile) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
        
        // Save to MySQL database
        Task {
            do {
                if let userId = profile.userId {
                    // Update existing user
                    try await databaseService.updateUser(userId: userId, profile)
                    print("✅ User updated in database")
                } else {
                    // Create new user
                    let userId = try await databaseService.saveUser(profile)
                    var updatedProfile = profile
                    updatedProfile.userId = userId
                    
                    await MainActor.run {
                        self.userProfile = updatedProfile
                        // Update UserDefaults with userId
                        if let encoded = try? JSONEncoder().encode(updatedProfile) {
                            UserDefaults.standard.set(encoded, forKey: self.userDefaultsKey)
                        }
                    }
                    print("✅ User saved to database with ID: \(userId)")
                }
            } catch {
                print("❌ Error saving to database: \(error.localizedDescription)")
                // Continue anyway - local storage still works
            }
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
