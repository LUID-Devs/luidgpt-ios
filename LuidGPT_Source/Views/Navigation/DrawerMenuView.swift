//
//  DrawerMenuView.swift
//  LuidGPT
//
//  Professional slide-out drawer navigation menu
//  Matches luidgpt-frontend mobile menu design
//

import SwiftUI

enum DrawerDestination: Identifiable {
    case home, dashboard, usage, workspaces, profile, billing, settings

    var id: String {
        switch self {
        case .home: return "home"
        case .dashboard: return "dashboard"
        case .usage: return "usage"
        case .workspaces: return "workspaces"
        case .profile: return "profile"
        case .billing: return "billing"
        case .settings: return "settings"
        }
    }
}

struct DrawerMenuView: View {
    @Binding var isOpen: Bool
    @Binding var destination: DrawerDestination?
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var creditsViewModel: CreditsViewModel

    var body: some View {
        ZStack {
            // Background overlay
            if isOpen {
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isOpen = false
                        }
                    }
            }

            // Drawer content
            HStack(spacing: 0) {
                // Menu panel
                VStack(spacing: 0) {
                    // Header
                    drawerHeader

                    // Content
                    ScrollView {
                        VStack(spacing: 0) {
                            // Credit Balance
                            creditBalanceSection

                            Divider()
                                .background(LGColors.neutral200)
                                .padding(.vertical, LGSpacing.md)

                            // Navigation Links
                            navigationSection

                            Divider()
                                .background(LGColors.neutral200)
                                .padding(.vertical, LGSpacing.md)

                            // User Actions
                            userActionsSection
                        }
                        .padding(.horizontal, LGSpacing.lg)
                    }

                    Spacer()

                    // User Info Footer
                    userInfoFooter
                }
                .frame(width: 280)
                .background(Color.white)
                .offset(x: isOpen ? 0 : -280)
                .animation(.easeInOut(duration: 0.3), value: isOpen)

                Spacer()
            }
        }
    }

    // MARK: - Header

    private var drawerHeader: some View {
        HStack {
            Text("LuidGPT")
                .font(LGFonts.h3)
                .foregroundColor(.black)

            Spacer()

            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isOpen = false
                }
            }) {
                Image(systemName: "xmark")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.black)
                    .padding(8)
            }
        }
        .padding(.horizontal, LGSpacing.lg)
        .padding(.vertical, LGSpacing.md)
        .background(Color.white)
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(LGColors.neutral200),
            alignment: .bottom
        )
    }

    // MARK: - Credit Balance Section

    private var creditBalanceSection: some View {
        Button(action: {
            isOpen = false
            destination = .usage
        }) {
            HStack(spacing: LGSpacing.md) {
                Image(systemName: "sparkles")
                    .font(.system(size: 20))
                    .foregroundColor(LGColors.VideoGeneration.main)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Credits")
                        .font(LGFonts.small)
                        .foregroundColor(LGColors.neutral600)

                    if creditsViewModel.isLoading {
                        ProgressView()
                            .scaleEffect(0.8)
                    } else {
                        Text("\(creditsViewModel.totalCredits)")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.black)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(LGColors.neutral400)
            }
            .padding(LGSpacing.md)
            .background(LGColors.neutral100)
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }

    // MARK: - Navigation Section

    private var navigationSection: some View {
        VStack(spacing: LGSpacing.xs) {
            DrawerMenuButton(
                icon: "sparkles",
                title: "AI Models",
                isOpen: $isOpen,
                destination: $destination,
                target: .home
            )

            DrawerMenuButton(
                icon: "square.grid.2x2",
                title: "Dashboard",
                isOpen: $isOpen,
                destination: $destination,
                target: .dashboard
            )

            DrawerMenuButton(
                icon: "chart.bar",
                title: "Usage",
                isOpen: $isOpen,
                destination: $destination,
                target: .usage
            )

            DrawerMenuButton(
                icon: "building.2",
                title: "Workspaces",
                isOpen: $isOpen,
                destination: $destination,
                target: .workspaces
            )
        }
    }

    // MARK: - User Actions Section

    private var userActionsSection: some View {
        VStack(spacing: LGSpacing.xs) {
            DrawerMenuButton(
                icon: "person",
                title: "Profile",
                isOpen: $isOpen,
                destination: $destination,
                target: .profile
            )

            DrawerMenuButton(
                icon: "creditcard",
                title: "Billing",
                isOpen: $isOpen,
                destination: $destination,
                target: .billing
            )

            DrawerMenuButton(
                icon: "gearshape",
                title: "Settings",
                isOpen: $isOpen,
                destination: $destination,
                target: .settings
            )

            Button(action: {
                Task {
                    await authViewModel.logout()
                }
            }) {
                HStack(spacing: LGSpacing.sm) {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .font(.system(size: 20))
                        .foregroundColor(.red)

                    Text("Logout")
                        .font(LGFonts.body)
                        .foregroundColor(.red)

                    Spacer()
                }
                .padding(.vertical, LGSpacing.md)
                .padding(.horizontal, LGSpacing.sm)
                .background(Color.white)
                .cornerRadius(8)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }

    // MARK: - User Info Footer

    private var userInfoFooter: some View {
        VStack(spacing: 0) {
            Rectangle()
                .frame(height: 1)
                .foregroundColor(LGColors.neutral200)

            if let user = authViewModel.currentUser {
                HStack(spacing: LGSpacing.md) {
                    // Avatar
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
                            .frame(width: 48, height: 48)

                        Text(user.initials)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(user.fullName)
                            .font(LGFonts.body.weight(.semibold))
                            .foregroundColor(.black)
                            .lineLimit(1)

                        Text(user.email)
                            .font(LGFonts.small)
                            .foregroundColor(LGColors.neutral600)
                            .lineLimit(1)
                    }

                    Spacer()
                }
                .padding(LGSpacing.lg)
                .background(Color.white)
            }
        }
    }
}

// MARK: - Drawer Menu Button

struct DrawerMenuButton: View {
    let icon: String
    let title: String
    @Binding var isOpen: Bool
    @Binding var destination: DrawerDestination?
    let target: DrawerDestination

    var body: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.3)) {
                isOpen = false
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                destination = target
            }
        }) {
            HStack(spacing: LGSpacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(LGColors.neutral700)
                    .frame(width: 24)

                Text(title)
                    .font(LGFonts.body)
                    .foregroundColor(.black)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(LGColors.neutral400)
            }
            .padding(.vertical, LGSpacing.md)
            .padding(.horizontal, LGSpacing.sm)
            .background(Color.white)
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview

#if DEBUG
struct DrawerMenuView_Previews: PreviewProvider {
    static var previews: some View {
        DrawerMenuView(isOpen: .constant(true), destination: .constant(nil))
            .environmentObject(AuthViewModel())
            .environmentObject(CreditsViewModel())
    }
}
#endif
