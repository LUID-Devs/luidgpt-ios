//
//  GenerationsViewModel.swift
//  LuidGPT
//
//  ViewModel for generation history - handles listing, filtering, and management
//

import Foundation
import SwiftUI

/// ViewModel managing generation history list
@MainActor
class GenerationsViewModel: ObservableObject {
    // MARK: - Published Properties

    // Generations Data
    @Published var generations: [ModelGeneration] = []
    @Published var isLoading = false
    @Published var error: String?

    // Pagination
    @Published var currentPage = 1
    @Published var totalPages = 1
    @Published var hasMore = false
    @Published var isLoadingMore = false

    // Filters
    @Published var selectedCategory: String?
    @Published var selectedModel: String?
    @Published var selectedStatus: ModelGeneration.GenerationStatus?
    @Published var showFavoritesOnly = false
    @Published var searchText = ""

    // MARK: - Services

    private let modelsAPI = ModelsAPIService.shared
    private let pageLimit = 20

    // MARK: - Public Methods

    /// Load initial generations
    func loadGenerations(reset: Bool = true) async {
        if reset {
            currentPage = 1
            generations = []
        }

        isLoading = true
        error = nil

        do {
            let result = try await modelsAPI.fetchGenerations(
                page: currentPage,
                limit: pageLimit,
                categorySlug: selectedCategory,
                modelId: selectedModel,
                status: selectedStatus?.rawValue,
                favorite: showFavoritesOnly ? true : nil
            )

            if reset {
                generations = result.generations
            } else {
                generations.append(contentsOf: result.generations)
            }

            // Update pagination
            if let pagination = result.pagination {
                totalPages = pagination.pages
                hasMore = currentPage < pagination.pages
            }

        } catch {
            self.error = error.localizedDescription
            print("❌ Error loading generations: \(error)")
        }

        isLoading = false
    }

    /// Load next page of generations
    func loadMore() async {
        guard !isLoadingMore && hasMore else { return }

        isLoadingMore = true
        currentPage += 1
        await loadGenerations(reset: false)
        isLoadingMore = false
    }

    /// Refresh generations (pull to refresh)
    func refresh() async {
        await loadGenerations(reset: true)
    }

    /// Apply filters and reload
    func applyFilters() async {
        await loadGenerations(reset: true)
    }

    /// Clear all filters
    func clearFilters() async {
        selectedCategory = nil
        selectedModel = nil
        selectedStatus = nil
        showFavoritesOnly = false
        searchText = ""
        await loadGenerations(reset: true)
    }

    /// Toggle favorite status of a generation
    func toggleFavorite(generation: ModelGeneration) async {
        do {
            let updated = try await modelsAPI.updateGeneration(
                id: generation.id,
                isFavorite: !generation.isFavorite
            )

            // Update in local list
            if let index = generations.firstIndex(where: { $0.id == generation.id }) {
                generations[index] = updated
            }

        } catch {
            print("❌ Error toggling favorite: \(error)")
            // Optionally show error to user
        }
    }

    /// Delete a generation
    func deleteGeneration(generation: ModelGeneration) async {
        do {
            try await modelsAPI.deleteGeneration(id: generation.id)

            // Remove from local list
            generations.removeAll { $0.id == generation.id }

        } catch {
            print("❌ Error deleting generation: \(error)")
            // Optionally show error to user
        }
    }

    /// Cancel a running generation
    func cancelGeneration(generation: ModelGeneration) async {
        guard generation.status.isRunning else { return }

        do {
            let updated = try await modelsAPI.cancelGeneration(id: generation.id)

            // Update in local list
            if let index = generations.firstIndex(where: { $0.id == generation.id }) {
                generations[index] = updated
            }

        } catch {
            print("❌ Error cancelling generation: \(error)")
            // Optionally show error to user
        }
    }

    /// Update generation metadata
    func updateGeneration(
        generation: ModelGeneration,
        title: String? = nil,
        tags: [String]? = nil
    ) async {
        do {
            let updated = try await modelsAPI.updateGeneration(
                id: generation.id,
                title: title,
                tags: tags
            )

            // Update in local list
            if let index = generations.firstIndex(where: { $0.id == generation.id }) {
                generations[index] = updated
            }

        } catch {
            print("❌ Error updating generation: \(error)")
            // Optionally show error to user
        }
    }

    // MARK: - Computed Properties

    /// Filtered generations based on search text
    var filteredGenerations: [ModelGeneration] {
        guard !searchText.isEmpty else {
            return generations
        }

        let lowercasedSearch = searchText.lowercased()

        return generations.filter { generation in
            // Search in title
            if let title = generation.title, title.lowercased().contains(lowercasedSearch) {
                return true
            }

            // Search in tags
            if let tags = generation.tags {
                for tag in tags {
                    if tag.lowercased().contains(lowercasedSearch) {
                        return true
                    }
                }
            }

            // Search in model name
            if let modelName = generation.replicateModel?.name,
               modelName.lowercased().contains(lowercasedSearch) {
                return true
            }

            return false
        }
    }

    /// Group generations by date
    var generationsByDate: [(date: String, generations: [ModelGeneration])] {
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none

        var grouped: [String: [ModelGeneration]] = [:]

        for generation in filteredGenerations {
            guard let date = generation.createdDate else { continue }

            let dateString: String
            if calendar.isDateInToday(date) {
                dateString = "Today"
            } else if calendar.isDateInYesterday(date) {
                dateString = "Yesterday"
            } else {
                dateString = dateFormatter.string(from: date)
            }

            if grouped[dateString] == nil {
                grouped[dateString] = []
            }
            grouped[dateString]?.append(generation)
        }

        // Sort by date (most recent first)
        let sorted = grouped.sorted { first, second in
            if first.key == "Today" { return true }
            if second.key == "Today" { return false }
            if first.key == "Yesterday" { return true }
            if second.key == "Yesterday" { return false }

            guard let firstDate = first.value.first?.createdDate,
                  let secondDate = second.value.first?.createdDate else {
                return false
            }
            return firstDate > secondDate
        }

        return sorted.map { (date: $0.key, generations: $0.value) }
    }

    /// Get statistics
    var totalGenerations: Int {
        generations.count
    }

    var completedCount: Int {
        generations.filter { $0.status == .completed }.count
    }

    var processingCount: Int {
        generations.filter { $0.status.isRunning }.count
    }

    var favoritesCount: Int {
        generations.filter { $0.isFavorite }.count
    }

    var totalCreditsUsed: Int {
        generations.reduce(0) { $0 + $1.creditsUsed }
    }
}

// MARK: - Preview Helpers

#if DEBUG
extension GenerationsViewModel {
    /// Create mock ViewModel for previews
    static func mock() -> GenerationsViewModel {
        let vm = GenerationsViewModel()
        vm.generations = ModelGeneration.mockGenerations + [
            ModelGeneration.mockImageGeneration,
            ModelGeneration.mockVideoGeneration,
            ModelGeneration(
                id: UUID().uuidString,
                userId: UUID().uuidString,
                organizationId: nil,
                replicateModelId: UUID().uuidString,
                modelId: "stability-ai/sdxl",
                categorySlug: "image-generation",
                input: ["prompt": AnyCodable("A serene lake")],
                output: AnyCodable("https://example.com/lake.png"),
                outputUrl: "https://example.com/lake.png",
                outputUrls: nil,
                status: .failed,
                errorMessage: "Insufficient resources",
                creditsUsed: 2,
                executionTimeMs: 5000,
                title: "Serene Lake",
                tags: ["nature"],
                isFavorite: false,
                createdAt: ISO8601DateFormatter().string(from: Date().addingTimeInterval(-86400)),
                updatedAt: ISO8601DateFormatter().string(from: Date().addingTimeInterval(-86400)),
                replicateModel: nil
            )
        ]
        vm.hasMore = true
        return vm
    }

    /// Create mock ViewModel in loading state
    static func mockLoading() -> GenerationsViewModel {
        let vm = GenerationsViewModel()
        vm.isLoading = true
        return vm
    }

    /// Create mock ViewModel with empty state
    static func mockEmpty() -> GenerationsViewModel {
        let vm = GenerationsViewModel()
        vm.generations = []
        return vm
    }
}
#endif
