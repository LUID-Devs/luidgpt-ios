//
//  SettingsView.swift
//  LuidGPT
//
//  Application settings and preferences
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var notificationsEnabled = true
    @State private var emailNotifications = true
    @State private var pushNotifications = false
    @State private var showingDeleteAccountAlert = false
    @State private var showingLogoutAlert = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            ScrollView {
                VStack(spacing: LGSpacing.lg) {
                    // Account Section
                    accountSection

                    // Preferences Section
                    preferencesSection

                    // Notifications Section
                    notificationsSection

                    // Privacy & Security Section
                    privacySection

                    // About Section
                    aboutSection

                    // Danger Zone
                    dangerZoneSection
                }
                .padding(LGSpacing.lg)
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.large)
    }

    // MARK: - Account Section

    private var accountSection: some View {
        VStack(alignment: .leading, spacing: LGSpacing.md) {
            Text("Account")
                .font(LGFonts.h3)
                .foregroundColor(.white)

            VStack(spacing: LGSpacing.xs) {
                if let user = authViewModel.currentUser {
                    SettingsRow(
                        icon: "person.circle",
                        title: "Full Name",
                        value: user.fullName,
                        showChevron: true
                    ) {
                        // Navigate to edit name
                    }

                    SettingsRow(
                        icon: "envelope",
                        title: "Email",
                        value: user.email,
                        showChevron: true
                    ) {
                        // Navigate to edit email
                    }
                }

                SettingsRow(
                    icon: "lock",
                    title: "Change Password",
                    showChevron: true
                ) {
                    // Navigate to change password
                }
            }
        }
    }

    // MARK: - Preferences Section

    private var preferencesSection: some View {
        VStack(alignment: .leading, spacing: LGSpacing.md) {
            Text("Preferences")
                .font(LGFonts.h3)
                .foregroundColor(.white)

            VStack(spacing: LGSpacing.xs) {
                SettingsRow(
                    icon: "paintpalette",
                    title: "Theme",
                    value: "Dark",
                    showChevron: true
                ) {
                    // Navigate to theme settings
                }

                SettingsRow(
                    icon: "globe",
                    title: "Language",
                    value: "English",
                    showChevron: true
                ) {
                    // Navigate to language settings
                }

                SettingsRow(
                    icon: "textformat.size",
                    title: "Text Size",
                    value: "Medium",
                    showChevron: true
                ) {
                    // Navigate to text size settings
                }
            }
        }
    }

    // MARK: - Notifications Section

    private var notificationsSection: some View {
        VStack(alignment: .leading, spacing: LGSpacing.md) {
            Text("Notifications")
                .font(LGFonts.h3)
                .foregroundColor(.white)

            VStack(spacing: LGSpacing.xs) {
                SettingsToggleRow(
                    icon: "bell.fill",
                    title: "Enable Notifications",
                    subtitle: "Receive updates about your generations",
                    isOn: $notificationsEnabled
                )

                if notificationsEnabled {
                    SettingsToggleRow(
                        icon: "envelope.fill",
                        title: "Email Notifications",
                        subtitle: "Get notified via email",
                        isOn: $emailNotifications
                    )

                    SettingsToggleRow(
                        icon: "iphone",
                        title: "Push Notifications",
                        subtitle: "Receive push notifications",
                        isOn: $pushNotifications
                    )
                }
            }
        }
    }

    // MARK: - Privacy Section

    private var privacySection: some View {
        VStack(alignment: .leading, spacing: LGSpacing.md) {
            Text("Privacy & Security")
                .font(LGFonts.h3)
                .foregroundColor(.white)

            VStack(spacing: LGSpacing.xs) {
                SettingsRow(
                    icon: "hand.raised.fill",
                    title: "Privacy Policy",
                    showChevron: true
                ) {
                    // Open privacy policy
                }

                SettingsRow(
                    icon: "doc.text",
                    title: "Terms of Service",
                    showChevron: true
                ) {
                    // Open terms of service
                }

                SettingsRow(
                    icon: "shield.fill",
                    title: "Data & Privacy",
                    showChevron: true
                ) {
                    // Navigate to data settings
                }
            }
        }
    }

    // MARK: - About Section

    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: LGSpacing.md) {
            Text("About")
                .font(LGFonts.h3)
                .foregroundColor(.white)

            VStack(spacing: LGSpacing.xs) {
                SettingsRow(
                    icon: "info.circle",
                    title: "Version",
                    value: "1.0.0"
                ) {}

                SettingsRow(
                    icon: "questionmark.circle",
                    title: "Help & Support",
                    showChevron: true
                ) {
                    // Navigate to help
                }

                SettingsRow(
                    icon: "star.fill",
                    title: "Rate App",
                    showChevron: true
                ) {
                    // Open App Store rating
                }

                SettingsRow(
                    icon: "bubble.left.and.bubble.right",
                    title: "Send Feedback",
                    showChevron: true
                ) {
                    // Open feedback form
                }
            }
        }
    }

    // MARK: - Danger Zone Section

    private var dangerZoneSection: some View {
        VStack(alignment: .leading, spacing: LGSpacing.md) {
            Text("Danger Zone")
                .font(LGFonts.h3)
                .foregroundColor(Color(white: 0.6))

            VStack(spacing: LGSpacing.xs) {
                Button(action: {
                    showingLogoutAlert = true
                }) {
                    HStack(spacing: LGSpacing.md) {
                        ZStack {
                            Circle()
                                .fill(Color(white: 0.15))
                                .frame(width: 40, height: 40)

                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .font(.system(size: 18))
                                .foregroundColor(Color(white: 0.6))
                        }

                        Text("Log Out")
                            .font(LGFonts.body)
                            .foregroundColor(Color(white: 0.6))

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.system(size: 14))
                            .foregroundColor(Color(white: 0.4))
                    }
                    .padding(LGSpacing.md)
                    .background(Color(white: 0.07))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
                }
                .alert("Log Out", isPresented: $showingLogoutAlert) {
                    Button("Cancel", role: .cancel) {}
                    Button("Log Out", role: .destructive) {
                        Task {
                            await authViewModel.logout()
                        }
                    }
                } message: {
                    Text("Are you sure you want to log out?")
                }

                Button(action: {
                    showingDeleteAccountAlert = true
                }) {
                    HStack(spacing: LGSpacing.md) {
                        ZStack {
                            Circle()
                                .fill(Color(white: 0.15))
                                .frame(width: 40, height: 40)

                            Image(systemName: "trash.fill")
                                .font(.system(size: 18))
                                .foregroundColor(Color(white: 0.4))
                        }

                        Text("Delete Account")
                            .font(LGFonts.body)
                            .foregroundColor(Color(white: 0.4))

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.system(size: 14))
                            .foregroundColor(Color(white: 0.4))
                    }
                    .padding(LGSpacing.md)
                    .background(Color(white: 0.07))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
                }
                .alert("Delete Account", isPresented: $showingDeleteAccountAlert) {
                    Button("Cancel", role: .cancel) {}
                    Button("Delete", role: .destructive) {
                        // Handle account deletion
                    }
                } message: {
                    Text("This action cannot be undone. All your data will be permanently deleted.")
                }
            }
        }
    }
}

// MARK: - Settings Row Component

struct SettingsRow: View {
    let icon: String
    let title: String
    var value: String? = nil
    var showChevron: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: LGSpacing.md) {
                ZStack {
                    Circle()
                        .fill(Color(white: 0.15))
                        .frame(width: 40, height: 40)

                    Image(systemName: icon)
                        .font(.system(size: 18))
                        .foregroundColor(.white)
                }

                Text(title)
                    .font(LGFonts.body)
                    .foregroundColor(.white)

                Spacer()

                if let value = value {
                    Text(value)
                        .font(LGFonts.small)
                        .foregroundColor(Color(white: 0.5))
                }

                if showChevron {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14))
                        .foregroundColor(Color(white: 0.4))
                }
            }
            .padding(LGSpacing.md)
            .background(Color(white: 0.07))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Settings Toggle Row Component

struct SettingsToggleRow: View {
    let icon: String
    let title: String
    var subtitle: String? = nil
    @Binding var isOn: Bool

    var body: some View {
        HStack(spacing: LGSpacing.md) {
            ZStack {
                Circle()
                    .fill(Color(white: 0.15))
                    .frame(width: 40, height: 40)

                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(LGFonts.body)
                    .foregroundColor(.white)

                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(LGFonts.small)
                        .foregroundColor(Color(white: 0.5))
                }
            }

            Spacer()

            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(Color(white: 0.5))
        }
        .padding(LGSpacing.md)
        .background(Color(white: 0.07))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
}

// MARK: - Preview

#if DEBUG
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SettingsView()
                .environmentObject(AuthViewModel())
        }
    }
}
#endif
