//
//  TabBarView.swift
//  LuidGPT
//
//  Main tab bar navigation with Home, Models, Generations, and Profile tabs
//  Includes drawer menu for navigation
//

import SwiftUI

struct TabBarView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var creditsViewModel: CreditsViewModel
    @State private var selectedTab = 0
    @State private var isDrawerOpen = false
    @State private var drawerDestination: DrawerDestination?

    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                // Home Tab
                NavigationView {
                    HomeView()
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        isDrawerOpen = true
                                    }
                                }) {
                                    Image(systemName: "line.3.horizontal")
                                        .font(.system(size: 20, weight: .semibold))
                                        .foregroundColor(.black)
                                }
                            }
                        }
                }
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)

                // Generations Tab
                NavigationView {
                    GenerationsListView()
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        isDrawerOpen = true
                                    }
                                }) {
                                    Image(systemName: "line.3.horizontal")
                                        .font(.system(size: 20, weight: .semibold))
                                        .foregroundColor(.black)
                                }
                            }
                        }
                }
                .tabItem {
                    Label("History", systemImage: "clock.fill")
                }
                .tag(1)

                // Profile Tab
                NavigationView {
                    ProfileView()
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        isDrawerOpen = true
                                    }
                                }) {
                                    Image(systemName: "line.3.horizontal")
                                        .font(.system(size: 20, weight: .semibold))
                                        .foregroundColor(.black)
                                }
                            }
                        }
                }
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(2)
            }
            .accentColor(LGColors.VideoGeneration.main)

            // Drawer Menu Overlay
            if isDrawerOpen {
                DrawerMenuView(isOpen: $isDrawerOpen, destination: $drawerDestination)
                    .transition(.move(edge: .leading))
                    .zIndex(1)
            }
        }
        .sheet(item: $drawerDestination) { dest in
            NavigationView {
                destinationView(for: dest)
                    .navigationBarTitleDisplayMode(.large)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("Close") {
                                drawerDestination = nil
                            }
                        }
                    }
            }
        }
    }

    @ViewBuilder
    private func destinationView(for destination: DrawerDestination) -> some View {
        switch destination {
        case .home:
            HomeView()
        case .dashboard:
            DashboardView()
        case .usage:
            UsageView()
        case .workspaces:
            WorkspacesView()
        case .profile:
            ProfileView()
        case .billing:
            BillingView()
        case .settings:
            SettingsView()
        }
    }
}

// MARK: - Preview

#if DEBUG
struct TabBarView_Previews: PreviewProvider {
    static var previews: some View {
        TabBarView()
            .environmentObject(AuthViewModel())
            .environmentObject(CreditsViewModel())
    }
}
#endif
