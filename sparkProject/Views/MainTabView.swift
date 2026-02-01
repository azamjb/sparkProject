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
    @State private var tabSelection = 1

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
                    title: "Wellness",
                    isSelected: selectedTab == 2,
                    action: { selectedTab = 2 }
                )
            }
            .frame(height: 49)
            .background(Color.white)
            .overlay(
                Rectangle()
                    .frame(height: 0.5)
                    .foregroundColor(Color.textPrimary.opacity(0.08)),
                alignment: .top
            )
            
            // Bottom padding
            Color.white
                .frame(height: 16)
        }
        .background(Color.white)
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
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(isSelected ? .buttonPrimary : .black)
                
                Text(title)
                    .font(.system(size: 11, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? .buttonPrimary : .black)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 49)
            .background(isSelected ? Color.buttonPrimary.opacity(0.15) : Color.clear)
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct AppointmentView: View {
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Title
                Text("Upcoming Appointment")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.black)
                    .padding(.top, 10)
                    .padding(.bottom, 30)
                
                // Date Card
                VStack {
                    Text("February 2nd, 2026")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.black)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
                .background(Color.tropicalTeal)
                .cornerRadius(18)
                .padding(.horizontal, 30)
                .padding(.bottom, 24)
                
                // Appointment Details Card
                VStack(spacing: 0) {
                    AppointmentDetailRow(
                        label: "Time",
                        value: "3:00 pm",
                        showChevron: false
                    )
                    
                    Divider()
                        .background(Color.black.opacity(0.15))
                    
                    AppointmentDetailRow(
                        label: "Location",
                        value: "449 Rippleton Rd",
                        showChevron: false
                    )
                    
                    Divider()
                        .background(Color.black.opacity(0.15))
                    
                    AppointmentDetailRow(
                        label: "Topic",
                        value: "",
                        showChevron: true
                    )
                    
                    Divider()
                        .background(Color.black.opacity(0.15))
                    
                    AppointmentDetailRow(
                        label: "Travel Options",
                        value: "",
                        showChevron: true
                    )
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.tropicalTeal)
                .cornerRadius(18)
                .padding(.horizontal, 30)
                .padding(.bottom, 50)
                
                // Action Buttons
                HStack(spacing: 15) {
                    Button(action: {
                        // Reschedule action
                    }) {
                        Text("Reschedule")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.buttonPrimary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.buttonPrimary, lineWidth: 2)
                            )
                    }
                    
                    Button(action: {
                        // Contact action
                    }) {
                        Text("Contact")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.buttonPrimary)
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 50)
            }
        }
        .navigationBarHidden(true)
    }
}

struct AppointmentDetailRow: View {
    let label: String
    let value: String
    let showChevron: Bool
    
    var body: some View {
        HStack {
            Text(label)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.black)
            
            Spacer()
            
            if !value.isEmpty {
                Text(value)
                    .font(.body)
                    .foregroundColor(.black)
            }
            
            if showChevron {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.black)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .contentShape(Rectangle())
    }
}

struct WellnessCheckView: View {
    @EnvironmentObject var profileManager: UserProfileManager
    @State private var messages: [ChatMessage] = []
    @State private var inputText: String = ""
    @State private var isLoadingResponse = false
    @State private var isConversationComplete = false
    @State private var followUpCount = 0
    @State private var wellnessCheckFrequency: Int = 30
    @FocusState private var isInputFocused: Bool
    
    private let aiService = AIService(apiKey: Config.openAIKey)
    private let databaseService = DatabaseService()
    
    private var nextWellnessCheckDate: Date {
        Calendar.current.date(byAdding: .day, value: wellnessCheckFrequency, to: Date()) ?? Date()
    }
    
    private var formattedNextCheckDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        return formatter.string(from: nextWellnessCheckDate)
    }
    
    private var frequencyDescription: String {
        switch wellnessCheckFrequency {
        case 1:
            return "Daily"
        case 2:
            return "Every 2 days"
        case 7:
            return "Weekly"
        case 14:
            return "Bi-weekly"
        case 30:
            return "Monthly"
        default:
            return "Every \(wellnessCheckFrequency) days"
        }
    }
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()

            GeometryReader { geo in
                // Heights reserved for header + info bar + padding + custom tab bar overlay
                let tabBarOverlayHeight: CGFloat = 49 + 16 // your custom tab bar heights
                let headerBlockHeight: CGFloat = 20 + 30 + 40 // top/bottom padding + title visual space
                let infoBarBlockHeight: CGFloat = 16 + 84 // top padding + info bar approx height
                let outerVerticalPadding: CGFloat = 0 // we already manage internal padding
                let availableForChat = geo.size.height
                    - tabBarOverlayHeight
                    - headerBlockHeight
                    - infoBarBlockHeight
                    - outerVerticalPadding
                    - 20 // extra breathing room
                
                let chatCardHeight:CGFloat = 480

                VStack(spacing: 0) {
                    // Header
                Text("Wellness Check")
                    .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.black)
                        .padding(.top, 20)
                        .padding(.bottom, 30)
                        .frame(maxWidth: .infinity)

                    // Chat Card (TOP teal box) — constrained so it doesn't push the info bar off-screen
                    ZStack {
                        Color.tropicalTeal
                            .cornerRadius(20)
                        
                        VStack(spacing: 0) {
                            // Date display
                            Text(formattedDate)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.black.opacity(0.6))
                                .padding(.top, 20)
                                .padding(.bottom, 16)
                            
                            // Messages area - takes available space inside the card
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
                                    .padding(.top, 16)
                                    .padding(.bottom, 40)
                                }
                                .onChange(of: messages.count) { _ in
                                    if let lastMessage = messages.last {
                                        withAnimation(.easeOut(duration: 0.3)) {
                                            proxy.scrollTo(lastMessage.id, anchor: .center)
                                        }
                                    }
                                }
                                .onChange(of: isLoadingResponse) { loading in
                                    if loading {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                            withAnimation {
                                                proxy.scrollTo("loading", anchor: .center)
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(.bottom, 16)
                            
                            // Input area - fixed at bottom
                            HStack(spacing: 12) {
                                TextField("Describe your health...", text: $inputText)
                                    .font(.system(size: 16))
                                    .foregroundColor(.black)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .frame(height: 36)
                                    .background(Color.white) // White background for contrast on teal
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
                                        .background(Color.white) // White background for contrast on teal
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
                    .frame(height: chatCardHeight)

                    // Wellness Check Info Bar (BOTTOM beige box) — now guaranteed room
                    WellnessCheckInfoBar(
                        nextCheckDate: formattedNextCheckDate,
                        frequency: frequencyDescription
                    )
                    .padding(.horizontal, 20)
                    .padding(.top, 16)

                    Spacer(minLength: 0)
                }
                // keep content above your custom tab bar overlay
                .padding(.bottom, tabBarOverlayHeight)
                .frame(width: geo.size.width, height: geo.size.height, alignment: .top)
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
            
            // Load wellness check frequency
            loadWellnessCheckFrequency()
        }
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        return formatter.string(from: Date())
    }
    
    private func loadWellnessCheckFrequency() {
        guard let userId = profileManager.userProfile?.userId else {
            return
        }
        
        Task {
            do {
                let frequency = try await databaseService.getWellnessCheckFrequency(userId: userId)
                await MainActor.run {
                    wellnessCheckFrequency = frequency
                }
            } catch {
                print("⚠️ Could not load wellness check frequency: \(error.localizedDescription)")
            }
        }
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
        4. If you asked about booking an appointment, wait for the user's response (yes/no), then say: "Thank you for completing the wellness check. A representative will be in touch about next steps"
        
        IMPORTANT RULES:
        - Maximum 4 follow-up questions total (not including the welcome message)
        - Keep responses concise (1-2 sentences max)
        - Be empathetic and supportive
        - Do NOT ask for personal identifiable information
        - Do NOT provide medical diagnosis or treatment advice
        - When the conversation is complete, you MUST end with exactly: "Thank you for completing the wellness check."
        - Count your follow-up questions carefully - after 4, you must make the appointment recommendation
        
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
        
        // Fetch user health data from database (excluding name for anonymity)
        var userHealthData: UserHealthData?
        do {
            print("📊 Fetching user health data from database...")
            userHealthData = try await databaseService.getUserData(userId: userId)
            print("✅ User health data retrieved")
        } catch {
            print("⚠️ Could not fetch user health data: \(error.localizedDescription)")
            print("   Continuing with report generation without user context...")
        }
        
        // Generate report from conversation
        let conversationText = messages.map { message in
            "\(message.isFromUser ? "User" : "Assistant"): \(message.content)"
        }.joined(separator: "\n")
        
        // Build context string with user health data
        var userContext = ""
        if let healthData = userHealthData {
            userContext = "\n\n" + healthData.formattedContext()
        }
        
        let reportPrompt = """
        Based on the following wellness check conversation and patient health profile, generate a concise report (2-3 sentences) that includes:
        1. A brief overview of the user's symptoms/concerns
        2. Whether a doctor's appointment was recommended (yes/no)
        3. Whether the user agreed to book an appointment (if applicable)
        
        IMPORTANT: Consider the patient's health profile when generating the report. For example:
        - If they have chronic conditions, consider how the current symptoms relate to those conditions
        - If they are on medications, consider potential interactions or side effects
        - If they have hereditary risk patterns, consider family history relevance
        - Use age and biological sex to provide age/sex-appropriate context
        
        Keep it professional and concise. Do not include personal details beyond symptoms and relevant health information.
        Format as a brief summary suitable for a medical record.
        
        Wellness Check Conversation:
        \(conversationText)\(userContext)
        
        Generate only the report text, nothing else:
        """
        
        do {
            print("🤖 Calling AI to generate report with user context...")
            let report = try await aiService.sendMessage(
                userMessage: "Generate the wellness check report based on the conversation and patient health profile above.",
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

struct WellnessCheckInfoBar: View {
    let nextCheckDate: String
    let frequency: String
    
    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Next Wellness Check")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.black.opacity(0.6))
                
                Text(nextCheckDate)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.black)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("Frequency")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.black.opacity(0.6))
                
                Text(frequency)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color.tropicalTeal)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.25), lineWidth: 1)
        )
    }
}


struct PrivacyPolicyView: View {
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text("Privacy Policy")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.black)
                        .padding(.top, 20)
                        .padding(.horizontal, 20)
                    
                    VStack(alignment: .leading, spacing: 20) {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("How We Use Your Data")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.black)
                            
                            Text("Your information is used only to support your health experience between your doctor and you. Our AI Chatbot only uses your data to answer your questions. The chatbot offers general health support and does not replace healthcare professionals or community care.")
                                .font(.system(size: 16))
                                .foregroundColor(.black)
                                .lineSpacing(4)
                            
                            Text("Our advanced system follows HIPAA-protocols under Canadian privacy laws. We respect Indigenous data rights and your right to choose what you share.")
                                .font(.system(size: 16))
                                .foregroundColor(.black)
                                .lineSpacing(4)
                        }
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Your Privacy & Choices")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.black)
                            
                            VStack(alignment: .leading, spacing: 12) {
                                PrivacyBulletPoint(text: "Your data is never sold or used for advertising")
                                PrivacyBulletPoint(text: "You control what information you share and can withdraw consent at any time.")
                                PrivacyBulletPoint(text: "Personal identifiers are removed whenever possible")
                                PrivacyBulletPoint(text: "To request a copy of your data, please email careify@careify.com.")
                                PrivacyBulletPoint(text: "Data is securely stored and protected. For any other inquiries, please email careify@careify.com.")
                            }
                        }
                        
                        Text("© 2026")
                            .font(.system(size: 14))
                            .foregroundColor(.black.opacity(0.6))
                            .padding(.top, 8)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 100)
                }
            }
        }
        .navigationBarHidden(true)
    }
}

struct PrivacyBulletPoint: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text("•")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.black)
                .padding(.top, 2)
            
            Text(text)
                .font(.system(size: 16))
                .foregroundColor(.black)
                .lineSpacing(4)
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
                        ? Color(red: 217/255, green: 217/255, blue: 217/255) // #D9D9D9 light grey background for user messages
                        : Color.mutedTeal // #8FC0A9 for AI messages
                )
                .cornerRadius(16)
                .frame(maxWidth: UIScreen.main.bounds.width * 0.75, alignment: message.isFromUser ? .trailing : .leading)
            
            if !message.isFromUser {
                Spacer(minLength: 50)
            }
        }
    }
}
