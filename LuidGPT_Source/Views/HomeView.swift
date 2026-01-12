//
//  HomeView.swift
//  LuidGPT
//
//  Home dashboard with user info, credits, categories, and featured models
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var creditsViewModel: CreditsViewModel
    @State private var isLoadingCategories = false
    @State private var categories: [Category] = []
    @State private var featuredModels: [ReplicateModel] = []

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // User greeting section
                    greetingSection
                        .padding(.horizontal, LGSpacing.lg)
                        .padding(.top, LGSpacing.md)

                    // Credit balance card
                    creditBalanceCard
                        .padding(.horizontal, LGSpacing.lg)

                    // Categories section
                    categoriesSection
                        .padding(.top, 8)

                    // Featured models section
                    featuredModelsSection
                        .padding(.top, 8)

                    Spacer(minLength: 40)
                }
            }
            .background(LGColors.background.ignoresSafeArea())
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    creditBalanceBadge
                }
            }
            .task {
                await loadData()
            }
            .refreshable {
                await refreshData()
            }
        }
    }

    // MARK: - Greeting Section

    private var greetingSection: some View {
        HStack(spacing: 16) {
            // User avatar
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
                        .frame(width: 50, height: 50)

                    Text(user.initials)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(timeBasedGreeting)
                        .font(LGFonts.label)
                        .foregroundColor(LGColors.neutral400)

                    Text(user.fullName)
                        .font(LGFonts.h3)
                        .foregroundColor(LGColors.foreground)
                }
            }

            Spacer()
        }
    }

    // MARK: - Credit Balance Badge (Toolbar)

    private var creditBalanceBadge: some View {
        HStack(spacing: 6) {
            Image(systemName: "sparkles")
                .font(.system(size: 14, weight: .semibold))

            if creditsViewModel.isLoading && creditsViewModel.balance == nil {
                ProgressView()
                    .scaleEffect(0.7)
            } else {
                Text("\(creditsViewModel.totalCredits)")
                    .font(.system(size: 16, weight: .bold))
            }
        }
        .foregroundColor(creditsViewModel.isLowBalance ? LGColors.warningText : LGColors.VideoGeneration.main)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(LGColors.neutral900)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(creditsViewModel.isLowBalance ? LGColors.warningText.opacity(0.3) : LGColors.neutral800, lineWidth: 1)
                )
        )
    }

    // MARK: - Credit Balance Card

    private var creditBalanceCard: some View {
        VStack(spacing: 0) {
            // Card content
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Credits")
                        .font(LGFonts.label)
                        .foregroundColor(LGColors.neutral400)

                    if let balance = creditsViewModel.balance {
                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                            Text("\(balance.totalCredits)")
                                .font(.system(size: 36, weight: .bold))
                                .foregroundColor(LGColors.foreground)

                            Text("credits")
                                .font(LGFonts.body)
                                .foregroundColor(LGColors.neutral500)
                        }

                        // Credit breakdown
                        VStack(alignment: .leading, spacing: 4) {
                            if balance.subscriptionCredits > 0 {
                                creditBreakdownRow(
                                    label: "Subscription",
                                    amount: balance.subscriptionCredits,
                                    color: LGColors.VideoGeneration.main
                                )
                            }
                            if balance.purchasedCredits > 0 {
                                creditBreakdownRow(
                                    label: "Purchased",
                                    amount: balance.purchasedCredits,
                                    color: LGColors.ImageGeneration.main
                                )
                            }
                            if balance.promotionalCredits > 0 {
                                creditBreakdownRow(
                                    label: "Promotional",
                                    amount: balance.promotionalCredits,
                                    color: Color.green
                                )
                            }
                        }
                        .padding(.top, 4)

                        // Low credits warning
                        if creditsViewModel.isLowBalance {
                            HStack(spacing: 6) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.caption)

                                Text("Low balance")
                                    .font(LGFonts.small)
                            }
                            .foregroundColor(LGColors.warningText)
                            .padding(.top, 4)
                        }
                    } else if creditsViewModel.isLoading {
                        ProgressView()
                            .padding(.top, 8)
                    } else {
                        Text("Unable to load balance")
                            .font(LGFonts.body)
                            .foregroundColor(LGColors.neutral500)
                    }
                }

                Spacer()

                // Buy credits button
                Button(action: {
                    // TODO: Navigate to credits purchase
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "plus.circle.fill")
                        Text("Buy")
                    }
                    .font(LGFonts.small.weight(.semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        LinearGradient(
                            colors: [
                                LGColors.VideoGeneration.main,
                                LGColors.ImageGeneration.main
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(20)
                }
            }
            .padding(LGSpacing.lg)
        }
        .background(LGColors.neutral900)
        .cornerRadius(LGSpacing.cardRadius)
        .overlay(
            RoundedRectangle(cornerRadius: LGSpacing.cardRadius)
                .stroke(LGColors.neutral800, lineWidth: 1)
        )
    }

    // Credit breakdown row helper
    private func creditBreakdownRow(label: String, amount: Int, color: Color) -> some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 6, height: 6)

            Text(label)
                .font(LGFonts.small)
                .foregroundColor(LGColors.neutral500)

            Text("\(amount)")
                .font(LGFonts.small.weight(.semibold))
                .foregroundColor(LGColors.neutral400)
        }
    }

    // MARK: - Categories Section

    private var categoriesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Categories")
                .font(LGFonts.h3)
                .foregroundColor(LGColors.foreground)
                .padding(.horizontal, LGSpacing.lg)

            // Categories grid
            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: 12),
                    GridItem(.flexible(), spacing: 12)
                ],
                spacing: 12
            ) {
                ForEach(mockCategories, id: \.id) { category in
                    CategoryCard(category: category)
                }
            }
            .padding(.horizontal, LGSpacing.lg)
        }
    }

    // MARK: - Featured Models Section

    private var featuredModelsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Featured Models")
                    .font(LGFonts.h3)
                    .foregroundColor(LGColors.foreground)

                Spacer()

                Button(action: {
                    // TODO: Navigate to all models
                }) {
                    Text("See all")
                        .font(LGFonts.small)
                        .foregroundColor(LGColors.VideoGeneration.main)
                }
            }
            .padding(.horizontal, LGSpacing.lg)

            // Featured models carousel
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(mockFeaturedModels, id: \.id) { model in
                        FeaturedModelCard(model: model)
                    }
                }
                .padding(.horizontal, LGSpacing.lg)
            }
        }
    }

    // MARK: - Helpers

    private var timeBasedGreeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12:
            return "Good morning"
        case 12..<17:
            return "Good afternoon"
        default:
            return "Good evening"
        }
    }

    private func loadData() async {
        isLoadingCategories = true

        // Fetch credit balance from Luidhub
        await creditsViewModel.fetchBalance()

        // TODO: Load categories and featured models from API
        // For now, using mock data

        isLoadingCategories = false
    }

    private func refreshData() async {
        // Refresh credit balance
        await creditsViewModel.refreshBalance()

        // TODO: Refresh categories and featured models
    }

    // MARK: - Mock Data

    private var mockCategories: [CategoryInfo] = [
        CategoryInfo(id: "video", name: "Video", icon: "video.fill", gradient: [LGColors.VideoGeneration.main, Color.purple]),
        CategoryInfo(id: "image", name: "Image", icon: "photo.fill", gradient: [LGColors.ImageGeneration.main, Color.pink]),
        CategoryInfo(id: "text-to-speech", name: "Text to Speech", icon: "speaker.wave.3.fill", gradient: [Color.blue, Color.cyan]),
        CategoryInfo(id: "image-editing", name: "Image Editing", icon: "paintbrush.fill", gradient: [Color.orange, Color.yellow]),
        CategoryInfo(id: "music", name: "Music", icon: "music.note", gradient: [Color.green, Color.mint]),
        CategoryInfo(id: "voice", name: "Voice Clone", icon: "waveform", gradient: [Color.yellow, Color.orange]),
        CategoryInfo(id: "3d", name: "3D Models", icon: "cube.fill", gradient: [Color.cyan, Color.blue]),
        CategoryInfo(id: "upscaling", name: "Upscaling", icon: "arrow.up.right.square.fill", gradient: [Color.red, Color.pink]),
        CategoryInfo(id: "face", name: "Face & Avatar", icon: "person.crop.circle.fill", gradient: [Color.indigo, Color.purple]),
        CategoryInfo(id: "background", name: "Background Removal", icon: "scissors", gradient: [Color.teal, Color.green]),
        CategoryInfo(id: "video-editing", name: "Video Editing", icon: "film.fill", gradient: [Color.purple, Color.pink])
    ]

    private var mockFeaturedModels: [FeaturedModelInfo] = [
        FeaturedModelInfo(id: "1", name: "Sora 2", description: "Text to video", icon: "video.fill", color: LGColors.VideoGeneration.main),
        FeaturedModelInfo(id: "2", name: "FLUX 1.1 Pro", description: "Ultra-fast images", icon: "bolt.fill", color: LGColors.ImageGeneration.main),
        FeaturedModelInfo(id: "3", name: "DALL-E 3", description: "Creative images", icon: "photo.fill", color: Color.blue),
        FeaturedModelInfo(id: "4", name: "Stable Audio", description: "Music generation", icon: "music.note", color: Color.green)
    ]
}

// MARK: - Category Card

struct CategoryCard: View {
    let category: CategoryInfo

    var body: some View {
        Button(action: {
            // TODO: Navigate to category models
        }) {
            VStack(spacing: 12) {
                // Icon with gradient background
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: category.gradient,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 50, height: 50)

                    Image(systemName: category.icon)
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                }

                Text(category.name)
                    .font(LGFonts.body.weight(.semibold))
                    .foregroundColor(LGColors.foreground)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(LGColors.neutral900)
            .cornerRadius(LGSpacing.cardRadius)
            .overlay(
                RoundedRectangle(cornerRadius: LGSpacing.cardRadius)
                    .stroke(LGColors.neutral800, lineWidth: 1)
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - Featured Model Card

struct FeaturedModelCard: View {
    let model: FeaturedModelInfo

    var body: some View {
        Button(action: {
            // TODO: Navigate to model details
        }) {
            VStack(alignment: .leading, spacing: 12) {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(model.color.opacity(0.2))
                        .frame(width: 60, height: 60)

                    Image(systemName: model.icon)
                        .font(.system(size: 28))
                        .foregroundColor(model.color)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(model.name)
                        .font(LGFonts.body.weight(.semibold))
                        .foregroundColor(LGColors.foreground)

                    Text(model.description)
                        .font(LGFonts.small)
                        .foregroundColor(LGColors.neutral400)
                }

                Spacer()

                HStack {
                    Image(systemName: "sparkles")
                        .font(.caption)
                    Text("Popular")
                        .font(LGFonts.caption)
                }
                .foregroundColor(LGColors.VideoGeneration.main)
            }
            .frame(width: 140)
            .padding(16)
            .background(LGColors.neutral900)
            .cornerRadius(LGSpacing.cardRadius)
            .overlay(
                RoundedRectangle(cornerRadius: LGSpacing.cardRadius)
                    .stroke(LGColors.neutral800, lineWidth: 1)
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - Scale Button Style

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

// MARK: - Helper Models

struct CategoryInfo {
    let id: String
    let name: String
    let icon: String
    let gradient: [Color]
}

struct FeaturedModelInfo {
    let id: String
    let name: String
    let description: String
    let icon: String
    let color: Color
}

// MARK: - Preview

#if DEBUG
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(AuthViewModel())
            .environmentObject(CreditsViewModel())
    }
}
#endif
