//
//  ModelGeneration.swift
//  LuidGPT
//
//  Model for tracking AI model generation history
//

import Foundation

/// Represents a single model execution/generation
struct ModelGeneration: Identifiable, Codable, Hashable {
    let id: String
    let userId: String
    let organizationId: String?
    let replicateModelId: String // UUID of ReplicateModel
    let modelId: String // e.g., "openai/sora-2"
    let categorySlug: String
    let input: [String: AnyCodable] // Input parameters used
    let output: AnyCodable? // Raw output from Replicate
    let outputUrl: String? // Primary output URL (image, video, audio)
    let outputUrls: [String]? // Multiple outputs (if applicable)
    let status: GenerationStatus
    let errorMessage: String?
    let creditsUsed: Int
    let executionTimeMs: Int? // Execution time in milliseconds
    let title: String? // User-provided title
    let tags: [String]? // User-provided tags
    let isFavorite: Bool
    let createdAt: String // ISO 8601 string
    let updatedAt: String // ISO 8601 string

    // Relationships (may be populated by API)
    var replicateModel: ReplicateModel?

    enum CodingKeys: String, CodingKey {
        case id, userId, organizationId, replicateModelId, modelId, categorySlug
        case input, output, outputUrl, outputUrls, status, errorMessage
        case creditsUsed, executionTimeMs, title, tags, isFavorite
        case createdAt, updatedAt, replicateModel
    }

    // Memberwise initializer (restored since custom init removes automatic one)
    init(
        id: String,
        userId: String,
        organizationId: String?,
        replicateModelId: String,
        modelId: String,
        categorySlug: String,
        input: [String: AnyCodable],
        output: AnyCodable?,
        outputUrl: String?,
        outputUrls: [String]?,
        status: GenerationStatus,
        errorMessage: String?,
        creditsUsed: Int,
        executionTimeMs: Int?,
        title: String?,
        tags: [String]?,
        isFavorite: Bool,
        createdAt: String,
        updatedAt: String,
        replicateModel: ReplicateModel?
    ) {
        self.id = id
        self.userId = userId
        self.organizationId = organizationId
        self.replicateModelId = replicateModelId
        self.modelId = modelId
        self.categorySlug = categorySlug
        self.input = input
        self.output = output
        self.outputUrl = outputUrl
        self.outputUrls = outputUrls
        self.status = status
        self.errorMessage = errorMessage
        self.creditsUsed = creditsUsed
        self.executionTimeMs = executionTimeMs
        self.title = title
        self.tags = tags
        self.isFavorite = isFavorite
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.replicateModel = replicateModel
    }

    // Custom decoding to handle null/missing replicateModel
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(String.self, forKey: .id)
        userId = try container.decode(String.self, forKey: .userId)
        organizationId = try container.decodeIfPresent(String.self, forKey: .organizationId)
        replicateModelId = try container.decode(String.self, forKey: .replicateModelId)
        modelId = try container.decode(String.self, forKey: .modelId)
        categorySlug = try container.decode(String.self, forKey: .categorySlug)
        input = try container.decode([String: AnyCodable].self, forKey: .input)
        output = try container.decodeIfPresent(AnyCodable.self, forKey: .output)
        outputUrl = try container.decodeIfPresent(String.self, forKey: .outputUrl)
        outputUrls = try container.decodeIfPresent([String].self, forKey: .outputUrls)
        status = try container.decode(GenerationStatus.self, forKey: .status)
        errorMessage = try container.decodeIfPresent(String.self, forKey: .errorMessage)
        creditsUsed = try container.decode(Int.self, forKey: .creditsUsed)
        executionTimeMs = try container.decodeIfPresent(Int.self, forKey: .executionTimeMs)
        title = try container.decodeIfPresent(String.self, forKey: .title)
        tags = try container.decodeIfPresent([String].self, forKey: .tags)
        isFavorite = try container.decode(Bool.self, forKey: .isFavorite)
        createdAt = try container.decode(String.self, forKey: .createdAt)
        updatedAt = try container.decode(String.self, forKey: .updatedAt)

        // Handle replicateModel gracefully - it may be null or missing
        replicateModel = try? container.decodeIfPresent(ReplicateModel.self, forKey: .replicateModel)
    }

    enum GenerationStatus: String, Codable {
        case pending
        case processing
        case completed
        case failed
        case cancelled

        var displayName: String {
            rawValue.capitalized
        }

        var isFinished: Bool {
            self == .completed || self == .failed || self == .cancelled
        }

        var isRunning: Bool {
            self == .pending || self == .processing
        }
    }
}

// MARK: - Helper Methods

extension ModelGeneration {
    /// Get formatted creation date
    var createdDate: Date? {
        ISO8601DateFormatter().date(from: createdAt)
    }

    /// Get formatted execution time
    var executionTimeDisplay: String? {
        guard let ms = executionTimeMs else { return nil }

        let seconds = Double(ms) / 1000.0

        if seconds < 1 {
            return "<1s"
        } else if seconds < 60 {
            return String(format: "%.1fs", seconds)
        } else {
            let minutes = Int(seconds / 60)
            let remainingSeconds = Int(seconds) % 60
            return "\(minutes)m \(remainingSeconds)s"
        }
    }

    /// Check if output is an image
    var isImageOutput: Bool {
        guard let url = outputUrl else { return false }
        let lowercased = url.lowercased()
        return lowercased.contains(".jpg") ||
               lowercased.contains(".jpeg") ||
               lowercased.contains(".png") ||
               lowercased.contains(".webp") ||
               lowercased.contains(".gif") ||
               lowercased.contains("image")
    }

    /// Check if output is a video
    var isVideoOutput: Bool {
        guard let url = outputUrl else { return false }
        let lowercased = url.lowercased()
        return lowercased.contains(".mp4") ||
               lowercased.contains(".webm") ||
               lowercased.contains(".mov") ||
               lowercased.contains("video")
    }

    /// Check if output is audio
    var isAudioOutput: Bool {
        guard let url = outputUrl else { return false }
        let lowercased = url.lowercased()
        return lowercased.contains(".mp3") ||
               lowercased.contains(".wav") ||
               lowercased.contains(".flac") ||
               lowercased.contains("audio")
    }

    /// Get all outputs (including multiple)
    var allOutputUrls: [String] {
        var urls: [String] = []
        if let outputUrl = outputUrl {
            urls.append(outputUrl)
        }
        if let outputUrls = outputUrls {
            urls.append(contentsOf: outputUrls)
        }
        return Array(Set(urls)) // Remove duplicates
    }
}

// MARK: - API Response Models

struct ModelsGenerationsResponse: Codable {
    let success: Bool
    let data: [ModelGeneration]
    let pagination: Pagination?

    struct Pagination: Codable {
        let total: Int
        let page: Int
        let limit: Int
        let pages: Int
    }
}

struct ModelsGenerationResponse: Codable {
    let success: Bool
    let data: ModelGeneration
}

struct ExecuteModelRequest: Codable {
    let input: [String: AnyCodable]
    let organizationId: String?
    let title: String?
    let tags: [String]?
}

struct ExecuteModelResponse: Codable {
    let success: Bool
    let data: ExecutionResult
    let creditsDeducted: Int?
    let creditRequestId: String?

    struct ExecutionResult: Codable {
        let id: String
        let modelId: String
        let status: String
        let outputUrl: String?
        let outputUrls: [String]?
        let output: AnyCodable?
        let executionTimeMs: Int?
        let creditsUsed: Int
        let model: ModelInfo?

        struct ModelInfo: Codable {
            let name: String
            let provider: String?
            let category: String?
        }
    }

    enum CodingKeys: String, CodingKey {
        case success, data
        case creditsDeducted = "credits_deducted"
        case creditRequestId = "credit_request_id"
    }
}

// MARK: - Mock Data

extension ModelGeneration {
    static let mockImageGeneration = ModelGeneration(
        id: UUID().uuidString,
        userId: UUID().uuidString,
        organizationId: nil,
        replicateModelId: UUID().uuidString,
        modelId: "black-forest-labs/flux-1.1-pro",
        categorySlug: "image-generation",
        input: [
            "prompt": AnyCodable("A beautiful sunset over mountains"),
            "width": AnyCodable(1024),
            "height": AnyCodable(1024)
        ],
        output: AnyCodable("https://example.com/generated-image.png"),
        outputUrl: "https://example.com/generated-image.png",
        outputUrls: nil,
        status: .completed,
        errorMessage: nil,
        creditsUsed: 2,
        executionTimeMs: 3450,
        title: "Sunset Mountains",
        tags: ["landscape", "nature"],
        isFavorite: false,
        createdAt: ISO8601DateFormatter().string(from: Date()),
        updatedAt: ISO8601DateFormatter().string(from: Date()),
        replicateModel: ReplicateModel.mockFlux
    )

    static let mockVideoGeneration = ModelGeneration(
        id: UUID().uuidString,
        userId: UUID().uuidString,
        organizationId: nil,
        replicateModelId: UUID().uuidString,
        modelId: "openai/sora-2",
        categorySlug: "video-generation",
        input: [
            "prompt": AnyCodable("A person walking through Tokyo at night"),
            "duration": AnyCodable(5)
        ],
        output: AnyCodable("https://example.com/generated-video.mp4"),
        outputUrl: "https://example.com/generated-video.mp4",
        outputUrls: nil,
        status: .processing,
        errorMessage: nil,
        creditsUsed: 10,
        executionTimeMs: nil,
        title: "Tokyo Night Walk",
        tags: ["urban", "cinematic"],
        isFavorite: true,
        createdAt: ISO8601DateFormatter().string(from: Date().addingTimeInterval(-3600)),
        updatedAt: ISO8601DateFormatter().string(from: Date()),
        replicateModel: ReplicateModel.mockSora2
    )

    static let mockGenerations = [mockImageGeneration, mockVideoGeneration]

    /// Create a placeholder generation for loading states
    static func placeholder(modelId: String) -> ModelGeneration {
        ModelGeneration(
            id: UUID().uuidString,
            userId: "",
            organizationId: nil,
            replicateModelId: "",
            modelId: modelId,
            categorySlug: "",
            input: [:],
            output: nil,
            outputUrl: nil,
            outputUrls: nil,
            status: .pending,
            errorMessage: nil,
            creditsUsed: 0,
            executionTimeMs: nil,
            title: nil,
            tags: nil,
            isFavorite: false,
            createdAt: ISO8601DateFormatter().string(from: Date()),
            updatedAt: ISO8601DateFormatter().string(from: Date()),
            replicateModel: nil
        )
    }
}
