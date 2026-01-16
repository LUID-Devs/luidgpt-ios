//
//  HomeView.swift
//  LuidGPT
//
//  Home screen with trending models, category tabs, filters, and Replicate models grid
//  Redesigned with premium black & white aesthetic
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var creditsViewModel: CreditsViewModel
    @StateObject private var modelsViewModel = ModelsViewModel()

    // State
    @State private var selectedCategory: String = "all"
    @State private var showFilters = false
    @State private var selectedStyles: Set<String> = []
    @State private var selectedSpeed: String? = nil
    @State private var selectedQuality: String? = nil

    // Filter options
    let styleOptions = ["Photorealistic", "Artistic", "Anime", "Cinematic", "3D Render", "Illustration"]
    let speedOptions = ["Instant (<5s)", "Fast (5-30s)", "Standard (30s-2m)", "Slow (2m+)"]
    let qualityOptions = ["Best Quality", "Balanced", "Draft"]

    var body: some View {
        ZStack(alignment: .top) {
            LGColors.background
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    // Header with credits
                    headerSection
                        .padding(.horizontal, LGSpacing.lg)
                        .padding(.top, 8)
                        .padding(.bottom, 12)

                    // Trending Now Section
                    if selectedCategory == "all" {
                        trendingSection
                            .padding(.top, 8)
                    }

                    // Category Tabs
                    categoryTabsSection
                        .padding(.top, 16)

                    // Filters Button
                    filtersButton
                        .padding(.horizontal, LGSpacing.lg)
                        .padding(.top, 12)

                    // Filters Section (expandable)
                    if showFilters {
                        filtersSection
                            .padding(.horizontal, LGSpacing.lg)
                            .padding(.top, 12)
                            .transition(.opacity)
                    }

                    // Models Grid
                    modelsGridSection
                        .padding(.horizontal, LGSpacing.lg)
                        .padding(.top, 16)
                }
                .padding(.bottom, 24)
            }
            .task {
                await loadData()
            }
            .refreshable {
                await refreshData()
            }
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        HStack {
            // User info
            if let user = authViewModel.currentUser {
                VStack(alignment: .leading, spacing: 4) {
                    Text(timeBasedGreeting)
                        .font(LGFonts.label)
                        .foregroundColor(LGColors.foregroundTertiary)

                    Text(user.fullName)
                        .font(LGFonts.h3)
                        .foregroundColor(.white)
                }
            }

            Spacer()

            // Credit balance badge
            creditBalanceBadge
        }
    }

    private var creditBalanceBadge: some View {
        HStack(spacing: 6) {
            Image(systemName: "sparkles")
                .font(.system(size: 14, weight: .semibold))

            if creditsViewModel.isLoading && creditsViewModel.balance == nil {
                ProgressView()
                    .scaleEffect(0.7)
                    .tint(.white)
            } else {
                Text("\(creditsViewModel.totalCredits)")
                    .font(.system(size: 16, weight: .bold))
            }
        }
        .foregroundColor(creditsViewModel.isLowBalance ? LGColors.warningText : .white)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(creditsViewModel.isLowBalance ? LGColors.warningBg : Color.white.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(creditsViewModel.isLowBalance ? LGColors.warningBorder : Color.white.opacity(0.2), lineWidth: 1)
                )
        )
    }

    // MARK: - Trending Now Section

    private var trendingSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "flame.fill")
                    .foregroundColor(.white)
                Text("Trending Now")
                    .font(LGFonts.h4)
                    .foregroundColor(.white)
                Spacer()
            }
            .padding(.horizontal, LGSpacing.lg)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(Array(modelsViewModel.featuredModels.prefix(10).enumerated()), id: \.element.id) { index, model in
                        TrendingModelCard(model: model, rank: index + 1)
                    }
                }
                .padding(.horizontal, LGSpacing.lg)
            }
        }
    }

    // MARK: - Category Tabs

    private var categoryTabsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Browse by Category")
                .font(LGFonts.h4)
                .foregroundColor(.white)
                .padding(.horizontal, LGSpacing.lg)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    CategoryTab(title: "All Models", isSelected: selectedCategory == "all") {
                        selectedCategory = "all"
                        Task {
                            await modelsViewModel.fetchModelsByCategory(slug: nil, page: 1)
                        }
                    }

                    ForEach(categories, id: \.slug) { category in
                        CategoryTab(
                            title: category.name,
                            count: modelsViewModel.categories.first(where: { $0.slug == category.slug })?.modelCountInt,
                            isSelected: selectedCategory == category.slug
                        ) {
                            selectedCategory = category.slug
                            Task {
                                await modelsViewModel.fetchModelsByCategory(slug: category.slug, page: 1)
                            }
                        }
                    }
                }
                .padding(.horizontal, LGSpacing.lg)
            }
        }
    }

    // MARK: - Filters

    private var filtersButton: some View {
        Button(action: {
            withAnimation {
                showFilters.toggle()
            }
        }) {
            HStack {
                Image(systemName: "slider.horizontal.3")
                    .foregroundColor(.white)
                Text("Filters")
                    .font(LGFonts.body)
                    .foregroundColor(.white)

                Spacer()

                if !selectedStyles.isEmpty || selectedSpeed != nil || selectedQuality != nil {
                    let count = selectedStyles.count + (selectedSpeed != nil ? 1 : 0) + (selectedQuality != nil ? 1 : 0)
                    Text("\(count)")
                        .font(LGFonts.small)
                        .foregroundColor(.black)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(.white)
                        .cornerRadius(10)
                }

                Image(systemName: showFilters ? "chevron.up" : "chevron.down")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(LGColors.foregroundSecondary)
            }
            .padding()
            .background(LGColors.backgroundCard)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(LGColors.border, lineWidth: 1)
            )
        }
    }

    private var filtersSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Style Filter
            FilterGroup(title: "Style") {
                FlowLayout(spacing: 8) {
                    ForEach(styleOptions, id: \.self) { style in
                        FilterChip(
                            title: style,
                            isSelected: selectedStyles.contains(style)
                        ) {
                            if selectedStyles.contains(style) {
                                selectedStyles.remove(style)
                            } else {
                                selectedStyles.insert(style)
                            }
                            applyFilters()
                        }
                    }
                }
            }

            // Speed Filter
            FilterGroup(title: "Speed") {
                FlowLayout(spacing: 8) {
                    ForEach(speedOptions, id: \.self) { speed in
                        FilterChip(
                            title: speed,
                            isSelected: selectedSpeed == speed
                        ) {
                            selectedSpeed = selectedSpeed == speed ? nil : speed
                            applyFilters()
                        }
                    }
                }
            }

            // Quality Filter
            FilterGroup(title: "Quality") {
                FlowLayout(spacing: 8) {
                    ForEach(qualityOptions, id: \.self) { quality in
                        FilterChip(
                            title: quality,
                            isSelected: selectedQuality == quality
                        ) {
                            selectedQuality = selectedQuality == quality ? nil : quality
                            applyFilters()
                        }
                    }
                }
            }

            // Clear Filters Button
            if !selectedStyles.isEmpty || selectedSpeed != nil || selectedQuality != nil {
                Button(action: clearFilters) {
                    HStack {
                        Image(systemName: "xmark.circle.fill")
                        Text("Clear all filters")
                            .font(LGFonts.small)
                    }
                    .foregroundColor(LGColors.errorText)
                }
            }
        }
        .padding()
        .background(LGColors.backgroundElevated)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(LGColors.border, lineWidth: 1)
        )
    }

    // MARK: - Models Grid

    private var modelsGridSection: some View {
        Group {
            if modelsViewModel.modelsLoading && modelsViewModel.models.isEmpty {
                // Loading skeleton
                LazyVGrid(
                    columns: [
                        GridItem(.adaptive(minimum: 160, maximum: 200), spacing: 12)
                    ],
                    spacing: 16
                ) {
                    ForEach(0..<6, id: \.self) { _ in
                        ModelCardSkeletonView()
                    }
                }
            } else if filteredModels.isEmpty {
                // Empty state
                emptyStateView
            } else {
                // Models grid
                LazyVGrid(
                    columns: [
                        GridItem(.adaptive(minimum: 160, maximum: 200), spacing: 12)
                    ],
                    spacing: 16
                ) {
                    ForEach(filteredModels) { model in
                        NavigationLink(destination: ModelDetailView(modelId: model.modelId)) {
                            ModelCardView(model: model, showCategory: selectedCategory == "all")
                        }
                        .buttonStyle(PlainButtonStyle())
                        .onAppear {
                            // Load more when reaching near the end
                            if model.id == filteredModels.suffix(4).first?.id {
                                Task {
                                    await modelsViewModel.loadMoreModels()
                                }
                            }
                        }
                    }

                    // Loading more indicator
                    if modelsViewModel.modelsLoading && !modelsViewModel.models.isEmpty {
                        ForEach(0..<2, id: \.self) { _ in
                            ModelCardSkeletonView()
                        }
                    }
                }

                // End of list message
                if !modelsViewModel.hasMore && !modelsViewModel.modelsLoading {
                    Text("You've seen all \(modelsViewModel.totalModels) models")
                        .font(LGFonts.caption)
                        .foregroundColor(LGColors.foregroundTertiary)
                        .padding(.vertical, 12)
                }
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "square.stack.3d.up.slash")
                .font(.system(size: 48))
                .foregroundColor(LGColors.foregroundTertiary)

            Text("No models found")
                .font(LGFonts.h4)
                .foregroundColor(.white)

            Text("Try adjusting your filters or category")
                .font(LGFonts.small)
                .foregroundColor(LGColors.foregroundSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(40)
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
        // Fetch credit balance
        await creditsViewModel.fetchBalance()

        // Fetch categories
        await modelsViewModel.fetchCategories()

        // Fetch featured models
        await modelsViewModel.fetchFeaturedModels()

        // Fetch all models
        await modelsViewModel.fetchModelsByCategory(slug: nil, page: 1)
    }

    private func refreshData() async {
        await creditsViewModel.refreshBalance()
        await modelsViewModel.refresh()
    }

    // Computed property for filtered models
    private var filteredModels: [ReplicateModel] {
        var models = modelsViewModel.displayModels

        // Apply style filters
        if !selectedStyles.isEmpty {
            models = models.filter { model in
                let modelStyles = model.styleTags.map { $0.lowercased() }
                return selectedStyles.contains { style in
                    modelStyles.contains(style.lowercased().replacingOccurrences(of: " ", with: "-"))
                }
            }
        }

        // Apply speed filter
        if let speedFilter = selectedSpeed {
            let speedMap: [String: String] = [
                "Instant (<5s)": "instant",
                "Fast (5-30s)": "fast",
                "Standard (30s-2m)": "standard",
                "Slow (2m+)": "slow"
            ]

            if let speedTag = speedMap[speedFilter] {
                models = models.filter { model in
                    model.speedTag?.lowercased() == speedTag
                }
            }
        }

        // Apply quality filter
        if let qualityFilter = selectedQuality {
            let qualityMap: [String: String] = [
                "Best Quality": "best",
                "Balanced": "balanced",
                "Draft": "draft"
            ]

            if let qualityTag = qualityMap[qualityFilter] {
                models = models.filter { model in
                    model.qualityTag?.lowercased() == qualityTag
                }
            }
        }

        return models
    }

    private func applyFilters() {
        // Filters are now applied via computed property
        // This function exists to trigger UI updates
    }

    private func clearFilters() {
        selectedStyles.removeAll()
        selectedSpeed = nil
        selectedQuality = nil
        applyFilters()
    }

    // Categories data
    private let categories: [CategoryInfo] = [
        CategoryInfo(slug: "video-generation", name: "Video Generation"),
        CategoryInfo(slug: "image-generation", name: "Image Generation"),
        CategoryInfo(slug: "image-editing", name: "Image Editing"),
        CategoryInfo(slug: "text-generation", name: "Text Generation"),
        CategoryInfo(slug: "audio-speech", name: "Audio & Speech"),
        CategoryInfo(slug: "music-generation", name: "Music Generation"),
        CategoryInfo(slug: "upscaling", name: "Upscaling"),
        CategoryInfo(slug: "vision-documents", name: "Vision & Documents"),
        CategoryInfo(slug: "3d-models", name: "3D Models"),
        CategoryInfo(slug: "face-avatar", name: "Face & Avatar"),
        CategoryInfo(slug: "utility", name: "Utility"),
    ]
}

// MARK: - Trending Model Card

struct TrendingModelCard: View {
    let model: ReplicateModel
    let rank: Int

    var body: some View {
        NavigationLink(destination: ModelDetailView(modelId: model.modelId)) {
            ZStack(alignment: .topLeading) {
                // Background image - try multiple sources
                if let displayImage = model.displayImage, let url = URL(string: displayImage) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        case .failure, .empty:
                            gradientPlaceholder
                        @unknown default:
                            gradientPlaceholder
                        }
                    }
                } else if let coverImage = model.coverImage, let url = URL(string: coverImage) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        case .failure, .empty:
                            gradientPlaceholder
                        @unknown default:
                            gradientPlaceholder
                        }
                    }
                } else if let thumbnailUrl = model.thumbnailUrl, let url = URL(string: thumbnailUrl) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        case .failure, .empty:
                            gradientPlaceholder
                        @unknown default:
                            gradientPlaceholder
                        }
                    }
                } else {
                    gradientPlaceholder
                }

                // Overlay gradient
                LinearGradient(
                    colors: [Color.clear, Color.black.opacity(0.9)],
                    startPoint: .top,
                    endPoint: .bottom
                )

                // Ranking badge
                ZStack {
                    Circle()
                        .fill(.white)
                        .frame(width: 28, height: 28)

                    Text("\(rank)")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.black)
                }
                .padding(8)

                // Model info
                VStack(alignment: .leading, spacing: 4) {
                    Spacer()

                    Text(model.name)
                        .font(LGFonts.body.weight(.semibold))
                        .foregroundColor(.white)
                        .lineLimit(1)

                    Text("\(model.creditCost) credits")
                        .font(LGFonts.caption)
                        .foregroundColor(LGColors.foregroundSecondary)
                }
                .padding(12)
            }
            .frame(width: 160, height: 100)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(LGColors.border, lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.4), radius: 6, x: 0, y: 3)
            .clipped()
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var gradientPlaceholder: some View {
        ZStack {
            let colors = ModelCategoryConstants.colors(for: model.categorySlug)

            // Convert to grayscale gradient
            LGColors.categoryGradient(for: model.categorySlug)

            Image(systemName: Category.icon(for: model.categorySlug))
                .font(.system(size: 36, weight: .regular))
                .foregroundColor(.white.opacity(0.6))
        }
    }
}

// MARK: - Category Tab

struct CategoryTab: View {
    let title: String
    var count: Int? = nil
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Text(title)
                    .font(LGFonts.small.weight(isSelected ? .semibold : .regular))

                if let count = count {
                    Text("\(count)")
                        .font(LGFonts.caption)
                        .foregroundColor(isSelected ? .black : LGColors.foregroundTertiary)
                }
            }
            .foregroundColor(isSelected ? .black : LGColors.foregroundSecondary)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(isSelected ? .white : LGColors.backgroundCard)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? .white : LGColors.border, lineWidth: 1)
            )
        }
    }
}

// MARK: - Filter Group

struct FilterGroup<Content: View>: View {
    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(LGFonts.label.weight(.semibold))
                .foregroundColor(.white)

            content
        }
    }
}

// MARK: - Filter Chip

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(LGFonts.small)
                .foregroundColor(isSelected ? .black : .white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? .white : LGColors.backgroundCard)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(isSelected ? .white : LGColors.border, lineWidth: 1)
                )
        }
    }
}

// MARK: - Helper Models

struct CategoryInfo {
    let slug: String
    let name: String
}

// MARK: - Preview

#if DEBUG
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(AuthViewModel())
            .environmentObject(CreditsViewModel())
            .preferredColorScheme(.dark)
    }
}
#endif
