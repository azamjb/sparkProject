//
//  ChatMessage.swift
//  sparkProject
//
//  Created by Azam Jawad on 2026-01-31.
//

import Foundation

struct ChatMessage: Identifiable {
    let id = UUID()
    let content: String
    let isFromUser: Bool
    let timestamp: Date
    
    init(content: String, isFromUser: Bool, timestamp: Date = Date()) {
        self.content = content
        self.isFromUser = isFromUser
        self.timestamp = timestamp
    }
}
