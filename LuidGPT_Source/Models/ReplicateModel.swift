//
//  ReplicateModel.swift
//  LuidGPT
//
//  Model for Replicate AI models (100+ models from the dynamic registry)
//

import Foundation

/// Replicate AI Model
struct ReplicateModel: Identifiable, Codable, Hashable {
    let id: String
    let modelId: String // e.g., "openai/sora-2"
    let name: String
    let description: String?
    let categoryId: String // UUID of category
    let provider: String? // e.g., "openai", "black-forest-labs"
    let version: String?
    let creditCost: Int?
    let estimatedTimeSeconds: Int?
    let inputSchema: InputSchema?
    let supportedFeatures: [String]?
    let tier: Tier
    let maxResolution: String?
    let isActive: Bool
    let isFeatured: Bool
    let isNew: Bool?
    let thumbnailUrl: String?
    let coverImage: String? // Added to match backend
    let outputType: String? // Added to match backend (video, image, audio, etc.)
    let exampleOutputs: [String]?
    let tags: [String]?
    let runCount: Int?
    let metadata: [String: AnyCodable]?
    let createdAt: String? // Changed to String to match backend ISO format
    let updatedAt: String? // Changed to String to match backend ISO format

    // Relationship (may be populated by API)
    var category: Category?

    enum Tier: String, Codable {
        case free
        case standard
        case premium
        case enterprise

        var displayName: String {
            return rawValue.capitalized
        }
    }

    enum CodingKeys: String, CodingKey {
        case id, modelId, name, description, categoryId, provider, version
        case creditCost, estimatedTimeSeconds, inputSchema, supportedFeatures
        case tier, maxResolution, isActive, isFeatured, isNew
        case thumbnailUrl, coverImage, outputType, exampleOutputs, tags, runCount, metadata
        case createdAt, updatedAt, category
    }

    // Computed property for display image
    var displayImage: String? {
        return coverImage ?? thumbnailUrl
    }

    // Computed property to get category slug
    var categorySlug: String {
        return category?.slug ?? "utility"
    }
}

// MARK: - Input Schema

/// Dynamic input schema for model parameters
struct InputSchema: Codable, Hashable {
    let type: String?
    let properties: [String: InputProperty]
    let required: [String]

    enum CodingKeys: String, CodingKey {
        case type, properties, required
    }
}

/// Individual input property definition
struct InputProperty: Codable, Hashable {
    let type: String? // Optional because some properties use allOf/ref instead
    let title: String?
    let description: String?
    let defaultValue: AnyCodable?
    let enumValues: [String]?
    let minimum: Double?
    let maximum: Double?
    let format: String?

    enum CodingKeys: String, CodingKey {
        case type, title, description
        case defaultValue = "default"
        case enumValues = "enum"
        case minimum, maximum, format
    }
}

// MARK: - Helper Methods

extension ReplicateModel {
    /// Get effective credit cost (model-specific or category default)
    func effectiveCreditCost(categoryDefaults: [String: Int] = [:]) -> Int {
        if let creditCost = creditCost {
            return creditCost
        }
        if let category = category {
            return category.creditCostDefault
        }
        // Fallback to category defaults if available
        return category?.creditCostDefault ?? 2
    }

    /// Get display name for provider
    var providerDisplayName: String? {
        provider?.components(separatedBy: "-")
            .map { $0.capitalized }
            .joined(separator: " ")
    }

    /// Get estimated time display string
    var estimatedTimeDisplay: String? {
        guard let seconds = estimatedTimeSeconds else { return nil }

        if seconds < 5 {
            return "<5s"
        } else if seconds < 60 {
            return "\(seconds)s"
        } else {
            let minutes = seconds / 60
            return "\(minutes)m"
        }
    }

    /// Check if model has specific tag
    func hasTag(_ tag: String) -> Bool {
        tags?.contains(tag) ?? false
    }

    /// Filter tags by prefix (e.g., "style:")
    func tags(withPrefix prefix: String) -> [String] {
        tags?.filter { $0.hasPrefix(prefix) }
            .map { $0.replacingOccurrences(of: "\(prefix)", with: "") } ?? []
    }

    /// Get style tags
    var styleTags: [String] {
        tags(withPrefix: "style:")
    }

    /// Get speed tag
    var speedTag: String? {
        tags?.first { $0.hasPrefix("speed:") }?
            .replacingOccurrences(of: "speed:", with: "")
    }

    /// Get quality tag
    var qualityTag: String? {
        tags?.first { $0.hasPrefix("quality:") }?
            .replacingOccurrences(of: "quality:", with: "")
    }
}

// MARK: - API Response Models

struct ModelsResponse: Codable {
    let models: [ReplicateModel]
    let pagination: Pagination?

    struct Pagination: Codable {
        let page: Int
        let limit: Int
        let total: Int
        let totalPages: Int
        let hasMore: Bool
    }
}

struct FeaturedModelsResponse: Codable {
    let models: [ReplicateModel]
}

struct ModelDetailResponse: Codable {
    let model: ReplicateModel
}

// MARK: - Mock Data

extension ReplicateModel {
    static let mockSora2 = ReplicateModel(
        id: UUID().uuidString,
        modelId: "openai/sora-2",
        name: "Sora 2",
        description: "OpenAI's state-of-the-art text-to-video model",
        categoryId: UUID().uuidString,
        provider: "openai",
        version: "1.0",
        creditCost: 10,
        estimatedTimeSeconds: 120,
        inputSchema: InputSchema(
            type: "object",
            properties: [
                "prompt": InputProperty(
                    type: "string",
                    title: "Prompt",
                    description: "Describe the video you want to generate",
                    defaultValue: nil,
                    enumValues: nil,
                    minimum: nil,
                    maximum: nil,
                    format: nil
                ),
                "duration": InputProperty(
                    type: "integer",
                    title: "Duration",
                    description: "Video duration in seconds",
                    defaultValue: AnyCodable(5),
                    enumValues: nil,
                    minimum: 3,
                    maximum: 10,
                    format: nil
                ),
            ],
            required: ["prompt"]
        ),
        supportedFeatures: ["text-to-video", "high-resolution"],
        tier: .premium,
        maxResolution: "1920x1080",
        isActive: true,
        isFeatured: true,
        isNew: true,
        thumbnailUrl: "https://example.com/sora2.jpg",
        coverImage: nil,
        outputType: "video",
        exampleOutputs: [],
        tags: ["style:cinematic", "speed:slow", "quality:best"],
        runCount: 1234,
        metadata: nil,
        createdAt: nil,
        updatedAt: nil,
        category: Category.mockVideoGeneration
    )

    static let mockFlux = ReplicateModel(
        id: UUID().uuidString,
        modelId: "black-forest-labs/flux-1.1-pro",
        name: "FLUX 1.1 Pro",
        description: "Ultra-fast photorealistic image generation",
        categoryId: UUID().uuidString,
        provider: "black-forest-labs",
        version: "1.1",
        creditCost: 2,
        estimatedTimeSeconds: 3,
        inputSchema: nil,
        supportedFeatures: ["text-to-image", "fast"],
        tier: .standard,
        maxResolution: "2048x2048",
        isActive: true,
        isFeatured: true,
        isNew: false,
        thumbnailUrl: "https://example.com/flux.jpg",
        coverImage: nil,
        outputType: "image",
        exampleOutputs: [],
        tags: ["style:photorealistic", "speed:instant", "quality:high"],
        runCount: 5678,
        metadata: nil,
        createdAt: nil,
        updatedAt: nil,
        category: Category.mockImageGeneration
    )

    static let mockModels = [mockSora2, mockFlux]
}
