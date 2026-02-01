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
    
    func updateWellnessReport(userId: Int, report: String) async throws {
        let url = URL(string: "\(baseURL)/users/\(userId)/wellness-report")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let reportData: [String: Any] = [
            "wellnessReport": report
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: reportData)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NSError(domain: "DatabaseService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
        }
        
        if httpResponse.statusCode != 200 && httpResponse.statusCode != 204 {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            print("❌ Wellness report update failed - Status: \(httpResponse.statusCode), Error: \(errorMessage)")
            throw NSError(
                domain: "DatabaseService",
                code: httpResponse.statusCode,
                userInfo: [NSLocalizedDescriptionKey: "HTTP \(httpResponse.statusCode): \(errorMessage)"]
            )
        }
        
        print("✅ Wellness report updated successfully for user \(userId)")
    }
    
    func updateWellnessCheckFrequency(userId: Int, frequency: Int) async throws {
        let url = URL(string: "\(baseURL)/users/\(userId)/wellness-frequency")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let frequencyData: [String: Any] = [
            "wellnessCheckFrequency": String(frequency)
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: frequencyData)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NSError(domain: "DatabaseService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
        }
        
        if httpResponse.statusCode != 200 && httpResponse.statusCode != 204 {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            print("❌ Wellness frequency update failed - Status: \(httpResponse.statusCode), Error: \(errorMessage)")
            throw NSError(
                domain: "DatabaseService",
                code: httpResponse.statusCode,
                userInfo: [NSLocalizedDescriptionKey: "HTTP \(httpResponse.statusCode): \(errorMessage)"]
            )
        }
        
        print("✅ Wellness check frequency updated successfully for user \(userId)")
    }
    
    func getUserData(userId: Int) async throws -> UserHealthData {
        let url = URL(string: "\(baseURL)/users/\(userId)")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NSError(domain: "DatabaseService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
        }
        
        if httpResponse.statusCode == 200 {
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let user = json["user"] as? [String: Any] {
                return UserHealthData(
                    age: user["age"] as? String ?? "",
                    sex: user["sex"] as? String ?? "",
                    height: user["height"] as? String ?? "",
                    weight: user["weight"] as? String ?? "",
                    medicalBackground: user["medicalBackground"] as? String ?? "",
                    chronicConditions: user["chronicConditions"] as? String ?? "",
                    currentMedications: user["currentMedications"] as? String ?? "",
                    hereditaryRiskPatterns: user["hereditaryRiskPatterns"] as? String ?? ""
                )
            }
            throw NSError(domain: "DatabaseService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to parse user data"])
        } else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw NSError(
                domain: "DatabaseService",
                code: httpResponse.statusCode,
                userInfo: [NSLocalizedDescriptionKey: "HTTP \(httpResponse.statusCode): \(errorMessage)"]
            )
        }
    }
    
    func getWellnessCheckFrequency(userId: Int) async throws -> Int {
        let url = URL(string: "\(baseURL)/users/\(userId)")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NSError(domain: "DatabaseService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
        }
        
        if httpResponse.statusCode == 200 {
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let user = json["user"] as? [String: Any],
               let frequencyString = user["wellnessCheckFrequency"] as? String,
               !frequencyString.isEmpty,
               let frequency = Int(frequencyString) {
                return frequency
            }
            // Default to 30 days if not set
            return 30
        } else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw NSError(
                domain: "DatabaseService",
                code: httpResponse.statusCode,
                userInfo: [NSLocalizedDescriptionKey: "HTTP \(httpResponse.statusCode): \(errorMessage)"]
            )
        }
    }
}

struct UserHealthData {
    let age: String
    let sex: String
    let height: String
    let weight: String
    let medicalBackground: String
    let chronicConditions: String
    let currentMedications: String
    let hereditaryRiskPatterns: String
    
    func formattedContext() -> String {
        var context = "Patient Health Profile (anonymized):\n"
        
        if !age.isEmpty {
            context += "- Age: \(age)\n"
        }
        if !sex.isEmpty {
            context += "- Biological Sex: \(sex)\n"
        }
        if !height.isEmpty {
            context += "- Height: \(height)\n"
        }
        if !weight.isEmpty {
            context += "- Weight: \(weight)\n"
        }
        if !medicalBackground.isEmpty {
            context += "- Medical Background: \(medicalBackground)\n"
        }
        if !chronicConditions.isEmpty {
            context += "- Chronic Conditions: \(chronicConditions)\n"
        }
        if !currentMedications.isEmpty {
            context += "- Current Medications: \(currentMedications)\n"
        }
        if !hereditaryRiskPatterns.isEmpty {
            context += "- Hereditary Risk Patterns: \(hereditaryRiskPatterns)\n"
        }
        
        return context
    }
}
