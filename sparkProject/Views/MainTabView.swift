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

    // ✅ This binding forces selection changes to happen with NO animation
    private var tabSelectionNoAnim: Binding<Int> {
        Binding(
            get: { tabSelection },
            set: { newValue in
                var txn = Transaction()
                txn.animation = nil
                withTransaction(txn) {
                    tabSelection = newValue
                }
            }
        )
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

                TabView(selection: tabSelectionNoAnim) {
                    AppointmentView()
                        .tag(0)
                        .tabItem {
                            Image(systemName: "calendar")
                            Text("Appointments")
                        }

                    ProfileView()
                        .tag(1)
                        .tabItem {
                            Image(systemName: "person.circle")
                            Text("Profile")
                        }

                    WellnessCheckView()
                        .tag(2)
                        .tabItem {
                            Image(systemName: "heart.circle")
                            Text("Wellness Check")
                        }
                }
                .accentColor(.buttonPrimary)

                // SwiftUI-side tab bar background enforcement
                .toolbarBackground(Color.contentBackground, for: .tabBar)
                .toolbarBackground(.visible, for: .tabBar)

                // UIKit-side background enforcement (fixes floating gaps)
                .background(TabBarControllerBackgroundSetter(color: UIColor(Color.contentBackground)))

                // ✅ Extra insurance: prevent implicit animations inside the TabView tree
                .transaction { txn in
                    txn.animation = nil
                }
            }
        }
    }
}

// MARK: - Forces the underlying UITabBarController's view background
private struct TabBarControllerBackgroundSetter: UIViewControllerRepresentable {
    let color: UIColor

    func makeUIViewController(context: Context) -> UIViewController {
        Controller(color: color)
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}

    private final class Controller: UIViewController {
        let color: UIColor

        init(color: UIColor) {
            self.color = color
            super.init(nibName: nil, bundle: nil)
            view.isUserInteractionEnabled = false
            view.backgroundColor = .clear
        }

        required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

        override func didMove(toParent parent: UIViewController?) {
            super.didMove(toParent: parent)
            guard let tab = parent as? UITabBarController else { return }

            tab.view.backgroundColor = color
            tab.tabBar.isTranslucent = false
            tab.tabBar.backgroundColor = color
        }
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
    var body: some View {
        ZStack {
            Color.contentBackground
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Text("Wellness Check")
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
