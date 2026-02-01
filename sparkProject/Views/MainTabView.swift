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
                .padding(.top, 4) // Add space between indicator and content
                
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
    @EnvironmentObject var profileManager: UserProfileManager
    @State private var messages: [ChatMessage] = []
    @State private var inputText: String = ""
    @State private var isLoadingResponse = false
    @State private var isConversationComplete = false
    @State private var followUpCount = 0
    @FocusState private var isInputFocused: Bool
    
    private let aiService = AIService(apiKey: Config.openAIKey)
    private let databaseService = DatabaseService()
    
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
                            .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isLoadingResponse || isConversationComplete)
                            .opacity((inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isLoadingResponse || isConversationComplete) ? 0.5 : 1.0)
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
                followUpCount = 0
                isConversationComplete = false
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
        
        // Count AI messages to track follow-up questions
        let aiMessageCount = messages.filter { !$0.isFromUser }.count
        
        // System prompt for medical intake
        let systemPrompt = """
        You are a friendly and professional healthcare assistant conducting a wellness check interview.
        
        CONVERSATION FLOW:
        1. The user has already shared their initial symptoms/concerns.
        2. You may ask up to 4 follow-up questions to better understand their symptoms (you have asked \(aiMessageCount - 1) follow-up questions so far).
        3. After maximum 4 follow-up questions, you MUST make an appointment recommendation:
           - If symptoms are serious/urgent: Say "You are recommended to book a doctor's appointment. Would you like to do so?"
           - If symptoms are mild/moderate: Say "Would you like to book a doctor's appointment?"
           - If no appointment needed: Say "Thank you for completing the wellness check."
        4. If you asked about booking an appointment, wait for the user's response (yes/no), then say: "Thank you for completing the wellness check."
        
        IMPORTANT RULES:
        - Maximum 2 follow-up questions total (not including the welcome message)
        - Keep responses concise (1-2 sentences max)
        - Be empathetic and supportive
        - Do NOT ask for personal identifiable information
        - Do NOT provide medical diagnosis or treatment advice
        - When the conversation is complete, you MUST end with exactly: "Thank you for completing the wellness check."
        - Count your follow-up questions carefully - after 2, you must make the appointment recommendation
        
        Current conversation: You have asked \(aiMessageCount - 1) follow-up question(s) so far.
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
                    
                    // Check if conversation is complete
                    if aiResponseText.lowercased().contains("thank you for completing the wellness check") {
                        isConversationComplete = true
                        // Generate and save report
                        Task {
                            await generateAndSaveReport()
                        }
                    }
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
    
    private func generateAndSaveReport() async {
        guard let userId = profileManager.userProfile?.userId else {
            print("❌ No user ID found, cannot save report")
            print("💡 User profile: \(profileManager.userProfile?.name ?? "nil")")
            print("💡 Make sure user completed onboarding and was saved to database")
            return
        }
        
        print("📝 Generating wellness report for user ID: \(userId)")
        
        // Generate report from conversation
        let conversationText = messages.map { message in
            "\(message.isFromUser ? "User" : "Assistant"): \(message.content)"
        }.joined(separator: "\n")
        
        let reportPrompt = """
        Based on the following wellness check conversation, generate a concise report (2-3 sentences) that includes:
        1. A brief overview of the user's symptoms/concerns
        2. Whether a doctor's appointment was recommended (yes/no)
        3. Whether the user agreed to book an appointment (if applicable)
        
        Keep it professional and concise. Do not include personal details beyond symptoms.
        Format as a brief summary suitable for a medical record.
        
        Conversation:
        \(conversationText)
        
        Generate only the report text, nothing else:
        """
        
        do {
            print("🤖 Calling AI to generate report...")
            let report = try await aiService.sendMessage(
                userMessage: "Generate the wellness check report based on the conversation above.",
                conversationHistory: [],
                systemPrompt: reportPrompt
            )
            
            let cleanReport = report.trimmingCharacters(in: .whitespacesAndNewlines)
            print("📄 Generated report: \(cleanReport.prefix(100))...")
            
            // Save report to database
            print("💾 Saving report to database...")
            try await databaseService.updateWellnessReport(userId: userId, report: cleanReport)
            
            await MainActor.run {
                print("✅ Wellness report saved to database successfully!")
                print("📋 Report preview: \(cleanReport.prefix(50))...")
            }
        } catch {
            print("❌ Error generating/saving report: \(error.localizedDescription)")
            if let nsError = error as NSError? {
                print("   Error domain: \(nsError.domain)")
                print("   Error code: \(nsError.code)")
                if let userInfo = nsError.userInfo as? [String: Any] {
                    print("   Error details: \(userInfo)")
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
