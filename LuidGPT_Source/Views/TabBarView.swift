//
//  TabBarView.swift
//  LuidGPT
//
//  Main tab bar navigation with Home, Models, Generations, and Profile tabs
//

import SwiftUI

struct TabBarView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            // Home Tab
            NavigationView {
                HomeView()
            }
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }
            .tag(0)

            // Generations Tab
            GenerationsListView()
                .tabItem {
                    Label("History", systemImage: "clock.fill")
                }
                .tag(1)

            // Profile Tab
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(2)
        }
        .accentColor(LGColors.VideoGeneration.main)
    }
}

// MARK: - Placeholder Views

// ModelsView is now implemented in Views/Models/ModelsView.swift
// GenerationsListView is now implemented in Views/Generations/GenerationsListView.swift

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        NavigationView {
            ZStack {
                LGColors.background.ignoresSafeArea()

                VStack(spacing: 24) {
                    // Profile avatar
                    if let user = authViewModel.currentUser {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            LGColors.VideoGeneration.main,
                                            LGColors.ImageGeneration.main
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 80, height: 80)

                            Text(user.initials)
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.white)
                        }

                        Text(user.fullName)
                            .font(LGFonts.h2)
                            .foregroundColor(LGColors.foreground)

                        Text(user.email)
                            .font(LGFonts.body)
                            .foregroundColor(LGColors.neutral600)

                        // Logout button
                        LGButton(
                            "Logout",
                            style: .outline,
                            fullWidth: false
                        ) {
                            Task {
                                await authViewModel.logout()
                            }
                        }
                        .padding(.top, 20)
                    }
                }
                .padding()
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - Preview

#if DEBUG
struct TabBarView_Previews: PreviewProvider {
    static var previews: some View {
        TabBarView()
            .environmentObject(AuthViewModel())
    }
}
#endif
