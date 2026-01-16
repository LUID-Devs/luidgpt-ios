//
//  ProfileView.swift
//  LuidGPT
//
//  User profile and account information
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var isEditingProfile = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            ScrollView {
                VStack(spacing: LGSpacing.lg) {
                    // Profile Header
                    profileHeader

                    // Account Information
                    accountInformationSection

                    // Statistics
                    statisticsSection

                    // Quick Actions
                    quickActionsSection
                }
                .padding(LGSpacing.lg)
            }
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    isEditingProfile = true
                }) {
                    Text("Edit")
                        .font(LGFonts.body)
                        .foregroundColor(.white)
                }
            }
        }
        .sheet(isPresented: $isEditingProfile) {
            EditProfileSheet()
        }
    }

    // MARK: - Profile Header

    private var profileHeader: some View {
        VStack(spacing: LGSpacing.md) {
            if let user = authViewModel.currentUser {
                // Avatar with grayscale gradient
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white,
                                    Color(white: 0.7)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 100, height: 100)

                    Text(user.initials)
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.black)
                }

                // User Info
                VStack(spacing: 4) {
                    Text(user.fullName)
                        .font(LGFonts.h2)
                        .foregroundColor(.white)

                    Text(user.email)
                        .font(LGFonts.body)
                        .foregroundColor(Color(white: 0.6))
                }

                // Member Since
                Text("Member since \(formatDateShort(user.createdAt))")
                    .font(LGFonts.small)
                    .foregroundColor(Color(white: 0.5))
            }
        }
        .padding(LGSpacing.xl)
        .frame(maxWidth: .infinity)
        .background(Color(white: 0.07))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }

    // MARK: - Account Information

    private var accountInformationSection: some View {
        VStack(alignment: .leading, spacing: LGSpacing.md) {
            Text("Account Information")
                .font(LGFonts.h3)
                .foregroundColor(.white)

            VStack(spacing: LGSpacing.xs) {
                if let user = authViewModel.currentUser {
                    ProfileInfoRow(
                        icon: "person.fill",
                        title: "Full Name",
                        value: user.fullName
                    )

                    ProfileInfoRow(
                        icon: "envelope.fill",
                        title: "Email",
                        value: user.email
                    )

                    ProfileInfoRow(
                        icon: "calendar",
                        title: "Joined",
                        value: formatDateLong(user.createdAt)
                    )

                    ProfileInfoRow(
                        icon: "key.fill",
                        title: "Account ID",
                        value: String(user.id.prefix(8)) + "..."
                    )
                }
            }
        }
    }

    // MARK: - Statistics Section

    private var statisticsSection: some View {
        VStack(alignment: .leading, spacing: LGSpacing.md) {
            Text("Your Statistics")
                .font(LGFonts.h3)
                .foregroundColor(.white)

            HStack(spacing: LGSpacing.sm) {
                ProfileStatCard(
                    icon: "photo.stack",
                    title: "Generations",
                    value: "142"
                )

                ProfileStatCard(
                    icon: "sparkles",
                    title: "Credits Used",
                    value: "3.2K"
                )
            }

            HStack(spacing: LGSpacing.sm) {
                ProfileStatCard(
                    icon: "heart.fill",
                    title: "Favorites",
                    value: "28"
                )

                ProfileStatCard(
                    icon: "building.2",
                    title: "Workspaces",
                    value: "2"
                )
            }
        }
    }

    // MARK: - Quick Actions

    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: LGSpacing.md) {
            Text("Quick Actions")
                .font(LGFonts.h3)
                .foregroundColor(.white)

            VStack(spacing: LGSpacing.xs) {
                NavigationLink(destination: UsageView()) {
                    ProfileActionRow(
                        icon: "chart.bar",
                        title: "View Usage"
                    )
                }

                NavigationLink(destination: BillingView()) {
                    ProfileActionRow(
                        icon: "creditcard",
                        title: "Manage Billing"
                    )
                }

                NavigationLink(destination: SettingsView()) {
                    ProfileActionRow(
                        icon: "gearshape",
                        title: "Settings"
                    )
                }

                NavigationLink(destination: GenerationsListView()) {
                    ProfileActionRow(
                        icon: "photo.on.rectangle",
                        title: "My Generations"
                    )
                }
            }
        }
    }

    // MARK: - Helpers

    private func formatDateShort(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        return formatter.string(from: date)
    }

    private func formatDateLong(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: date)
    }
}

// MARK: - Profile Info Row

struct ProfileInfoRow: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        HStack(spacing: LGSpacing.md) {
            ZStack {
                Circle()
                    .fill(Color(white: 0.15))
                    .frame(width: 40, height: 40)

                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(LGFonts.small)
                    .foregroundColor(Color(white: 0.5))

                Text(value)
                    .font(LGFonts.body)
                    .foregroundColor(.white)
            }

            Spacer()
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

// MARK: - Profile Stat Card

struct ProfileStatCard: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: LGSpacing.sm) {
            ZStack {
                Circle()
                    .fill(Color(white: 0.15))
                    .frame(width: 48, height: 48)

                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(.white)
            }

            Text(value)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)

            Text(title)
                .font(LGFonts.small)
                .foregroundColor(Color(white: 0.5))
        }
        .frame(maxWidth: .infinity)
        .padding(LGSpacing.md)
        .background(Color(white: 0.07))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
}

// MARK: - Profile Action Row

struct ProfileActionRow: View {
    let icon: String
    let title: String

    var body: some View {
        HStack(spacing: LGSpacing.md) {
            ZStack {
                Circle()
                    .fill(Color(white: 0.15))
                    .frame(width: 40, height: 40)

                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(.white)
            }

            Text(title)
                .font(LGFonts.body)
                .foregroundColor(.white)

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
}

// MARK: - Edit Profile Sheet

struct EditProfileSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var fullName = ""
    @State private var email = ""

    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()

                VStack(spacing: LGSpacing.lg) {
                    VStack(alignment: .leading, spacing: LGSpacing.sm) {
                        Text("Full Name")
                            .font(LGFonts.body.weight(.semibold))
                            .foregroundColor(.white)

                        TextField("Enter your full name", text: $fullName)
                            .font(LGFonts.body)
                            .foregroundColor(.white)
                            .padding(LGSpacing.md)
                            .background(Color(white: 0.07))
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                            )
                    }

                    VStack(alignment: .leading, spacing: LGSpacing.sm) {
                        Text("Email")
                            .font(LGFonts.body.weight(.semibold))
                            .foregroundColor(.white)

                        TextField("Enter your email", text: $email)
                            .font(LGFonts.body)
                            .foregroundColor(.white)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .padding(LGSpacing.md)
                            .background(Color(white: 0.07))
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                            )
                    }

                    Button(action: {
                        // TODO: Update profile via API
                        dismiss()
                    }) {
                        Text("Save Changes")
                            .font(LGFonts.body.weight(.semibold))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, LGSpacing.md)
                            .background(.white)
                            .cornerRadius(10)
                    }

                    Spacer()
                }
                .padding(LGSpacing.lg)
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
        .onAppear {
            if let user = authViewModel.currentUser {
                fullName = user.fullName
                email = user.email
            }
        }
    }
}

// MARK: - Preview

#if DEBUG
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ProfileView()
                .environmentObject(AuthViewModel())
        }
    }
}
#endif
