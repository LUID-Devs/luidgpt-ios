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
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)

            // Models Tab
            ModelsView()
                .tabItem {
                    Label("Models", systemImage: "sparkles")
                }
                .tag(1)

            // Generations Tab
            GenerationsView()
                .tabItem {
                    Label("History", systemImage: "clock.fill")
                }
                .tag(2)

            // Profile Tab
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(3)
        }
        .accentColor(LGColors.VideoGeneration.main)
    }
}

// MARK: - Placeholder Views

struct ModelsView: View {
    var body: some View {
        NavigationView {
            ZStack {
                LGColors.background.ignoresSafeArea()

                VStack(spacing: 20) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 60))
                        .foregroundColor(LGColors.VideoGeneration.main)

                    Text("Models Browser")
                        .font(LGFonts.h2)
                        .foregroundColor(LGColors.foreground)

                    Text("Coming in Phase 5")
                        .font(LGFonts.body)
                        .foregroundColor(LGColors.neutral400)
                }
            }
            .navigationTitle("Models")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct GenerationsView: View {
    var body: some View {
        NavigationView {
            ZStack {
                LGColors.background.ignoresSafeArea()

                VStack(spacing: 20) {
                    Image(systemName: "clock.fill")
                        .font(.system(size: 60))
                        .foregroundColor(LGColors.VideoGeneration.main)

                    Text("Generation History")
                        .font(LGFonts.h2)
                        .foregroundColor(LGColors.foreground)

                    Text("Coming in Phase 7")
                        .font(LGFonts.body)
                        .foregroundColor(LGColors.neutral400)
                }
            }
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

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
                            .foregroundColor(LGColors.neutral400)

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
