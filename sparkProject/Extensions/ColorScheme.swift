//
//  ColorScheme.swift
//  sparkProject
//
//  Created by Azam Jawad on 2026-01-31.
//

import SwiftUI

extension Color {
    // Color Palette
    static let eggshell = Color(red: 250/255, green: 243/255, blue: 221/255) // #FAF3DD
    static let teaGreen = Color(red: 200/255, green: 213/255, blue: 185/255) // #C8D5B9
    static let mutedTeal = Color(red: 143/255, green: 192/255, blue: 169/255) // #8FC0A9
    static let tropicalTeal = Color(red: 104/255, green: 176/255, blue: 171/255) // #68B0AB
    static let jungleTeal = Color(red: 74/255, green: 124/255, blue: 89/255) // #4A7C59
    
    // Semantic colors
    static let appBackground = Color.jungleTeal // Dark background
    static let contentBackground = Color.mutedTeal // Main content area
    static let cardBackground = Color.eggshell // Cards
    static let textPrimary = Color.jungleTeal // Primary text
    static let buttonPrimary = Color.tropicalTeal // Primary buttons
    static let accentColor = Color.tropicalTeal // Accents
}
