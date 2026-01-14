//
//  ModelsViewModel.swift
//  LuidGPT
//
//  ViewModel for managing Replicate models, categories, and search
//

import Foundation
import SwiftUI
import os.log

@MainActor
class ModelsViewModel: ObservableObject {
    // MARK: - Published Properties

    // Categories
    @Published var categories: [Category] = []
    @Published var categoriesLoading = false

    // Models
    @Published var models: [ReplicateModel] = []
    @Published var modelsLoading = false
    @Published var modelsError: String?

    // Featured models
    @Published var featuredModels: [ReplicateModel] = []
    @Published var featuredLoading = false

    // Search
    @Published var searchResults: [ReplicateModel] = []
    @Published var searchLoading = false
    @Published var searchQuery = ""

    // Selected items
    @Published var selectedCategory: Category?
    @Published var selectedModel: ReplicateModel?

    // Pagination
    @Published var currentPage = 1
    @Published var hasMore = false
    @Published var totalModels = 0

    // Filters
    @Published var selectedTier: ReplicateModel.Tier?
    @Published var selectedProvider: String?
    @Published var featuredOnly = false

    // MARK: - Dependencies

    private let modelsService = ModelsService.shared
    private let logger = OSLog(subsystem: "com.luidgpt.LuidGPT", category: "ModelsViewModel")

    // MARK: - Computed Properties

    var hasModels: Bool {
        !models.isEmpty
    }

    var hasFeaturedModels: Bool {
        !featuredModels.isEmpty
    }

    var isSearching: Bool {
        !searchQuery.isEmpty
    }

    var displayModels: [ReplicateModel] {
        isSearching ? searchResults : models
    }

    // MARK: - Public Methods

    // MARK: - Categories

    /// Fetch all categories
    func fetchCategories() async {
        NSLog("📁 ModelsViewModel: Fetching categories...")
        os_log("📁 ModelsViewModel: Fetching categories...", log: logger, type: .info)

        categoriesLoading = true

        do {
            let fetchedCategories = try await modelsService.getCategories()
            self.categories = fetchedCategories

            NSLog("📁 ModelsViewModel: Loaded %d categories", fetchedCategories.count)
            os_log("📁 ModelsViewModel: Loaded %{public}d categories", log: logger, type: .info, fetchedCategories.count)

        } catch let error as APIError {
            NSLog("❌ ModelsViewModel: Failed to fetch categories - %@", error.localizedDescription)
            os_log("❌ ModelsViewModel: Failed to fetch categories - %{public}@", log: logger, type: .error, error.localizedDescription)
        } catch {
            NSLog("❌ ModelsViewModel: Unexpected error - %@", error.localizedDescription)
            os_log("❌ ModelsViewModel: Unexpected error - %{public}@", log: logger, type: .error, error.localizedDescription)
        }

        categoriesLoading = false
    }

    /// Fetch category by slug
    func fetchCategory(slug: String) async {
        do {
            let category = try await modelsService.getCategory(slug: slug)
            self.selectedCategory = category
        } catch {
            NSLog("❌ ModelsViewModel: Failed to fetch category: %@", error.localizedDescription)
        }
    }

    // MARK: - Models

    /// Fetch models for a category
    func fetchModelsByCategory(slug: String?, page: Int = 1, append: Bool = false) async {
        NSLog("🤖 ModelsViewModel: Fetching models for category: %@, page: %d", slug ?? "all", page)
        os_log("🤖 ModelsViewModel: Fetching models - category: %{public}@, page: %{public}d", log: logger, type: .info, slug ?? "all", page)

        if !append {
            modelsLoading = true
        }
        modelsError = nil

        do {
            // If no category slug, fetch featured/all models instead
            if slug == nil || slug?.isEmpty == true {
                // Use featured endpoint for "All Models"
                let featuredModels = try await modelsService.getFeaturedModels(limit: 20)

                if append {
                    self.models.append(contentsOf: featuredModels)
                } else {
                    self.models = featuredModels
                }

                // For featured models, we don't have full pagination info
                self.currentPage = page
                self.hasMore = featuredModels.count >= 20
                self.totalModels = featuredModels.count
                self.selectedCategory = nil

                NSLog("🤖 ModelsViewModel: Loaded %d featured models", featuredModels.count)
                os_log("🤖 ModelsViewModel: Loaded %{public}d featured models", log: logger, type: .info, featuredModels.count)
            } else {
                // Fetch for specific category
                let result = try await modelsService.getCategoryModels(
                    slug: slug!,
                    page: page,
                    limit: 20
                )

            if append {
                self.models.append(contentsOf: result.models)
            } else {
                self.models = result.models
            }

            // Update pagination
            self.currentPage = result.pagination?.page ?? page
            self.hasMore = result.pagination?.hasMore ?? false
            self.totalModels = result.pagination?.total ?? result.models.count

            // Update selected category if provided in response
            if let category = result.category {
                self.selectedCategory = category
            }

            NSLog("🤖 ModelsViewModel: Loaded %d models (total: %d, hasMore: %@)",
                  result.models.count, totalModels, hasMore ? "yes" : "no")
            os_log("🤖 ModelsViewModel: Loaded %{public}d models (total: %{public}d, hasMore: %{public}@)",
                   log: logger, type: .info, result.models.count, totalModels, hasMore ? "yes" : "no")
            }
        } catch let error as APIError {
            NSLog("❌ ModelsViewModel: Failed to fetch models - %@", error.localizedDescription)
            os_log("❌ ModelsViewModel: Failed to fetch models - %{public}@", log: logger, type: .error, error.localizedDescription)
            self.modelsError = error.localizedDescription
        } catch {
            NSLog("❌ ModelsViewModel: Unexpected error - %@", error.localizedDescription)
            os_log("❌ ModelsViewModel: Unexpected error - %{public}@", log: logger, type: .error, error.localizedDescription)
            self.modelsError = "Failed to load models"
        }

        modelsLoading = false
    }

    /// Load more models (pagination)
    func loadMoreModels() async {
        guard hasMore, !modelsLoading else { return }
        await fetchModelsByCategory(slug: selectedCategory?.slug, page: currentPage + 1, append: true)
    }

    /// Fetch featured models
    func fetchFeaturedModels(limit: Int = 10) async {
        NSLog("⭐ ModelsViewModel: Fetching featured models...")
        os_log("⭐ ModelsViewModel: Fetching featured models...", log: logger, type: .info)

        featuredLoading = true

        do {
            let models = try await modelsService.getFeaturedModels(limit: limit)
            self.featuredModels = models

            NSLog("⭐ ModelsViewModel: Loaded %d featured models", models.count)
            os_log("⭐ ModelsViewModel: Loaded %{public}d featured models", log: logger, type: .info, models.count)

        } catch let error as APIError {
            NSLog("❌ ModelsViewModel: Failed to fetch featured models - %@", error.localizedDescription)
            os_log("❌ ModelsViewModel: Failed to fetch featured models - %{public}@", log: logger, type: .error, error.localizedDescription)
        } catch {
            NSLog("❌ ModelsViewModel: Unexpected error - %@", error.localizedDescription)
            os_log("❌ ModelsViewModel: Unexpected error - %{public}@", log: logger, type: .error, error.localizedDescription)
        }

        featuredLoading = false
    }

    /// Fetch specific model by ID
    func fetchModel(id: String) async {
        NSLog("🤖 ModelsViewModel: Fetching model: %@", id)
        os_log("🤖 ModelsViewModel: Fetching model: %{public}@", log: logger, type: .info, id)

        do {
            let model = try await modelsService.getModel(id: id)
            self.selectedModel = model

            NSLog("🤖 ModelsViewModel: Loaded model: %@", model.name)
            os_log("🤖 ModelsViewModel: Loaded model: %{public}@", log: logger, type: .info, model.name)

        } catch let error as APIError {
            NSLog("❌ ModelsViewModel: Failed to fetch model - %@", error.localizedDescription)
            os_log("❌ ModelsViewModel: Failed to fetch model - %{public}@", log: logger, type: .error, error.localizedDescription)
            self.modelsError = error.localizedDescription
        } catch {
            NSLog("❌ ModelsViewModel: Unexpected error - %@", error.localizedDescription)
            os_log("❌ ModelsViewModel: Unexpected error - %{public}@", log: logger, type: .error, error.localizedDescription)
            self.modelsError = "Failed to load model"
        }
    }

    // MARK: - Search

    /// Search models
    func searchModels(query: String) async {
        guard !query.isEmpty else {
            clearSearch()
            return
        }

        NSLog("🔍 ModelsViewModel: Searching for: %@", query)
        os_log("🔍 ModelsViewModel: Searching for: %{public}@", log: logger, type: .info, query)

        searchQuery = query
        searchLoading = true

        do {
            let result = try await modelsService.searchModels(query: query, page: 1, limit: 20)
            self.searchResults = result.models

            NSLog("🔍 ModelsViewModel: Found %d results", result.models.count)
            os_log("🔍 ModelsViewModel: Found %{public}d results", log: logger, type: .info, result.models.count)

        } catch let error as APIError {
            NSLog("❌ ModelsViewModel: Search failed - %@", error.localizedDescription)
            os_log("❌ ModelsViewModel: Search failed - %{public}@", log: logger, type: .error, error.localizedDescription)
            self.searchResults = []
        } catch {
            NSLog("❌ ModelsViewModel: Unexpected error - %@", error.localizedDescription)
            os_log("❌ ModelsViewModel: Unexpected error - %{public}@", log: logger, type: .error, error.localizedDescription)
            self.searchResults = []
        }

        searchLoading = false
    }

    /// Clear search
    func clearSearch() {
        searchQuery = ""
        searchResults = []
        searchLoading = false
    }

    // MARK: - Filters

    /// Apply filters and refetch
    func applyFilters() async {
        await fetchModelsByCategory(slug: selectedCategory?.slug, page: 1)
    }

    /// Clear all filters
    func clearFilters() {
        selectedTier = nil
        selectedProvider = nil
        featuredOnly = false
    }

    // MARK: - Utility

    /// Refresh all data
    func refresh() async {
        await fetchCategories()
        await fetchFeaturedModels()
        await fetchModelsByCategory(slug: selectedCategory?.slug, page: 1)
    }

    /// Clear error
    func clearError() {
        modelsError = nil
    }

    /// Reset state
    func reset() {
        NSLog("🔄 ModelsViewModel: Resetting state...")
        os_log("🔄 ModelsViewModel: Resetting state...", log: logger, type: .info)

        categories = []
        models = []
        featuredModels = []
        searchResults = []
        selectedCategory = nil
        selectedModel = nil
        searchQuery = ""
        currentPage = 1
        hasMore = false
        totalModels = 0
        modelsError = nil
        categoriesLoading = false
        modelsLoading = false
        featuredLoading = false
        searchLoading = false
        clearFilters()
    }
}
