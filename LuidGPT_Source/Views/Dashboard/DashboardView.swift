//
//  DashboardView.swift
//  LuidGPT
//
//  Dashboard overview with stats, recent activity, and quick actions
//  Redesigned with elegant black & white aesthetic
//

import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var creditsViewModel: CreditsViewModel
    @StateObject private var generationsViewModel = GenerationsViewModel()
    @State private var recentGenerations: [ModelGeneration] = []
    @State private var isLoading = false

    var body: some View {
        ZStack {
            LGColors.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: LGSpacing.lg) {
                    // Stats Cards
                    statsSection

                    // Quick Actions
                    quickActionsSection

                    // Recent Activity
                    recentActivitySection
                }
                .padding(LGSpacing.lg)
            }
        }
        .navigationTitle("Dashboard")
        .navigationBarTitleDisplayMode(.large)
        .task {
            await loadDashboardData()
        }
    }

    // MARK: - Stats Section

    private var statsSection: some View {
        VStack(spacing: LGSpacing.md) {
            Text("Overview")
                .font(LGFonts.h3)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: LGSpacing.md) {
                StatCard(
                    icon: "sparkles",
                    title: "Credits",
                    value: "\(creditsViewModel.totalCredits)",
                    color: .white
                )

                StatCard(
                    icon: "photo.stack",
                    title: "Generations",
                    value: "\(recentGenerations.count)",
                    color: LGColors.ImageGeneration.main
                )
            }

            HStack(spacing: LGSpacing.md) {
                StatCard(
                    icon: "clock",
                    title: "This Month",
                    value: "\(monthlyCount)",
                    color: LGColors.AudioSpeech.main
                )

                StatCard(
                    icon: "checkmark.circle",
                    title: "Completed",
                    value: "\(completedCount)",
                    color: LGColors.TextGeneration.main
                )
            }
        }
    }

    // MARK: - Quick Actions

    private var quickActionsSection: some View {
        VStack(spacing: LGSpacing.md) {
            Text("Quick Actions")
                .font(LGFonts.h3)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: LGSpacing.sm) {
                NavigationLink(destination: HomeView()) {
                    QuickActionRow(
                        icon: "plus.circle.fill",
                        title: "New Generation",
                        subtitle: "Create AI content",
                        color: .white
                    )
                }

                NavigationLink(destination: UsageView()) {
                    QuickActionRow(
                        icon: "chart.bar.fill",
                        title: "View Usage",
                        subtitle: "Check credit usage",
                        color: LGColors.foregroundSecondary
                    )
                }

                NavigationLink(destination: BillingView()) {
                    QuickActionRow(
                        icon: "creditcard.fill",
                        title: "Manage Billing",
                        subtitle: "Subscription & payments",
                        color: LGColors.AudioSpeech.main
                    )
                }
            }
        }
    }

    // MARK: - Recent Activity

    private var recentActivitySection: some View {
        VStack(spacing: LGSpacing.md) {
            HStack {
                Text("Recent Activity")
                    .font(LGFonts.h3)
                    .foregroundColor(.white)

                Spacer()

                NavigationLink("View All", destination: GenerationsListView())
                    .font(LGFonts.small)
                    .foregroundColor(LGColors.foregroundSecondary)
            }

            if isLoading {
                ProgressView()
                    .padding(LGSpacing.xl)
                    .tint(.white)
            } else if recentGenerations.isEmpty {
                VStack(spacing: LGSpacing.md) {
                    Image(systemName: "tray")
                        .font(.system(size: 48))
                        .foregroundColor(LGColors.foregroundTertiary)

                    Text("No recent activity")
                        .font(LGFonts.body)
                        .foregroundColor(LGColors.foregroundSecondary)

                    NavigationLink(destination: HomeView()) {
                        LGButton("Create Your First Generation", style: .primary, fullWidth: false) {
                            // Navigation handled by NavigationLink
                        }
                    }
                }
                .padding(LGSpacing.xl)
                .frame(maxWidth: .infinity)
                .background(LGColors.backgroundCard)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(LGColors.border, lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
            } else {
                VStack(spacing: LGSpacing.sm) {
                    ForEach(recentGenerations.prefix(5)) { generation in
                        NavigationLink(destination: GenerationDetailView(generation: generation, viewModel: generationsViewModel)) {
                            GenerationRow(generation: generation)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Helpers

    private var monthlyCount: Int {
        // Filter generations from this month
        let calendar = Calendar.current
        let now = Date()
        return recentGenerations.filter { generation in
            guard let date = ISO8601DateFormatter().date(from: generation.createdAt) else { return false }
            return calendar.isDate(date, equalTo: now, toGranularity: .month)
        }.count
    }

    private var completedCount: Int {
        recentGenerations.filter { $0.status == .completed }.count
    }

    private func loadDashboardData() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let (generations, _) = try await ModelsAPIService.shared.fetchGenerations(
                page: 1,
                limit: 10
            )
            recentGenerations = generations
            await creditsViewModel.fetchBalance()
        } catch {
            print("Error loading dashboard data: \(error)")
        }
    }
}

// MARK: - Stat Card

struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: LGSpacing.sm) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(color)

                Spacer()
            }

            Text(value)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)

            Text(title)
                .font(LGFonts.small)
                .foregroundColor(LGColors.foregroundSecondary)
        }
        .padding(LGSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(LGColors.backgroundCard)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(LGColors.border, lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Quick Action Row

struct QuickActionRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color

    var body: some View {
        HStack(spacing: LGSpacing.md) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 48, height: 48)
                    .overlay(
                        Circle()
                            .stroke(color.opacity(0.3), lineWidth: 1)
                    )

                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(LGFonts.body.weight(.semibold))
                    .foregroundColor(.white)

                Text(subtitle)
                    .font(LGFonts.small)
                    .foregroundColor(LGColors.foregroundSecondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundColor(LGColors.foregroundTertiary)
        }
        .padding(LGSpacing.md)
        .background(LGColors.backgroundCard)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(LGColors.border, lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.3), radius: 6, x: 0, y: 3)
    }
}

// MARK: - Generation Row

struct GenerationRow: View {
    let generation: ModelGeneration

    var body: some View {
        HStack(spacing: LGSpacing.md) {
            // Status icon
            ZStack {
                Circle()
                    .fill(statusColor.opacity(0.15))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Circle()
                            .stroke(statusColor.opacity(0.3), lineWidth: 1)
                    )

                Image(systemName: statusIcon)
                    .font(.system(size: 16))
                    .foregroundColor(statusColor)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(generation.title ?? generation.modelId)
                    .font(LGFonts.body.weight(.semibold))
                    .foregroundColor(.white)
                    .lineLimit(1)

                Text(timeAgo)
                    .font(LGFonts.small)
                    .foregroundColor(LGColors.foregroundSecondary)
            }

            Spacer()

            Text("\(generation.creditsUsed)")
                .font(LGFonts.small.weight(.medium))
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.white.opacity(0.1))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )

            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundColor(LGColors.foregroundTertiary)
        }
        .padding(LGSpacing.md)
        .background(LGColors.backgroundCard)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(LGColors.border, lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.3), radius: 6, x: 0, y: 3)
    }

    private var statusColor: Color {
        switch generation.status {
        case .completed: return LGColors.success
        case .processing: return LGColors.warning
        case .failed: return LGColors.error
        default: return LGColors.neutral500
        }
    }

    private var statusIcon: String {
        switch generation.status {
        case .completed: return "checkmark.circle.fill"
        case .processing: return "clock.fill"
        case .failed: return "xmark.circle.fill"
        default: return "circle.fill"
        }
    }

    private var timeAgo: String {
        guard let date = ISO8601DateFormatter().date(from: generation.createdAt) else {
            return "Recently"
        }

        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - Preview

#if DEBUG
struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DashboardView()
                .environmentObject(CreditsViewModel())
        }
        .preferredColorScheme(.dark)
    }
}
#endif
