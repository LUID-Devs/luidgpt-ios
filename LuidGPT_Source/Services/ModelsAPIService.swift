//
//  ModelsAPIService.swift
//  LuidGPT
//
//  API service for model operations (detail, schema, execution, generations)
//

import Foundation

/// Service for model-related API operations
class ModelsAPIService {
    static let shared = ModelsAPIService()

    private let apiClient = APIClient.shared

    private init() {}

    // MARK: - Model Details

    /// Fetch detailed information for a specific model
    /// GET /api/models/:modelId
    func fetchModelDetails(modelId: String) async throws -> ReplicateModel {
        // URL encode the model ID (e.g., "openai/sora-2" -> "openai%2Fsora-2")
        var allowedCharacters = CharacterSet.urlPathAllowed
        allowedCharacters.remove(charactersIn: "/")
        let encodedModelId = modelId.addingPercentEncoding(withAllowedCharacters: allowedCharacters) ?? modelId

        let endpoint = "/models/\(encodedModelId)"

        struct Response: Codable {
            let success: Bool
            let data: ReplicateModel
        }

        let response: Response = try await apiClient.get(endpoint, requiresAuth: false)

        if !response.success {
            throw APIError.serverError("Failed to fetch model details")
        }

        return response.data
    }

    /// Fetch input schema for a model
    /// GET /api/models/:modelId/schema
    func fetchModelSchema(modelId: String) async throws -> InputSchema {
        var allowedCharacters = CharacterSet.urlPathAllowed
        allowedCharacters.remove(charactersIn: "/")
        let encodedModelId = modelId.addingPercentEncoding(withAllowedCharacters: allowedCharacters) ?? modelId

        let endpoint = "/models/\(encodedModelId)/schema"

        struct Response: Codable {
            let success: Bool
            let data: SchemaData

            struct SchemaData: Codable {
                let inputSchema: InputSchema
                let modelId: String
            }
        }

        let response: Response = try await apiClient.get(endpoint, requiresAuth: false)

        if !response.success {
            throw APIError.serverError("Failed to fetch model schema")
        }

        return response.data.inputSchema
    }

    // MARK: - Model Execution

    /// Execute a model with given inputs
    /// POST /api/models/:modelId/run
    func executeModel(
        modelId: String,
        input: [String: Any],
        organizationId: String? = nil,
        title: String? = nil,
        tags: [String]? = nil
    ) async throws -> ModelGeneration {
        var allowedCharacters = CharacterSet.urlPathAllowed
        allowedCharacters.remove(charactersIn: "/")
        let encodedModelId = modelId.addingPercentEncoding(withAllowedCharacters: allowedCharacters) ?? modelId

        let endpoint = "/models/\(encodedModelId)/run"

        // Convert input to AnyCodable for JSON encoding
        var inputCodable: [String: AnyCodable] = [:]
        for (key, value) in input {
            inputCodable[key] = AnyCodable(value)
        }

        let params: [String: Any] = [
            "input": inputCodable,
            "organizationId": organizationId as Any,
            "title": title as Any,
            "tags": tags as Any
        ]

        let response: ExecuteModelResponse = try await apiClient.post(
            endpoint,
            parameters: params,
            requiresAuth: true
        )

        if !response.success {
            throw APIError.serverError("Failed to execute model")
        }

        // Convert execution result to ModelGeneration
        return ModelGeneration(
            id: response.data.id,
            userId: "", // Will be populated by backend
            organizationId: organizationId,
            replicateModelId: "", // Will be populated by backend
            modelId: response.data.modelId,
            categorySlug: response.data.model?.category ?? "unknown",
            input: inputCodable,
            output: response.data.output,
            outputUrl: response.data.outputUrl,
            outputUrls: response.data.outputUrls,
            status: ModelGeneration.GenerationStatus(rawValue: response.data.status) ?? .pending,
            errorMessage: nil,
            creditsUsed: response.data.creditsUsed,
            executionTimeMs: response.data.executionTimeMs,
            title: title,
            tags: tags,
            isFavorite: false,
            createdAt: ISO8601DateFormatter().string(from: Date()),
            updatedAt: ISO8601DateFormatter().string(from: Date()),
            replicateModel: nil
        )
    }

    // MARK: - Generation History

    /// Fetch user's generation history
    /// GET /api/models/user/generations
    func fetchGenerations(
        page: Int = 1,
        limit: Int = 20,
        organizationId: String? = nil,
        categorySlug: String? = nil,
        modelId: String? = nil,
        status: String? = nil,
        favorite: Bool? = nil
    ) async throws -> (generations: [ModelGeneration], pagination: ModelsGenerationsResponse.Pagination?) {
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "limit", value: String(limit))
        ]

        if let organizationId = organizationId {
            queryItems.append(URLQueryItem(name: "organizationId", value: organizationId))
        }

        if let categorySlug = categorySlug {
            queryItems.append(URLQueryItem(name: "categorySlug", value: categorySlug))
        }

        if let modelId = modelId {
            let encoded = modelId.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? modelId
            queryItems.append(URLQueryItem(name: "modelId", value: encoded))
        }

        if let status = status {
            queryItems.append(URLQueryItem(name: "status", value: status))
        }

        if let favorite = favorite, favorite {
            queryItems.append(URLQueryItem(name: "favorite", value: "true"))
        }

        // Build query string
        var components = URLComponents(string: "/models/user/generations")!
        components.queryItems = queryItems
        let endpoint = components.url!.path + (components.query.map { "?\($0)" } ?? "")

        let response: ModelsGenerationsResponse = try await apiClient.get(
            endpoint,
            requiresAuth: true
        )

        if !response.success {
            throw APIError.serverError("Failed to fetch generations")
        }

        return (response.data, response.pagination)
    }

    /// Fetch a single generation by ID
    /// GET /api/models/user/generations/:id
    func fetchGeneration(id: String) async throws -> ModelGeneration {
        let endpoint = "/models/user/generations/\(id)"

        let response: ModelsGenerationResponse = try await apiClient.get(
            endpoint,
            requiresAuth: true
        )

        if !response.success {
            throw APIError.serverError("Failed to fetch generation")
        }

        return response.data
    }

    /// Update a generation (favorite, title, tags)
    /// PATCH /api/models/user/generations/:id
    func updateGeneration(
        id: String,
        isFavorite: Bool? = nil,
        title: String? = nil,
        tags: [String]? = nil
    ) async throws -> ModelGeneration {
        let endpoint = "/models/user/generations/\(id)"

        var params: [String: Any] = [:]
        if let isFavorite = isFavorite {
            params["isFavorite"] = isFavorite
        }
        if let title = title {
            params["title"] = title
        }
        if let tags = tags {
            params["tags"] = tags
        }

        struct Response: Codable {
            let success: Bool
            let data: ModelGeneration
        }

        let response: Response = try await apiClient.patch(
            endpoint,
            parameters: params,
            requiresAuth: true
        )

        if !response.success {
            throw APIError.serverError("Failed to update generation")
        }

        return response.data
    }

    /// Delete a generation
    /// DELETE /api/models/user/generations/:id
    func deleteGeneration(id: String) async throws {
        let endpoint = "/models/user/generations/\(id)"

        struct Response: Codable {
            let success: Bool
            let message: String
        }

        let response: Response = try await apiClient.delete(
            endpoint,
            requiresAuth: true
        )

        if !response.success {
            throw APIError.serverError(response.message)
        }
    }

    /// Cancel a running generation
    /// POST /api/models/user/generations/:id/cancel
    func cancelGeneration(id: String) async throws -> ModelGeneration {
        let endpoint = "/models/user/generations/\(id)/cancel"

        let response: ModelsGenerationResponse = try await apiClient.post(
            endpoint,
            requiresAuth: true
        )

        if !response.success {
            throw APIError.serverError("Failed to cancel generation")
        }

        return response.data
    }
}
