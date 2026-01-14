//
//  ModelsService.swift
//  LuidGPT
//
//  Service for fetching AI models, categories, and executing generations
//

import Foundation

/// Response models for API (matching backend format)
struct CategoriesAPIResponse: Codable {
    let success: Bool
    let data: [Category]
}

struct ModelsAPIResponse: Codable {
    let success: Bool
    let data: [ReplicateModel]
    let pagination: PaginationInfo?
    let category: Category?

    struct PaginationInfo: Codable {
        let page: Int
        let limit: Int
        let total: Int
        let pages: Int // Backend returns "pages" not "totalPages"

        // Computed property for convenience
        var hasMore: Bool {
            return page < pages
        }

        enum CodingKeys: String, CodingKey {
            case page, limit, total, pages
        }
    }
}

struct ModelAPIResponse: Codable {
    let success: Bool
    let data: ReplicateModel
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
        let response: CategoriesAPIResponse = try await client.get("/models/categories", requiresAuth: false)
        return response.data
    }

    /// Get category by slug
    func getCategory(slug: String) async throws -> Category {
        let response: CategoriesAPIResponse = try await client.get("/models/categories/\(slug)", requiresAuth: false)
        return response.data.first ?? Category(_id: "", slug: slug, name: "", description: nil, iconEmoji: nil, creditCostDefault: 2, outputType: .utility, sortOrder: 0, isActive: true, metadata: nil, createdAt: nil, updatedAt: nil, modelCount: nil)
    }

    /// Get models in a category (with pagination)
    func getCategoryModels(slug: String, page: Int = 1, limit: Int = 20) async throws -> (models: [ReplicateModel], pagination: ModelsAPIResponse.PaginationInfo?, category: Category?) {
        let params: [String: Any] = [
            "page": page,
            "limit": limit
        ]
        let response: ModelsAPIResponse = try await client.get(
            "/models/categories/\(slug)/models",
            parameters: params,
            requiresAuth: false
        )
        return (models: response.data, pagination: response.pagination, category: response.category)
    }

    // MARK: - Models

    /// Search models (with pagination)
    func searchModels(query: String, page: Int = 1, limit: Int = 20) async throws -> (models: [ReplicateModel], pagination: ModelsAPIResponse.PaginationInfo?) {
        let params: [String: Any] = [
            "q": query,
            "page": page,
            "limit": limit
        ]
        let response: ModelsAPIResponse = try await client.get(
            "/models/search",
            parameters: params,
            requiresAuth: false
        )
        return (models: response.data, pagination: response.pagination)
    }

    /// Get featured models
    func getFeaturedModels(limit: Int = 10) async throws -> [ReplicateModel] {
        let params: [String: Any] = ["limit": limit]
        let response: ModelsAPIResponse = try await client.get(
            "/models/featured",
            parameters: params,
            requiresAuth: false
        )
        return response.data
    }

    /// Get model by ID
    func getModel(id: String) async throws -> ReplicateModel {
        // URL encode the model ID (contains slashes)
        let encodedId = id.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? id
        let response: ModelAPIResponse = try await client.get(
            "/models/\(encodedId)",
            requiresAuth: false
        )
        return response.data
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
