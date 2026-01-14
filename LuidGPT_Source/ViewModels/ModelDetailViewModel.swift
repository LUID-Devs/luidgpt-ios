//
//  ModelDetailViewModel.swift
//  LuidGPT
//
//  ViewModel for model detail screen - handles model loading, execution, and state
//

import Foundation
import SwiftUI

/// ViewModel managing model detail state and execution
@MainActor
class ModelDetailViewModel: ObservableObject {
    // MARK: - Published Properties

    // Model Data
    @Published var model: ReplicateModel?
    @Published var modelLoading = false
    @Published var modelError: String?

    // Schema Data
    @Published var schema: InputSchema?
    @Published var schemaLoading = false
    @Published var schemaError: String?

    // Execution State
    @Published var executionLoading = false
    @Published var executionError: String?
    @Published var executionResult: ModelGeneration?
    @Published var executionStatus: ExecutionStatus = .idle

    // Recent Generations
    @Published var recentGenerations: [ModelGeneration] = []
    @Published var generationsLoading = false

    // MARK: - Services

    private let modelsAPI = ModelsAPIService.shared

    // MARK: - Execution Status

    enum ExecutionStatus {
        case idle
        case preparing
        case submitting
        case processing
        case completed
        case failed

        var displayText: String {
            switch self {
            case .idle: return ""
            case .preparing: return "Preparing..."
            case .submitting: return "Submitting..."
            case .processing: return "Processing..."
            case .completed: return "Completed"
            case .failed: return "Failed"
            }
        }
    }

    // MARK: - Public Methods

    /// Load model details and schema
    func loadModel(modelId: String) async {
        modelLoading = true
        modelError = nil

        do {
            // Load model details
            let fetchedModel = try await modelsAPI.fetchModelDetails(modelId: modelId)
            self.model = fetchedModel

            // Load schema in parallel
            await loadSchema(modelId: modelId)

            // Load recent generations for this model
            await loadRecentGenerations(modelId: modelId)

        } catch {
            modelError = error.localizedDescription
            print("❌ Error loading model: \(error)")
        }

        modelLoading = false
    }

    /// Load model input schema
    func loadSchema(modelId: String) async {
        schemaLoading = true
        schemaError = nil

        do {
            let fetchedSchema = try await modelsAPI.fetchModelSchema(modelId: modelId)
            self.schema = fetchedSchema
        } catch {
            schemaError = error.localizedDescription
            print("❌ Error loading schema: \(error)")
        }

        schemaLoading = false
    }

    /// Execute model with given inputs
    func executeModel(modelId: String, input: [String: Any], title: String? = nil, tags: [String]? = nil) async {
        executionLoading = true
        executionError = nil
        executionStatus = .preparing

        do {
            // Validate inputs
            guard !input.isEmpty else {
                throw NSError(domain: "ModelExecution", code: 400, userInfo: [
                    NSLocalizedDescriptionKey: "Input parameters are required"
                ])
            }

            executionStatus = .submitting

            // Execute model
            let generation = try await modelsAPI.executeModel(
                modelId: modelId,
                input: input,
                organizationId: nil,
                title: title,
                tags: tags
            )

            executionResult = generation

            // Poll for completion if status is pending/processing
            if generation.status.isRunning {
                executionStatus = .processing
                await pollGenerationStatus(generationId: generation.id)
            } else if generation.status == .completed {
                executionStatus = .completed
            } else if generation.status == .failed {
                executionStatus = .failed
                executionError = generation.errorMessage ?? "Generation failed"
            }

            // Reload recent generations
            await loadRecentGenerations(modelId: modelId)

        } catch let error as APIError {
            executionStatus = .failed
            executionError = handleAPIError(error)
            print("❌ Error executing model: \(error)")
        } catch {
            executionStatus = .failed
            executionError = error.localizedDescription
            print("❌ Error executing model: \(error)")
        }

        executionLoading = false
    }

    /// Poll generation status until completion
    private func pollGenerationStatus(generationId: String, maxAttempts: Int = 60) async {
        var attempts = 0

        while attempts < maxAttempts {
            do {
                try await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds

                let updatedGeneration = try await modelsAPI.fetchGeneration(id: generationId)
                executionResult = updatedGeneration

                if updatedGeneration.status.isFinished {
                    if updatedGeneration.status == .completed {
                        executionStatus = .completed
                    } else if updatedGeneration.status == .failed {
                        executionStatus = .failed
                        executionError = updatedGeneration.errorMessage ?? "Generation failed"
                    } else if updatedGeneration.status == .cancelled {
                        executionStatus = .failed
                        executionError = "Generation was cancelled"
                    }
                    return
                }

                attempts += 1
            } catch {
                print("⚠️ Error polling generation status: \(error)")
                attempts += 1
            }
        }

        // Timeout
        executionStatus = .failed
        executionError = "Generation timeout - please check your history for results"
    }

    /// Load recent generations for this model
    func loadRecentGenerations(modelId: String) async {
        generationsLoading = true

        do {
            let result = try await modelsAPI.fetchGenerations(
                page: 1,
                limit: 10,
                modelId: modelId
            )
            recentGenerations = result.generations
        } catch {
            print("⚠️ Error loading recent generations: \(error)")
        }

        generationsLoading = false
    }

    /// Reset execution state
    func resetExecution() {
        executionLoading = false
        executionError = nil
        executionResult = nil
        executionStatus = .idle
    }

    /// Clear all state
    func clearState() {
        model = nil
        schema = nil
        executionResult = nil
        recentGenerations = []
        resetExecution()
        modelError = nil
        schemaError = nil
    }

    /// Retry execution with same inputs
    func retryExecution() async {
        guard let model = model,
              let result = executionResult else {
            return
        }

        // Convert AnyCodable back to [String: Any]
        var inputDict: [String: Any] = [:]
        for (key, value) in result.input {
            inputDict[key] = value.value
        }

        await executeModel(
            modelId: model.modelId,
            input: inputDict,
            title: result.title,
            tags: result.tags
        )
    }

    /// Toggle favorite status of current execution result
    func toggleFavorite() async {
        guard let result = executionResult else { return }

        do {
            let updated = try await modelsAPI.updateGeneration(
                id: result.id,
                isFavorite: !result.isFavorite
            )

            // Update current result
            executionResult = updated

            // Update in recent generations list if present
            if let index = recentGenerations.firstIndex(where: { $0.id == result.id }) {
                recentGenerations[index] = updated
            }

        } catch {
            print("❌ Error toggling favorite: \(error)")
        }
    }

    // MARK: - Helper Methods

    /// Handle API errors with user-friendly messages
    private func handleAPIError(_ error: APIError) -> String {
        switch error {
        case .unauthorized:
            return "Session expired. Please login again."
        case .networkError:
            return "Network connection failed. Please check your internet connection."
        case .serverError(let message):
            // Parse specific error messages
            if message.contains("Insufficient credits") {
                return "You don't have enough credits for this operation."
            } else if message.contains("Model not found") {
                return "This model is no longer available."
            } else if message.contains("not active") {
                return "This model is currently unavailable."
            }
            return message
        default:
            return error.localizedDescription
        }
    }

    /// Get effective credit cost for the model
    var effectiveCreditCost: Int {
        guard let model = model else { return 2 }
        return model.creditCost ?? model.category?.creditCostDefault ?? 2
    }

    /// Get speed estimate for the model
    var speedEstimate: String {
        guard let model = model else { return "~30s" }

        if let speedTag = model.speedTag {
            switch speedTag {
            case "instant": return "<5s"
            case "fast": return "5-30s"
            case "standard": return "30s-2m"
            case "slow": return "2m+"
            default: return "~30s"
            }
        }

        return model.estimatedTimeDisplay ?? "~30s"
    }

    /// Check if user has enough credits (requires CreditsViewModel integration)
    func hasEnoughCredits(userCredits: Int) -> Bool {
        return userCredits >= effectiveCreditCost
    }
}

// MARK: - Preview Helpers

#if DEBUG
extension ModelDetailViewModel {
    /// Create mock ViewModel for previews
    static func mock(model: ReplicateModel = .mockFlux) -> ModelDetailViewModel {
        let vm = ModelDetailViewModel()
        vm.model = model
        vm.schema = model.inputSchema
        vm.recentGenerations = ModelGeneration.mockGenerations
        return vm
    }

    /// Create mock ViewModel in loading state
    static func mockLoading() -> ModelDetailViewModel {
        let vm = ModelDetailViewModel()
        vm.modelLoading = true
        vm.schemaLoading = true
        return vm
    }

    /// Create mock ViewModel with execution result
    static func mockWithResult() -> ModelDetailViewModel {
        let vm = ModelDetailViewModel()
        vm.model = .mockFlux
        vm.schema = ReplicateModel.mockFlux.inputSchema
        vm.executionResult = .mockImageGeneration
        vm.executionStatus = .completed
        return vm
    }
}
#endif
