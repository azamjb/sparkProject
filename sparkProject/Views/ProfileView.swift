//
//  ProfileView.swift
//  sparkProject
//
//  Created by Azam Jawad on 2026-01-31.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var profileManager: UserProfileManager

    // ✅ Adjust this to match the screenshot exactly (smaller = less blue)
    private let tealHeight: CGFloat = 65
    private let greenBandHeight: CGFloat = 140

    init() {
        // ✅ Make the tab bar background NOT white
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Color.contentBackground)
        appearance.shadowColor = .clear

        UITabBar.appearance().standardAppearance = appearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
        UITabBar.appearance().isTranslucent = false
    }

    var body: some View {
        GeometryReader { proxy in
            let topInset = proxy.safeAreaInsets.top
            let boundaryY = topInset + tealHeight
            let headerTotalHeight = topInset + tealHeight + greenBandHeight

            ZStack(alignment: .top) {

                // ✅ Teal is always behind the top (and there is NO ScrollView now, so no pull-down anyway)
                Color.tropicalTeal
                    .ignoresSafeArea()

                // ✅ Green fills from boundary to bottom (no white anywhere)
                Color.contentBackground
                    .frame(height: proxy.size.height - boundaryY)
                    .frame(maxWidth: .infinity)
                    .offset(y: boundaryY)
                    .ignoresSafeArea(edges: .bottom)

                // ✅ No ScrollView = no dragging
                VStack(spacing: 0) {

                    // MARK: - Header area
                    ZStack {
                        // Hamburger menu (top-right)
                        VStack {
                            HStack {
                                Spacer()
                                Menu {
                                    Button(role: .destructive) {
                                        profileManager.clearProfile()
                                    } label: {
                                        Label("Delete Account", systemImage: "trash")
                                    }
                                } label: {
                                    Image(systemName: "line.horizontal.3")
                                        .font(.title2)
                                        .foregroundColor(.black)
                                        .padding(.trailing, 20)
                                        .padding(.top, topInset + 10)
                                }
                            }
                            Spacer()
                        }

                        // Profile content overlapping the boundary
                        if let profile = profileManager.userProfile {
                            VStack(spacing: 4) {
                                Image("profile")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 140, height: 140)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.white, lineWidth: 4))
                                    .shadow(color: .black.opacity(0.25), radius: 8, x: 0, y: 4)

                                Text(profile.name)
                                    .font(.system(size: 26, weight: .bold))
                                    .foregroundColor(.black)

                                Text("\(profile.gender), \(profile.age)")
                                    .font(.system(size: 16, weight: .regular))
                                    .foregroundColor(.black.opacity(0.75))
                            }
                            // Center the circle on the teal/green boundary:
                            // top padding = boundaryY - 70
                            .padding(.top, boundaryY - 70)
                        }
                    }
                    .frame(height: headerTotalHeight)

                    // MARK: - Physical Attributes Card
                    VStack(spacing: 0) {
                        PhysicalAttributeRow(label: "Height", value: profileManager.userProfile?.height ?? "N/A")

                        Divider()
                            .background(Color.black.opacity(0.15))

                        PhysicalAttributeRow(label: "Weight", value: profileManager.userProfile?.weight ?? "N/A")
                    }
                    .padding(20)
                    .background(Color.cardBackground)
                    .cornerRadius(18)
                    .padding(.horizontal, 20)
                    .padding(.top, 12)

                    // MARK: - Medical Information Section
                    VStack(spacing: 0) {
                        NavigationLink(destination: MedicalDetailView(
                            title: "Medical Background",
                            content: profileManager.userProfile?.medicalBackground ?? "No information provided"
                        ).environmentObject(profileManager)) {
                            MedicalInfoRow(title: "Medical Background")
                        }
                        .buttonStyle(PlainButtonStyle())

                        Divider()
                            .background(Color.black.opacity(0.15))

                        NavigationLink(destination: MedicalDetailView(
                            title: "Chronic Conditions",
                            content: profileManager.userProfile?.chronicConditions ?? "No information provided"
                        ).environmentObject(profileManager)) {
                            MedicalInfoRow(title: "Chronic Conditions")
                        }
                        .buttonStyle(PlainButtonStyle())

                        Divider()
                            .background(Color.black.opacity(0.15))

                        NavigationLink(destination: MedicalDetailView(
                            title: "Current Medications",
                            content: profileManager.userProfile?.currentMedications ?? "No information provided"
                        ).environmentObject(profileManager)) {
                            MedicalInfoRow(title: "Current Medications")
                        }
                        .buttonStyle(PlainButtonStyle())

                        Divider()
                            .background(Color.black.opacity(0.15))

                        NavigationLink(destination: MedicalDetailView(
                            title: "Hereditary Risk Patterns",
                            content: profileManager.userProfile?.hereditaryRiskPatterns ?? "No information provided"
                        ).environmentObject(profileManager)) {
                            MedicalInfoRow(title: "Hereditary Risk Patterns")
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(20)
                    .background(Color.cardBackground)
                    .cornerRadius(18)
                    .padding(.horizontal, 20)
                    .padding(.top, 18)

                    Spacer(minLength: 0)
                }
                // Helps keep the layout stable and fill the screen
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .padding(.bottom, 18) // extra breathing room above the tab bar
            }
            // Don’t let implicit animations sneak in
            .transaction { txn in
                txn.animation = nil
            }
        }
        .navigationBarHidden(true)
    }
}

struct PhysicalAttributeRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.black)

            Spacer()

            Text(value)
                .font(.body)
                .foregroundColor(.black)
        }
        .padding(.vertical, 12)
    }
}

struct MedicalInfoRow: View {
    let title: String

    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.black)

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.black)
        }
        .padding(.vertical, 15)
        .contentShape(Rectangle())
    }
}

struct MedicalDetailView: View {
    @EnvironmentObject var profileManager: UserProfileManager
    let title: String
    let initialContent: String
    let fieldType: MedicalFieldType

    @State private var content: String
    @State private var isEditing = false
    @FocusState private var isFocused: Bool

    init(title: String, content: String) {
        self.title = title
        self.initialContent = content

        switch title {
        case "Medical Background":
            self.fieldType = .medicalBackground
        case "Chronic Conditions":
            self.fieldType = .chronicConditions
        case "Current Medications":
            self.fieldType = .currentMedications
        case "Hereditary Risk Patterns":
            self.fieldType = .hereditaryRiskPatterns
        default:
            self.fieldType = .medicalBackground
        }

        _content = State(initialValue: content)
    }

    enum MedicalFieldType {
        case medicalBackground
        case chronicConditions
        case currentMedications
        case hereditaryRiskPatterns
    }

    var body: some View {
        ZStack {
            Color.contentBackground
                .ignoresSafeArea()

            VStack(spacing: 0) {
                LinearGradient(
                    gradient: Gradient(colors: [Color.tropicalTeal, Color.contentBackground]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 120)
                .ignoresSafeArea(edges: .top)

                ScrollView {
                    VStack(alignment: .leading, spacing: 25) {
                        Text(title)
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.textPrimary)
                            .padding(.top, 20)
                            .padding(.horizontal, 20)

                        VStack(alignment: .leading, spacing: 15) {
                            if isEditing {
                                TextEditor(text: $content)
                                    .font(.body)
                                    .foregroundColor(.textPrimary)
                                    .frame(minHeight: 200)
                                    .padding(8)
                                    .background(Color.white)
                                    .cornerRadius(10)
                                    .focused($isFocused)
                            } else {
                                if content.isEmpty || content == "No information provided" {
                                    HStack {
                                        Spacer()
                                        VStack(spacing: 10) {
                                            Image(systemName: "doc.text")
                                                .font(.system(size: 50))
                                                .foregroundColor(.textPrimary.opacity(0.3))
                                            Text("No information provided")
                                                .font(.body)
                                                .foregroundColor(.textPrimary.opacity(0.6))
                                        }
                                        .padding(.vertical, 40)
                                        Spacer()
                                    }
                                } else {
                                    Text(content)
                                        .font(.body)
                                        .foregroundColor(.textPrimary)
                                        .lineSpacing(4)
                                }
                            }
                        }
                        .padding(25)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.cardBackground)
                        .cornerRadius(15)
                        .padding(.horizontal, 20)

                        HStack(spacing: 15) {
                            if isEditing {
                                Button(action: {
                                    content = initialContent
                                    isEditing = false
                                    isFocused = false
                                }) {
                                    Text("Cancel")
                                        .font(.headline)
                                        .foregroundColor(.textPrimary)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.gray.opacity(0.2))
                                        .cornerRadius(12)
                                }

                                Button(action: {
                                    saveContent()
                                    isEditing = false
                                    isFocused = false
                                }) {
                                    Text("Save")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.buttonPrimary)
                                        .cornerRadius(12)
                                }
                            } else {
                                Button(action: {
                                    isEditing = true
                                    isFocused = true
                                }) {
                                    HStack {
                                        Image(systemName: "pencil")
                                        Text("Edit")
                                    }
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.buttonPrimary)
                                    .cornerRadius(12)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 30)
                    }
                }
                .scrollContentBackground(.hidden)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(false)
        .transaction { txn in
            txn.animation = nil
        }
    }

    private func saveContent() {
        guard var profile = profileManager.userProfile else { return }

        switch fieldType {
        case .medicalBackground:
            profile.medicalBackground = content.isEmpty ? "" : content
        case .chronicConditions:
            profile.chronicConditions = content.isEmpty ? "" : content
        case .currentMedications:
            profile.currentMedications = content.isEmpty ? "" : content
        case .hereditaryRiskPatterns:
            profile.hereditaryRiskPatterns = content.isEmpty ? "" : content
        }

        profileManager.saveProfile(profile)
    }
}

// Extension for custom corner radius
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
