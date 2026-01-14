//
//  GenerationsListView.swift
//  LuidGPT
//
//  Generation history list with grid layout, filters, and search
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
        NavigationView {
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
                            .foregroundColor(LGColors.VideoGeneration.main)
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
                        .tint(LGColors.VideoGeneration.main)
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
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(LGColors.neutral500)

            TextField("Search generations...", text: $viewModel.searchText)
                .textFieldStyle(.plain)
                .foregroundColor(LGColors.foreground)

            if !viewModel.searchText.isEmpty {
                Button(action: { viewModel.searchText = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(LGColors.neutral500)
                }
            }
        }
        .padding(12)
        .background(LGColors.neutral800)
        .cornerRadius(10)
        .padding(.horizontal, LGSpacing.md)
    }

    // MARK: - Stats Banner

    private var statsBanner: some View {
        HStack(spacing: LGSpacing.md) {
            statItem(
                icon: "photo.stack.fill",
                label: "Total",
                value: "\(viewModel.totalGenerations)",
                color: .blue
            )

            statItem(
                icon: "checkmark.circle.fill",
                label: "Completed",
                value: "\(viewModel.completedCount)",
                color: .green
            )

            if viewModel.processingCount > 0 {
                statItem(
                    icon: "clock.fill",
                    label: "Processing",
                    value: "\(viewModel.processingCount)",
                    color: .orange
                )
            }

            statItem(
                icon: "heart.fill",
                label: "Favorites",
                value: "\(viewModel.favoritesCount)",
                color: .red
            )
        }
        .padding(LGSpacing.md)
        .background(LGColors.neutral800)
        .cornerRadius(12)
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
                .foregroundColor(LGColors.neutral500)
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
                        .background(LGColors.errorText.opacity(0.1))
                        .cornerRadius(16)
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
                .tint(LGColors.VideoGeneration.main)

            Text("Loading generations...")
                .font(LGFonts.body)
                .foregroundColor(LGColors.neutral400)
        }
    }

    // MARK: - Empty View

    private var emptyView: some View {
        VStack(spacing: 20) {
            Image(systemName: "clock.badge.exclamationmark")
                .font(.system(size: 60))
                .foregroundColor(LGColors.neutral600)

            Text("No Generations Yet")
                .font(LGFonts.h2)
                .foregroundColor(LGColors.foreground)

            Text("Your generation history will appear here")
                .font(LGFonts.body)
                .foregroundColor(LGColors.neutral600)
                .multilineTextAlignment(.center)

            if hasActiveFilters {
                Button(action: {
                    Task { await viewModel.clearFilters() }
                }) {
                    Text("Clear Filters")
                        .font(LGFonts.body.weight(.semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(LGColors.VideoGeneration.main)
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
                            .foregroundColor(.red)
                    }
                }

                if let model = generation.replicateModel {
                    Text(model.name)
                        .font(.system(size: 11))
                        .foregroundColor(LGColors.neutral400)
                        .lineLimit(1)
                }

                HStack(spacing: 4) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 9))
                    Text("\(generation.creditsUsed)")
                        .font(.system(size: 10, weight: .medium))
                }
                .foregroundColor(LGColors.VideoGeneration.main)
            }
            .padding(8)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(LGColors.neutral800)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(LGColors.neutral800, lineWidth: 1)
        )
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
                LGColors.neutral800
                VStack(spacing: 8) {
                    ProgressView()
                        .tint(LGColors.VideoGeneration.main)
                    Text("Processing...")
                        .font(.system(size: 11))
                        .foregroundColor(LGColors.neutral400)
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
            colors?.background ?? LGColors.neutral800

            VStack(spacing: 8) {
                Image(systemName: generation.isImageOutput ? "photo" : generation.isVideoOutput ? "video" : "doc")
                    .font(.system(size: 32))
                    .foregroundColor(colors?.foreground.opacity(0.6) ?? LGColors.neutral500)

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
            return .orange
        case .completed:
            return .green
        case .failed, .cancelled:
            return LGColors.errorText
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
                    .foregroundColor(LGColors.neutral400)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(LGColors.neutral800)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(LGColors.VideoGeneration.main.opacity(0.5), lineWidth: 1)
        )
    }
}

// MARK: - Filters View

struct FiltersView: View {
    @ObservedObject var viewModel: GenerationsViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Status")) {
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
                                        .foregroundColor(LGColors.VideoGeneration.main)
                                }
                            }
                        }
                    }
                }

                Section {
                    Toggle("Favorites Only", isOn: $viewModel.showFavoritesOnly)
                        .tint(LGColors.VideoGeneration.main)
                }

                Section {
                    Button("Apply Filters") {
                        Task {
                            await viewModel.applyFilters()
                            dismiss()
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .foregroundColor(LGColors.VideoGeneration.main)

                    Button("Clear All") {
                        Task {
                            await viewModel.clearFilters()
                            dismiss()
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .foregroundColor(LGColors.errorText)
                }
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
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
