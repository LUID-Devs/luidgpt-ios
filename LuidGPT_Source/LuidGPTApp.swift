//
//  LuidGPTApp.swift
//  LuidGPT
//
//  Main app entry point for LuidGPT iOS
//

import SwiftUI

@main
struct LuidGPTApp: App {
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var creditsViewModel = CreditsViewModel()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(authViewModel)
                .environmentObject(creditsViewModel)
        }
    }
}

/// Root view that handles authentication state
struct RootView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        Group {
            if authViewModel.isLoading {
                // Show splash screen while checking auth state
                SplashView()
            } else if authViewModel.isAuthenticated {
                // Show main app with tab bar
                TabBarView()
            } else {
                // Show authentication flow
                ZStack {
                    Color.white
                        .ignoresSafeArea()
                    AuthenticationView()
                }
            }
        }
    }
}

/// Splash screen shown during initial load
struct SplashView: View {
    var body: some View {
        ZStack {
            LGColors.background
                .ignoresSafeArea()

            VStack(spacing: 24) {
                // App Logo/Icon
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
                        .frame(width: 120, height: 120)

                    Image(systemName: "sparkles")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.white)
                }

                Text("LuidGPT")
                    .font(LGFonts.h1)
                    .foregroundColor(LGColors.foreground)

                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: LGColors.VideoGeneration.main))
            }
        }
    }
}

