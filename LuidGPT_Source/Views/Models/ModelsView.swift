//
//  ModelsView.swift
//  LuidGPT
//
//  Main view for browsing and searching Replicate AI models
//

import SwiftUI

struct ModelsView: View {
    @StateObject private var viewModel = ModelsViewModel()
    @EnvironmentObject var creditsViewModel: CreditsViewModel

    @State private var searchText = ""
    @State private var showSearch = false

    var body: some View {
        ZStack(alignment: .top) {
            Color.white
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Custom header bar
                HStack {
                    Text("AI Models")
                        .font(.largeTitle.bold())
                        .foregroundColor(.black)

                    Spacer()

                    Button(action: { showSearch.toggle() }) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 20))
                            .foregroundColor(.black)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 8)
                .background(Color.white)

                ScrollView {
                    VStack(spacing: 16) {
                        // Header with credit balance
                        headerSection

                        // Search bar
                        searchSection

                        // Featured models
                        if !viewModel.isSearching && viewModel.hasFeaturedModels {
                            featuredSection
                        }

                        // Category navigation
                        if !viewModel.isSearching {
                            CategoryNavigationView(
                                categories: viewModel.categories,
                                selectedCategory: $viewModel.selectedCategory
                            ) { category in
                                Task {
                                    await viewModel.fetchModelsByCategory(slug: category?.slug, page: 1)
                                }
                            }
                        }

                        // Selected category header
                        if let category = viewModel.selectedCategory, !viewModel.isSearching {
                            categoryHeaderSection(category: category)
                        }

                        // Models grid
                        modelsGridSection
                    }
                    .padding(.top, 8)
                    .padding(.bottom, 8)
                }
                .refreshable {
                    await viewModel.refresh()
                    await creditsViewModel.fetchBalance()
                }
            }
        }
        .onAppear {
            Task {
                await viewModel.fetchCategories()
                await viewModel.fetchFeaturedModels()
                await viewModel.fetchModelsByCategory(slug: nil, page: 1)
                await creditsViewModel.fetchBalance()
            }
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("500+ AI Models")
                    .font(.title3.weight(.bold))
                    .foregroundColor(.black)
                Text("Browse and use powerful AI models")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }

            Spacer()

            // Credit balance
            VStack(alignment: .trailing, spacing: 2) {
                HStack(spacing: 4) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 12))
                        .foregroundColor(LGColors.VideoGeneration.main)
                    Text("\(creditsViewModel.totalCredits)")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.black)
                }

                Text("credits")
                    .font(.system(size: 11))
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(white: 0.95))
            .cornerRadius(10)
        }
        .padding(.horizontal)
    }

    // MARK: - Search Section

    private var searchSection: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)

            TextField("Search models...", text: $searchText)
                .textFieldStyle(.plain)
                .autocapitalization(.none)
                .foregroundColor(.black)
                .onChange(of: searchText) { newValue in
                    Task {
                        if newValue.count >= ModelSearchConstants.minSearchLength {
                            try? await Task.sleep(nanoseconds: UInt64(ModelSearchConstants.searchDebounce * 1_000_000_000))
                            if searchText == newValue {
                                await viewModel.searchModels(query: newValue)
                            }
                        } else if newValue.isEmpty {
                            viewModel.clearSearch()
                        }
                    }
                }

            if !searchText.isEmpty {
                Button(action: {
                    searchText = ""
                    viewModel.clearSearch()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .background(Color(white: 0.95))
        .cornerRadius(12)
        .padding(.horizontal)
    }

    // MARK: - Featured Section

    private var featuredSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "flame.fill")
                    .foregroundColor(.orange)
                Text("Trending Now")
                    .font(.headline)
                Spacer()
            }
            .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(Array(viewModel.featuredModels.prefix(10).enumerated()), id: \.element.id) { index, model in
                        NavigationLink(destination: ModelDetailView(modelId: model.modelId)) {
                            ModelCardFeaturedView(model: model, rank: index + 1)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal)
            }
        }
    }

    // MARK: - Category Header

    private func categoryHeaderSection(category: Category) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: Category.icon(for: category.slug))
                    .foregroundColor(ModelCategoryConstants.colors(for: category.slug).foreground)
                Text(category.name)
                    .font(.title2.weight(.bold))
                    .foregroundColor(.black)
            }

            if let description = category.description {
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }

            Text("\(viewModel.totalModels) models")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
    }

    // MARK: - Models Grid

    private var modelsGridSection: some View {
        Group {
            if viewModel.modelsLoading && viewModel.models.isEmpty {
                // Loading skeleton
                LazyVGrid(columns: ModelGridLayout.columns, spacing: 12) {
                    ForEach(0..<6, id: \.self) { _ in
                        ModelCardSkeletonView()
                    }
                }
                .padding(.horizontal)
            } else if viewModel.displayModels.isEmpty {
                // Empty state
                emptyStateView
            } else {
                // Models grid
                LazyVGrid(columns: ModelGridLayout.columns, spacing: 12) {
                    ForEach(viewModel.displayModels) { model in
                        NavigationLink(destination: ModelDetailView(modelId: model.modelId)) {
                            ModelCardView(model: model, showCategory: viewModel.selectedCategory == nil)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .onAppear {
                            // Load more when reaching near the end
                            if model.id == viewModel.displayModels.suffix(ModelPaginationConstants.loadMoreThreshold).first?.id {
                                Task {
                                    await viewModel.loadMoreModels()
                                }
                            }
                        }
                    }

                    // Loading more indicator
                    if viewModel.modelsLoading && !viewModel.models.isEmpty {
                        ForEach(0..<2, id: \.self) { _ in
                            ModelCardSkeletonView()
                        }
                    }
                }
                .padding(.horizontal)

                // End of list message
                if !viewModel.hasMore && !viewModel.modelsLoading {
                    Text("You've seen all \(viewModel.totalModels) models")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.vertical, 12)
                        .padding(.bottom, 8)
                }
            }
        }
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: viewModel.isSearching ? "magnifyingglass" : "square.stack.3d.up.slash")
                .font(.system(size: 48))
                .foregroundColor(.gray)

            Text(viewModel.isSearching
                 ? ModelEmptyStateConstants.noSearchResults
                 : ModelEmptyStateConstants.noModels)
                .font(.headline)
                .foregroundColor(.black)

            Text(viewModel.isSearching
                 ? ModelEmptyStateConstants.noSearchResultsDescription
                 : ModelEmptyStateConstants.noModelsDescription)
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .padding(40)
    }
}

// MARK: - Preview

#if DEBUG
struct ModelsView_Previews: PreviewProvider {
    static var previews: some View {
        ModelsView()
            .environmentObject(CreditsViewModel())
            .preferredColorScheme(.light)
    }
}
#endif
