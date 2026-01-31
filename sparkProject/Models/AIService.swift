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
