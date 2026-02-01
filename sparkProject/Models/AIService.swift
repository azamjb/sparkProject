//
//  AIService.swift
//  sparkProject
//
//  Created by Azam Jawad on 2026-01-31.
//

import Foundation

class AIService {
    private let apiKey: String
    private let baseURL = "https://api.openai.com/v1/chat/completions"
    
    init(apiKey: String) {
        // Trim whitespace and newlines from API key
        self.apiKey = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func sendMessage(
        userMessage: String,
        conversationHistory: [ChatMessage],
        systemPrompt: String
    ) async throws -> String {
        // Build messages array
        var messages: [[String: String]] = [
            ["role": "system", "content": systemPrompt]
        ]
        
        // Add conversation history (last 10 messages to keep context manageable)
        let recentHistory = Array(conversationHistory.suffix(10))
        for message in recentHistory {
            messages.append([
                "role": message.isFromUser ? "user" : "assistant",
                "content": message.content
            ])
        }
        
        // Add current user message
        messages.append(["role": "user", "content": userMessage])
        
        // Create request body
        let requestBody: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": messages,
            "temperature": 0.7,
            "max_tokens": 500
        ]
        
        #if DEBUG
        print("📤 Sending request to OpenAI API")
        print("📝 Messages count: \(messages.count)")
        #endif
        
        // Make API call
        guard let url = URL(string: baseURL) else {
            throw NSError(domain: "Invalid URL", code: 0)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // Ensure API key is properly trimmed
        let cleanApiKey = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        request.setValue("Bearer \(cleanApiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 30 // 30 second timeout
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        // Debug: Log first and last few characters of key (for debugging without exposing full key)
        #if DEBUG
        print("🔑 API Key check - Length: \(cleanApiKey.count), Starts with: \(cleanApiKey.prefix(10))")
        #endif
        
        // Create URLSession with proper configuration
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 30
        let session = URLSession(configuration: config)
        
        let (data, response) = try await session.data(for: request)
        
        // Check for HTTP errors
        if let httpResponse = response as? HTTPURLResponse {
            #if DEBUG
            print("📡 HTTP Status: \(httpResponse.statusCode)")
            #endif
            
            if httpResponse.statusCode != 200 {
                // Try to parse OpenAI error response
                if let errorResponse = try? JSONDecoder().decode(OpenAIErrorResponse.self, from: data) {
                    #if DEBUG
                    print("❌ OpenAI Error: \(errorResponse.error.message)")
                    #endif
                    throw NSError(
                        domain: "OpenAI API Error",
                        code: httpResponse.statusCode,
                        userInfo: [NSLocalizedDescriptionKey: errorResponse.error.message]
                    )
                } else {
                    // Fallback error message
                    let errorString = String(data: data, encoding: .utf8) ?? "Unknown error"
                    #if DEBUG
                    print("❌ Raw Error Response: \(errorString)")
                    #endif
                    throw NSError(
                        domain: "API Error",
                        code: httpResponse.statusCode,
                        userInfo: [NSLocalizedDescriptionKey: "HTTP \(httpResponse.statusCode): \(errorString)"]
                    )
                }
            }
        }
        
        let aiResponse = try JSONDecoder().decode(OpenAIResponse.self, from: data)
        return aiResponse.choices.first?.message.content ?? "I'm sorry, I couldn't process that."
    }
    
    func generateWellnessCheckFrequency(for profile: UserProfile) async throws -> Int {
        let userContext = """
        Patient Demographics and Health Profile:
        - Age: \(profile.age)
        - Biological Sex: \(profile.gender)
        - Height: \(profile.height)
        - Weight: \(profile.weight)
        - Medical Background: \(profile.medicalBackground.isEmpty ? "None" : profile.medicalBackground)
        - Chronic Conditions: \(profile.chronicConditions.isEmpty ? "None" : profile.chronicConditions)
        - Current Medications: \(profile.currentMedications.isEmpty ? "None" : profile.currentMedications)
        - Hereditary Risk Patterns: \(profile.hereditaryRiskPatterns.isEmpty ? "None" : profile.hereditaryRiskPatterns)
        """
        
        let systemPrompt = """
        You are a healthcare professional determining the recommended wellness check frequency for a patient.
        
        Based on the patient's demographics, medical history, chronic conditions, medications, and hereditary risk patterns, recommend how often (in days) they should complete a wellness check.
        
        CRITICAL: You must respond with ONLY a number representing days. The number must be one of these exact values:
        - 1 (for daily checks - high-risk patients, elderly with serious conditions, etc.)
        - 2 (for every 2 days - moderate-high risk)
        - 7 (for weekly checks - moderate risk or ongoing monitoring)
        - 14 (for bi-weekly checks - low-moderate risk)
        - 30 (for monthly checks - healthy individuals with minimal risk factors)
        
        Guidelines:
        - Elderly patients (80+) with serious conditions (dementia, heart disease, etc.): 1 day
        - Elderly patients (65-79) with chronic conditions: 2-7 days
        - Middle-aged (40-64) with chronic conditions: 7-14 days
        - Young adults (18-39) with chronic conditions: 14-30 days
        - Healthy individuals with no significant medical issues: 30 days
        - Consider severity of conditions, medication complexity, and hereditary risks
        
        Respond with ONLY the number (1, 2, 7, 14, or 30). No explanation, no text, just the number.
        """
        
        // Build messages for frequency generation
        var messages: [[String: String]] = [
            ["role": "system", "content": systemPrompt],
            ["role": "user", "content": userContext]
        ]
        
        // Create request body with lower temperature for more consistent output
        let requestBody: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": messages,
            "temperature": 0.3, // Lower temperature for more consistent number output
            "max_tokens": 10 // Only need a number, very short response
        ]
        
        guard let url = URL(string: baseURL) else {
            throw NSError(domain: "Invalid URL", code: 0)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let cleanApiKey = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        request.setValue("Bearer \(cleanApiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 30
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 30
        let session = URLSession(configuration: config)
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw NSError(domain: "API Error", code: (response as? HTTPURLResponse)?.statusCode ?? 0)
        }
        
        let aiResponse = try JSONDecoder().decode(OpenAIResponse.self, from: data)
        let responseText = aiResponse.choices.first?.message.content ?? "30"
        
        // Parse the response to get the number
        let cleaned = responseText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Extract number from response (in case AI adds extra text)
        let numbers = cleaned.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        
        if let frequency = Int(numbers) {
            // Round to nearest allowed value
            let allowedValues = [1, 2, 7, 14, 30]
            let closest = allowedValues.min(by: { abs($0 - frequency) < abs($1 - frequency) }) ?? 30
            print("📊 AI recommended frequency: \(frequency) days, rounded to: \(closest) days")
            return closest
        }
        
        // Default to 30 days if parsing fails
        print("⚠️ Could not parse frequency from AI response: \(responseText). Defaulting to 30 days.")
        return 30
    }
}

struct OpenAIResponse: Codable {
    let choices: [Choice]
    
    struct Choice: Codable {
        let message: Message
        
        struct Message: Codable {
            let content: String
        }
    }
}

struct OpenAIErrorResponse: Codable {
    let error: ErrorDetail
    
    struct ErrorDetail: Codable {
        let message: String
        let type: String?
        let code: String?
    }
}
