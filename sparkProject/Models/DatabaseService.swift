//
//  DatabaseService.swift
//  sparkProject
//
//  Created by Azam Jawad on 2026-01-31.
//

import Foundation

class DatabaseService {
    // Update this to your computer's IP address if testing on a real device
    // For simulator, localhost works. For real device, use your Mac's IP (e.g., "192.168.1.100")
    private let baseURL = "http://127.0.0.1:3000/api"
    
    func saveUser(_ profile: UserProfile) async throws -> Int {
        let url = URL(string: "\(baseURL)/users")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Map UserProfile to database fields
        let userData: [String: Any] = [
            "userName": profile.name,
            "age": String(profile.age),
            "height": profile.height,
            "weight": profile.weight,
            "sex": profile.gender,
            "medicalBackground": profile.medicalBackground,
            "chronicConditions": profile.chronicConditions,
            "currentMedications": profile.currentMedications,
            "hereditaryRiskPatterns": profile.hereditaryRiskPatterns,
            "wellnessCheckFrequency": "",
            "wellnessReport": ""
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: userData)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NSError(domain: "DatabaseService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
        }
        
        if httpResponse.statusCode == 200 || httpResponse.statusCode == 201 {
            // Parse response to get userId
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let userId = json["userId"] as? Int {
                return userId
            }
            return 0 // Success but no userId returned
        } else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw NSError(
                domain: "DatabaseService",
                code: httpResponse.statusCode,
                userInfo: [NSLocalizedDescriptionKey: "HTTP \(httpResponse.statusCode): \(errorMessage)"]
            )
        }
    }
    
    func updateUser(userId: Int, _ profile: UserProfile) async throws {
        let url = URL(string: "\(baseURL)/users/\(userId)")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let userData: [String: Any] = [
            "userName": profile.name,
            "age": String(profile.age),
            "height": profile.height,
            "weight": profile.weight,
            "sex": profile.gender,
            "medicalBackground": profile.medicalBackground,
            "chronicConditions": profile.chronicConditions,
            "currentMedications": profile.currentMedications,
            "hereditaryRiskPatterns": profile.hereditaryRiskPatterns
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: userData)
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NSError(domain: "DatabaseService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
        }
        
        if httpResponse.statusCode != 200 && httpResponse.statusCode != 204 {
            throw NSError(
                domain: "DatabaseService",
                code: httpResponse.statusCode,
                userInfo: [NSLocalizedDescriptionKey: "Failed to update user"]
            )
        }
    }
}
