//
//  MainTabView.swift
//  sparkProject
//
//  Created by Azam Jawad on 2026-01-31.
//

import SwiftUI
import UIKit

struct MainTabView: View {
    @EnvironmentObject var profileManager: UserProfileManager
    @State private var tabSelection = 0

    init() {
        setupTabBarAppearance()
    }

    private func setupTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()

        appearance.backgroundEffect = nil
        appearance.backgroundColor = UIColor(Color.contentBackground)

        appearance.shadowColor = .clear
        appearance.shadowImage = UIImage()

        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(Color.buttonPrimary)
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor(Color.buttonPrimary),
            .font: UIFont.systemFont(ofSize: 11, weight: .medium)
        ]

        appearance.stackedLayoutAppearance.normal.iconColor = UIColor(Color.textPrimary.opacity(0.5))
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor(Color.textPrimary.opacity(0.5)),
            .font: UIFont.systemFont(ofSize: 11, weight: .regular)
        ]

        appearance.selectionIndicatorTintColor = .clear
        appearance.selectionIndicatorImage = UIImage()

        let tabBar = UITabBar.appearance()
        tabBar.standardAppearance = appearance
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = appearance
        }

        tabBar.isTranslucent = false
        tabBar.backgroundImage = UIImage()
        tabBar.shadowImage = UIImage()
        tabBar.backgroundColor = UIColor(Color.contentBackground)
        tabBar.barTintColor = UIColor(Color.contentBackground)

        tabBar.layer.borderWidth = 0.5
        tabBar.layer.borderColor = UIColor(Color.textPrimary.opacity(0.08)).cgColor
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.contentBackground.ignoresSafeArea()

                // Content views
                Group {
                    if tabSelection == 0 {
                        AppointmentView()
                    } else if tabSelection == 1 {
                        ProfileView()
                    } else {
                        WellnessCheckView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .transaction { txn in
                    txn.animation = nil
                }

                // Custom Tab Bar
                VStack {
                    Spacer()
                    CustomTabBar(selectedTab: $tabSelection)
                }
                .ignoresSafeArea(edges: .bottom)
            }
        }
    }
}

// MARK: - Custom Tab Bar
struct CustomTabBar: View {
    @Binding var selectedTab: Int
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                TabBarButton(
                    icon: "calendar",
                    title: "Appointments",
                    isSelected: selectedTab == 0,
                    action: { selectedTab = 0 }
                )
                
                TabBarButton(
                    icon: "person.circle",
                    title: "Profile",
                    isSelected: selectedTab == 1,
                    action: { selectedTab = 1 }
                )
                
                TabBarButton(
                    icon: "heart.circle",
                    title: "Wellness Check",
                    isSelected: selectedTab == 2,
                    action: { selectedTab = 2 }
                )
            }
            .frame(height: 49)
            .background(Color.contentBackground)
            .overlay(
                Rectangle()
                    .frame(height: 0.5)
                    .foregroundColor(Color.textPrimary.opacity(0.08)),
                alignment: .top
            )
            
            // Bottom padding
            Color.contentBackground
                .frame(height: 16)
        }
        .background(Color.contentBackground)
    }
}

struct TabBarButton: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            action()
        }) {
            ZStack(alignment: .top) {
                VStack(spacing: 4) {
                    Image(systemName: icon)
                        .font(.system(size: 22))
                        .foregroundColor(.black)
                    
                    Text(title)
                        .font(.system(size: 11, weight: isSelected ? .medium : .regular))
                        .foregroundColor(.black)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 49)
                
                // Visual indicator - colored bar at top
                if isSelected {
                    Rectangle()
                        .fill(Color.buttonPrimary)
                        .frame(height: 3)
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct AppointmentView: View {
    var body: some View {
        ZStack {
            Color.contentBackground
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
        }
        .navigationBarHidden(true)
    }
}

struct WellnessCheckView: View {
    @State private var messages: [ChatMessage] = []
    @State private var inputText: String = ""
    @State private var isLoadingResponse = false
    @FocusState private var isInputFocused: Bool
    
    private let aiService = AIService(apiKey: Config.openAIKey)
    
    var body: some View {
        ZStack {
            Color.contentBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                Text("Wellness Check")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.black)
                    .padding(.top, 20)
                    .padding(.bottom, 30)
                
                // Chat Card
                ZStack {
                    Color.cardBackground
                        .cornerRadius(20)
                    
                    VStack(spacing: 0) {
                        // Date display
                        Text(formattedDate)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.black.opacity(0.6))
                            .padding(.top, 20)
                            .padding(.bottom, 16)
                        
                        // Messages area - takes available space
                        ScrollViewReader { proxy in
                            ScrollView {
                                VStack(alignment: .leading, spacing: 16) {
                                    ForEach(messages) { message in
                                        ChatBubbleView(message: message)
                                            .id(message.id)
                                    }
                                    
                                    // Loading indicator
                                    if isLoadingResponse {
                                        HStack {
                                            ProgressView()
                                                .scaleEffect(0.8)
                                            Text("Thinking...")
                                                .font(.system(size: 14))
                                                .foregroundColor(.black.opacity(0.6))
                                        }
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 12)
                                        .background(Color(white: 0.9))
                                        .cornerRadius(16)
                                        .id("loading")
                                    }
                                }
                                .padding(.horizontal, 20)
                                .padding(.bottom, 16)
                            }
                            .onChange(of: messages.count) { _ in
                                if let lastMessage = messages.last {
                                    withAnimation(.easeOut(duration: 0.3)) {
                                        proxy.scrollTo(lastMessage.id, anchor: .bottom)
                                    }
                                }
                            }
                            .onChange(of: isLoadingResponse) { loading in
                                if loading {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        withAnimation {
                                            proxy.scrollTo("loading", anchor: .bottom)
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Input area - fixed at bottom
                        HStack(spacing: 12) {
                            TextField("Describe your health...", text: $inputText)
                                .font(.system(size: 16))
                                .foregroundColor(.black)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .frame(height: 36)
                                .background(Color(white: 0.9)) // Light grey background
                                .cornerRadius(20)
                                .focused($isInputFocused)
                                .onSubmit {
                                    sendMessage()
                                }
                            
                            Button(action: sendMessage) {
                                Image(systemName: "arrow.up")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.black)
                                    .frame(width: 36, height: 36)
                                    .background(Color(white: 0.9)) // Light grey background
                                    .cornerRadius(12)
                            }
                            .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isLoadingResponse)
                            .opacity((inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isLoadingResponse) ? 0.5 : 1.0)
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    }
                }
                .padding(.horizontal, 20)
                .frame(maxWidth: .infinity)
                
                Spacer()
                    .frame(height: 80)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            // Initialize with welcome message
            if messages.isEmpty {
                let welcomeMessage = ChatMessage(
                    content: "Hi! Welcome to your Wellness check. Why don't you tell me how you're doing? any physical or mental health issues?",
                    isFromUser: false
                )
                messages.append(welcomeMessage)
            }
        }
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        return formatter.string(from: Date())
    }
    
    private func sendMessage() {
        let trimmedText = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return }
        
        // Check if API key is set
        guard Config.openAIKey != "YOUR_API_KEY_HERE" else {
            let errorMessage = ChatMessage(
                content: "Please add your OpenAI API key in Config.swift to enable AI responses.",
                isFromUser: false
            )
            messages.append(errorMessage)
            return
        }
        
        // Validate API key format
        let trimmedKey = Config.openAIKey.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedKey.hasPrefix("sk-") else {
            let errorMessage = ChatMessage(
                content: "Invalid API key format. OpenAI API keys should start with 'sk-'. Please check your Config.swift file.",
                isFromUser: false
            )
            messages.append(errorMessage)
            return
        }
        
        // Debug: Check key length (OpenAI keys are typically 51+ characters)
        if trimmedKey.count < 20 {
            let errorMessage = ChatMessage(
                content: "API key appears too short. Please verify you copied the complete key from OpenAI.",
                isFromUser: false
            )
            messages.append(errorMessage)
            return
        }
        
        // Add user message
        let userMessage = ChatMessage(content: trimmedText, isFromUser: true)
        messages.append(userMessage)
        
        // Clear input
        inputText = ""
        
        // Set loading state
        isLoadingResponse = true
        
        // System prompt for medical intake
        let systemPrompt = """
        You are a friendly and professional nurse conducting a medical intake interview. 
        Your role is to:
        - Ask follow-up questions about symptoms
        - Gather relevant health information
        - Be empathetic and supportive
        - Keep responses concise (2-3 sentences max)
        - Guide the conversation to understand the patient's concerns
        
        Remember: You are NOT providing medical diagnosis or treatment advice, 
        just gathering information for a healthcare provider.
        """
        
        // Call AI (async)
        Task {
            do {
                let aiResponseText = try await aiService.sendMessage(
                    userMessage: trimmedText,
                    conversationHistory: messages,
                    systemPrompt: systemPrompt
                )
                
                await MainActor.run {
                    let aiResponse = ChatMessage(content: aiResponseText, isFromUser: false)
                    messages.append(aiResponse)
                    isLoadingResponse = false
                }
            } catch {
                await MainActor.run {
                    // Get detailed error message
                    let errorDescription = (error as NSError).localizedDescription
                    var errorMessage = "I'm having trouble connecting right now."
                    
                    // Provide more specific error messages
                    if errorDescription.contains("401") || errorDescription.contains("Invalid API key") {
                        errorMessage = "Invalid API key. Please check your API key in Config.swift"
                    } else if errorDescription.contains("429") {
                        errorMessage = "Rate limit exceeded. Please wait a moment and try again."
                    } else if errorDescription.contains("insufficient_quota") {
                        errorMessage = "Insufficient quota. Please check your OpenAI account billing."
                    } else if errorDescription.contains("network") || errorDescription.contains("connection") {
                        errorMessage = "Network error. Please check your internet connection and try again."
                    } else {
                        // Show the actual error for debugging
                        errorMessage = "Error: \(errorDescription)"
                    }
                    
                    let errorChatMessage = ChatMessage(
                        content: errorMessage,
                        isFromUser: false
                    )
                    messages.append(errorChatMessage)
                    isLoadingResponse = false
                }
            }
        }
    }
}

struct ChatBubbleView: View {
    let message: ChatMessage
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            if message.isFromUser {
                Spacer(minLength: 50)
            }
            
            Text(message.content)
                .font(.system(size: 16))
                .foregroundColor(.black)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    message.isFromUser 
                        ? Color.tropicalTeal.opacity(0.3)
                        : Color(white: 0.9) // Light grey for AI messages
                )
                .cornerRadius(16)
                .frame(maxWidth: UIScreen.main.bounds.width * 0.75, alignment: message.isFromUser ? .trailing : .leading)
            
            if !message.isFromUser {
                Spacer(minLength: 50)
            }
        }
    }
}
