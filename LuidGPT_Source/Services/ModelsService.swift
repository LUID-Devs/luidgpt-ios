//
//  ModelsService.swift
//  LuidGPT
//
//  Service for fetching AI models, categories, and executing generations
//

import Foundation

/// Response models for API
struct CategoriesResponse: Codable {
    let success: Bool
    let categories: [Category]
}

struct ModelsResponse: Codable {
    let success: Bool
    let models: [ReplicateModel]
    let total: Int?
    let page: Int?
    let limit: Int?
}

struct ModelResponse: Codable {
    let success: Bool
    let model: ReplicateModel
}

struct ModelSchemaResponse: Codable {
    let success: Bool
    let schema: ModelSchema
}

struct ModelSchema: Codable {
    let parameters: [ModelParameter]
}

struct ModelParameter: Codable {
    let name: String
    let type: String
    let description: String?
    let required: Bool
    let `default`: AnyCodable?
    let options: [String]?
    let minimum: Double?
    let maximum: Double?
}

struct RunModelResponse: Codable {
    let success: Bool
    let generation: Generation
    let creditsDeducted: Int?
    let creditRequestId: String?

    enum CodingKeys: String, CodingKey {
        case success
        case generation
        case creditsDeducted = "credits_deducted"
        case creditRequestId = "credit_request_id"
    }
}

/// Models Service - Handles all model-related API calls
class ModelsService {
    static let shared = ModelsService()
    private let client = APIClient.shared

    private init() {}

    // MARK: - Categories

    /// Get all categories
    func getCategories() async throws -> [Category] {
        let response: CategoriesResponse = try await client.get("/models/categories", requiresAuth: false)
        return response.categories
    }

    /// Get category by slug
    func getCategory(slug: String) async throws -> Category {
        struct CategoryResponse: Codable {
            let success: Bool
            let category: Category
        }
        let response: CategoryResponse = try await client.get("/models/categories/\(slug)", requiresAuth: false)
        return response.category
    }

    /// Get models in a category
    func getCategoryModels(slug: String, page: Int = 1, limit: Int = 20) async throws -> [ReplicateModel] {
        let params: [String: Any] = [
            "page": page,
            "limit": limit
        ]
        let response: ModelsResponse = try await client.get(
            "/models/categories/\(slug)/models",
            parameters: params,
            requiresAuth: false
        )
        return response.models
    }

    // MARK: - Models

    /// Search models
    func searchModels(query: String, page: Int = 1, limit: Int = 20) async throws -> [ReplicateModel] {
        let params: [String: Any] = [
            "q": query,
            "page": page,
            "limit": limit
        ]
        let response: ModelsResponse = try await client.get(
            "/models/search",
            parameters: params,
            requiresAuth: false
        )
        return response.models
    }

    /// Get featured models
    func getFeaturedModels(limit: Int = 10) async throws -> [ReplicateModel] {
        let params: [String: Any] = ["limit": limit]
        let response: ModelsResponse = try await client.get(
            "/models/featured",
            parameters: params,
            requiresAuth: false
        )
        return response.models
    }

    /// Get model by ID
    func getModel(id: String) async throws -> ReplicateModel {
        // URL encode the model ID (contains slashes)
        let encodedId = id.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? id
        let response: ModelResponse = try await client.get(
            "/models/\(encodedId)",
            requiresAuth: false
        )
        return response.model
    }

    /// Get model schema (parameters)
    func getModelSchema(id: String) async throws -> ModelSchema {
        let encodedId = id.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? id
        let response: ModelSchemaResponse = try await client.get(
            "/models/\(encodedId)/schema",
            requiresAuth: false
        )
        return response.schema
    }

    // MARK: - Model Execution

    /// Run a model with parameters
    func runModel(id: String, parameters: [String: Any]) async throws -> Generation {
        let encodedId = id.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? id
        let response: RunModelResponse = try await client.post(
            "/models/\(encodedId)/run",
            parameters: parameters,
            requiresAuth: true
        )
        return response.generation
    }

    /// Upload file and run model
    func runModelWithFile(
        id: String,
        fileData: Data,
        fileName: String,
        mimeType: String,
        parameters: [String: String]
    ) async throws -> Generation {
        let encodedId = id.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? id
        let response: RunModelResponse = try await client.uploadFile(
            "/models/\(encodedId)/run",
            fileData: fileData,
            fileName: fileName,
            mimeType: mimeType,
            parameters: parameters,
            requiresAuth: true
        )
        return response.generation
    }
}
