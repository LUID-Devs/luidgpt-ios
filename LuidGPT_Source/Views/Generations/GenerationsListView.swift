//
//  GenerationsListView.swift
//  LuidGPT
//
//  Generation history list with grid layout, filters, and search
//  Black & White Premium Aesthetic
//

import SwiftUI

struct GenerationsListView: View {
    @StateObject private var viewModel = GenerationsViewModel()
    @State private var showFilters = false
    @State private var selectedGeneration: ModelGeneration?

    // Grid layout
    private let columns = [
        GridItem(.adaptive(minimum: 160, maximum: 200), spacing: 12)
    ]

    var body: some View {
        ZStack {
            LGColors.background.ignoresSafeArea()

            if viewModel.isLoading && viewModel.generations.isEmpty {
                loadingView
            } else if viewModel.generations.isEmpty {
                emptyView
            } else {
                contentView
            }
        }
        .navigationTitle("History")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showFilters.toggle() }) {
                    Image(systemName: hasActiveFilters ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                        .foregroundColor(LGColors.foreground)
                }
            }
        }
        .sheet(isPresented: $showFilters) {
            FiltersView(viewModel: viewModel)
        }
        .sheet(item: $selectedGeneration) { generation in
            GenerationDetailView(generation: generation, viewModel: viewModel)
        }
        .task {
            if viewModel.generations.isEmpty {
                await viewModel.loadGenerations()
            }
        }
    }

    // MARK: - Content View

    private var contentView: some View {
        ScrollView {
            VStack(spacing: LGSpacing.lg) {
                // Search bar
                searchBar

                // Stats banner
                if !viewModel.generations.isEmpty {
                    statsBanner
                }

                // Active filters
                if hasActiveFilters {
                    activeFiltersBar
                }

                // Grid of generations
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(viewModel.filteredGenerations) { generation in
                        GenerationCardView(generation: generation)
                            .onTapGesture {
                                selectedGeneration = generation
                            }
                            .contextMenu {
                                generationContextMenu(generation)
                            }
                            .onAppear {
                                // Pagination: Load more when reaching last item
                                if generation.id == viewModel.filteredGenerations.last?.id {
                                    Task {
                                        await viewModel.loadMore()
                                    }
                                }
                            }
                    }
                }
                .padding(.horizontal, LGSpacing.md)

                // Loading more indicator
                if viewModel.isLoadingMore {
                    ProgressView()
                        .tint(LGColors.foreground)
                        .padding()
                }
            }
            .padding(.bottom, LGSpacing.xl)
        }
        .refreshable {
            await viewModel.refresh()
        }
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(LGColors.foregroundSecondary)

            TextField("Search generations...", text: $viewModel.searchText)
                .textFieldStyle(.plain)
                .foregroundColor(LGColors.foreground)
                .font(.system(size: 15))
                .placeholder(when: viewModel.searchText.isEmpty) {
                    Text("Search generations...")
                        .foregroundColor(LGColors.foregroundSecondary)
                        .font(.system(size: 15))
                }

            if !viewModel.searchText.isEmpty {
                Button(action: { viewModel.searchText = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(LGColors.foregroundSecondary)
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(LGColors.backgroundCard)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(LGColors.borderElevated, lineWidth: 1)
        )
        .padding(.horizontal, LGSpacing.md)
        .padding(.top, 8)
    }

    // MARK: - Stats Banner

    private var statsBanner: some View {
        HStack(spacing: LGSpacing.md) {
            statItem(
                icon: "photo.stack.fill",
                label: "Total",
                value: "\(viewModel.totalGenerations)",
                color: LGColors.foreground
            )

            statItem(
                icon: "checkmark.circle.fill",
                label: "Completed",
                value: "\(viewModel.completedCount)",
                color: LGColors.success
            )

            if viewModel.processingCount > 0 {
                statItem(
                    icon: "clock.fill",
                    label: "Processing",
                    value: "\(viewModel.processingCount)",
                    color: LGColors.info
                )
            }

            statItem(
                icon: "heart.fill",
                label: "Favorites",
                value: "\(viewModel.favoritesCount)",
                color: LGColors.foregroundSecondary
            )
        }
        .padding(LGSpacing.md)
        .background(LGColors.backgroundCard)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(LGColors.border, lineWidth: 1)
        )
        .shadow(color: LGColors.innerShadow, radius: 4, x: 0, y: 2)
        .padding(.horizontal, LGSpacing.md)
    }

    private func statItem(icon: String, label: String, value: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(color)

            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(LGColors.foreground)

            Text(label)
                .font(.system(size: 10))
                .foregroundColor(LGColors.foregroundTertiary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Active Filters Bar

    private var activeFiltersBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                if let category = viewModel.selectedCategory {
                    GenerationsFilterChip(label: "Category: \(category)") {
                        viewModel.selectedCategory = nil
                        Task { await viewModel.applyFilters() }
                    }
                }

                if let model = viewModel.selectedModel {
                    GenerationsFilterChip(label: "Model: \(model)") {
                        viewModel.selectedModel = nil
                        Task { await viewModel.applyFilters() }
                    }
                }

                if let status = viewModel.selectedStatus {
                    GenerationsFilterChip(label: "Status: \(status.displayName)") {
                        viewModel.selectedStatus = nil
                        Task { await viewModel.applyFilters() }
                    }
                }

                if viewModel.showFavoritesOnly {
                    GenerationsFilterChip(label: "Favorites") {
                        viewModel.showFavoritesOnly = false
                        Task { await viewModel.applyFilters() }
                    }
                }

                Button(action: {
                    Task { await viewModel.clearFilters() }
                }) {
                    Text("Clear All")
                        .font(LGFonts.small)
                        .foregroundColor(LGColors.errorText)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(LGColors.errorBg)
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(LGColors.errorBorder, lineWidth: 1)
                        )
                }
            }
            .padding(.horizontal, LGSpacing.md)
        }
    }

    // MARK: - Context Menu

    @ViewBuilder
    private func generationContextMenu(_ generation: ModelGeneration) -> some View {
        Button(action: {
            selectedGeneration = generation
        }) {
            Label("View Details", systemImage: "eye")
        }

        Button(action: {
            Task {
                await viewModel.toggleFavorite(generation: generation)
            }
        }) {
            Label(
                generation.isFavorite ? "Remove from Favorites" : "Add to Favorites",
                systemImage: generation.isFavorite ? "heart.slash" : "heart"
            )
        }

        if let url = generation.outputUrl, let outputURL = URL(string: url) {
            ShareLink(item: outputURL) {
                Label("Share", systemImage: "square.and.arrow.up")
            }
        }

        Divider()

        Button(role: .destructive, action: {
            Task {
                await viewModel.deleteGeneration(generation: generation)
            }
        }) {
            Label("Delete", systemImage: "trash")
        }
    }

    // MARK: - Loading View

    private var loadingView: some View {
        VStack(spacing: LGSpacing.lg) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(LGColors.foreground)

            Text("Loading generations...")
                .font(LGFonts.body)
                .foregroundColor(LGColors.foregroundSecondary)
        }
    }

    // MARK: - Empty View

    private var emptyView: some View {
        VStack(spacing: 20) {
            Image(systemName: "clock.badge.exclamationmark")
                .font(.system(size: 60))
                .foregroundColor(LGColors.foregroundTertiary)

            Text("No Generations Yet")
                .font(LGFonts.h2)
                .foregroundColor(LGColors.foreground)

            Text("Your generation history will appear here")
                .font(LGFonts.body)
                .foregroundColor(LGColors.foregroundSecondary)
                .multilineTextAlignment(.center)

            if hasActiveFilters {
                Button(action: {
                    Task { await viewModel.clearFilters() }
                }) {
                    Text("Clear Filters")
                        .font(LGFonts.body.weight(.semibold))
                        .foregroundColor(LGColors.background)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(LGColors.foreground)
                        .cornerRadius(10)
                }
                .padding(.top)
            }
        }
        .padding()
    }

    // MARK: - Helpers

    private var hasActiveFilters: Bool {
        viewModel.selectedCategory != nil ||
        viewModel.selectedModel != nil ||
        viewModel.selectedStatus != nil ||
        viewModel.showFavoritesOnly
    }
}

// MARK: - Generation Card

struct GenerationCardView: View {
    let generation: ModelGeneration

    var body: some View {
        VStack(spacing: 0) {
            // Thumbnail
            thumbnailView
                .frame(height: 160)
                .clipped()

            // Info
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    // Status indicator
                    Circle()
                        .fill(statusColor)
                        .frame(width: 8, height: 8)

                    Text(generation.title ?? "Untitled")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(LGColors.foreground)
                        .lineLimit(1)

                    Spacer()

                    if generation.isFavorite {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 10))
                            .foregroundColor(LGColors.foregroundSecondary)
                    }
                }

                if let model = generation.replicateModel {
                    Text(model.name)
                        .font(.system(size: 11))
                        .foregroundColor(LGColors.foregroundTertiary)
                        .lineLimit(1)
                }

                HStack(spacing: 4) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 9))
                        .foregroundColor(LGColors.foregroundSecondary)
                    Text("\(generation.creditsUsed)")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(LGColors.foreground)
                }
            }
            .padding(8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(LGColors.backgroundCard)
        }
        .background(LGColors.backgroundCard)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(LGColors.border, lineWidth: 1)
        )
        .shadow(color: LGColors.innerShadow, radius: 4, x: 0, y: 2)
    }

    @ViewBuilder
    private var thumbnailView: some View {
        if let url = generation.outputUrl, generation.status == .completed {
            AsyncImage(url: URL(string: url)) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure, .empty:
                    placeholderView
                @unknown default:
                    placeholderView
                }
            }
        } else if generation.status.isRunning {
            ZStack {
                LGColors.backgroundElevated
                VStack(spacing: 8) {
                    ProgressView()
                        .tint(LGColors.foreground)
                    Text("Processing...")
                        .font(.system(size: 11))
                        .foregroundColor(LGColors.foregroundSecondary)
                }
            }
        } else {
            placeholderView
        }
    }

    private var placeholderView: some View {
        let colors = generation.replicateModel.map { model in
            ModelCategoryConstants.colors(for: model.categorySlug)
        }

        return ZStack {
            // Use grayscale category color background
            (colors?.background ?? LGColors.backgroundElevated)

            VStack(spacing: 8) {
                Image(systemName: generation.isImageOutput ? "photo" : generation.isVideoOutput ? "video" : "doc")
                    .font(.system(size: 32))
                    .foregroundColor(colors?.foreground ?? LGColors.foregroundTertiary)

                if generation.status == .failed {
                    Text("Failed")
                        .font(.system(size: 11))
                        .foregroundColor(LGColors.errorText)
                }
            }
        }
    }

    private var statusColor: Color {
        switch generation.status {
        case .pending, .processing:
            return LGColors.foregroundSecondary // Light gray for processing
        case .completed:
            return LGColors.foreground // White for success
        case .failed, .cancelled:
            return LGColors.foregroundTertiary // Medium gray for error
        }
    }
}

// MARK: - Filter Chip

struct GenerationsFilterChip: View {
    let label: String
    let onRemove: () -> Void

    var body: some View {
        HStack(spacing: 6) {
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(LGColors.foreground)

            Button(action: onRemove) {
                Image(systemName: "xmark")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(LGColors.foregroundTertiary)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(LGColors.backgroundCard)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(LGColors.border, lineWidth: 1)
        )
    }
}

// MARK: - Filters View

struct FiltersView: View {
    @ObservedObject var viewModel: GenerationsViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ZStack {
                LGColors.background.ignoresSafeArea()

                Form {
                    Section(header: Text("Status").foregroundColor(LGColors.foregroundSecondary)) {
                        ForEach([
                            ModelGeneration.GenerationStatus.pending,
                            .processing,
                            .completed,
                            .failed
                        ], id: \.self) { status in
                            Button(action: {
                                viewModel.selectedStatus = viewModel.selectedStatus == status ? nil : status
                            }) {
                                HStack {
                                    Text(status.displayName)
                                        .foregroundColor(LGColors.foreground)
                                    Spacer()
                                    if viewModel.selectedStatus == status {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(LGColors.success)
                                    }
                                }
                            }
                        }
                        .listRowBackground(LGColors.backgroundCard)
                    }

                    Section {
                        Toggle("Favorites Only", isOn: $viewModel.showFavoritesOnly)
                            .tint(LGColors.foreground)
                            .foregroundColor(LGColors.foreground)
                    }
                    .listRowBackground(LGColors.backgroundCard)

                    Section {
                        Button("Apply Filters") {
                            Task {
                                await viewModel.applyFilters()
                                dismiss()
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .foregroundColor(LGColors.foreground)

                        Button("Clear All") {
                            Task {
                                await viewModel.clearFilters()
                                dismiss()
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .foregroundColor(LGColors.errorText)
                    }
                    .listRowBackground(LGColors.backgroundCard)
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(LGColors.foreground)
                }
            }
        }
    }
}

// MARK: - View Extension for Placeholder

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

// MARK: - Preview

#if DEBUG
struct GenerationsListView_Previews: PreviewProvider {
    static var previews: some View {
        GenerationsListView()
            .preferredColorScheme(.dark)
    }
}
#endif
