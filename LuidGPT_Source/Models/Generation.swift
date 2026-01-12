//
//  Generation.swift
//  LuidGPT
//
//  Model for AI generation results
//

import Foundation

/// AI Generation Result
struct Generation: Identifiable, Codable, Hashable {
    let id: String
    let userId: String
    let organizationId: String?
    let replicateModelId: String?
    let modelId: String // e.g., "openai/sora-2"
    let categorySlug: String
    let input: [String: AnyCodable]
    let output: AnyCodable?
    let outputUrl: String?
    let outputUrls: [String]
    let replicatePredictionId: String?
    let status: Status
    let errorMessage: String?
    let executionTimeMs: Int?
    let creditsUsed: Int?
    let isFavorite: Bool
    let title: String?
    let tags: [String]
    let metadata: [String: AnyCodable]?
    let createdAt: Date
    let updatedAt: Date

    // Relationships
    var replicateModel: ReplicateModel?
    var user: User?

    enum Status: String, Codable {
        case pending
        case processing
        case completed
        case failed
        case cancelled
    }

    enum CodingKeys: String, CodingKey {
        case id, userId, organizationId, replicateModelId, modelId, categorySlug
        case input, output, outputUrl, outputUrls, replicatePredictionId
        case status, errorMessage, executionTimeMs, creditsUsed
        case isFavorite, title, tags, metadata, createdAt, updatedAt
        case replicateModel, user
    }
}

// MARK: - Helper Methods

extension Generation {
    /// Get all output URLs (combined single + array)
    func allOutputUrls() -> [String] {
        var urls: [String] = []
        if let outputUrl = outputUrl {
            urls.append(outputUrl)
        }
        urls.append(contentsOf: outputUrls)
        return urls
    }

    /// Get primary output URL
    var primaryOutputUrl: String? {
        outputUrl ?? outputUrls.first
    }

    /// Detect output type from URL or category
    var outputType: OutputType {
        if let url = primaryOutputUrl {
            if url.contains(".mp4") || url.contains(".mov") || url.contains("video") {
                return .video
            }
            if url.contains(".jpg") || url.contains(".png") || url.contains(".webp") || url.contains("image") {
                return .image
            }
            if url.contains(".mp3") || url.contains(".wav") || url.contains("audio") {
                return .audio
            }
        }

        // Fallback to category
        switch categorySlug {
        case "video-generation":
            return .video
        case "image-generation", "image-editing", "upscaling", "face-avatar":
            return .image
        case "audio-speech", "music-generation":
            return .audio
        case "3d-models":
            return .threeDModel
        default:
            return .text
        }
    }

    enum OutputType {
        case image
        case video
        case audio
        case text
        case threeDModel
        case unknown
    }

    /// Get execution time display string
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

    /// Get status badge style
    var statusBadgeStyle: LGBadgeStyle.Status {
        switch status {
        case .completed:
            return .success
        case .failed, .cancelled:
            return .error
        case .pending:
            return .warning
        case .processing:
            return .processing
        }
    }

    /// Get time ago string
    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: createdAt, relativeTo: Date())
    }
}

// MARK: - Generation Request

/// Request body for creating a generation
struct GenerationRequest: Codable {
    let modelId: String
    let input: [String: AnyCodable]
    let organizationId: String?

    init(modelId: String, input: [String: Any], organizationId: String? = nil) {
        self.modelId = modelId
        self.input = input.mapValues { AnyCodable($0) }
        self.organizationId = organizationId
    }
}

// MARK: - Generation Update

/// Update generation metadata
struct GenerationUpdate: Codable {
    let isFavorite: Bool?
    let title: String?
    let tags: [String]?
}

// MARK: - Mock Data

extension Generation {
    static let mockCompleted = Generation(
        id: UUID().uuidString,
        userId: UUID().uuidString,
        organizationId: nil,
        replicateModelId: UUID().uuidString,
        modelId: "openai/sora-2",
        categorySlug: "video-generation",
        input: ["prompt": AnyCodable("A cat playing piano")],
        output: AnyCodable("https://example.com/output.mp4"),
        outputUrl: "https://example.com/output.mp4",
        outputUrls: [],
        replicatePredictionId: "abc123",
        status: .completed,
        errorMessage: nil,
        executionTimeMs: 45000,
        creditsUsed: 10,
        isFavorite: false,
        title: "Cat Piano Video",
        tags: ["video", "music"],
        metadata: nil,
        createdAt: Date().addingTimeInterval(-3600),
        updatedAt: Date(),
        replicateModel: ReplicateModel.mockSora2,
        user: nil
    )

    static let mockProcessing = Generation(
        id: UUID().uuidString,
        userId: UUID().uuidString,
        organizationId: nil,
        replicateModelId: UUID().uuidString,
        modelId: "black-forest-labs/flux-1.1-pro",
        categorySlug: "image-generation",
        input: ["prompt": AnyCodable("Sunset over mountains")],
        output: nil,
        outputUrl: nil,
        outputUrls: [],
        replicatePredictionId: "def456",
        status: .processing,
        errorMessage: nil,
        executionTimeMs: nil,
        creditsUsed: nil,
        isFavorite: false,
        title: nil,
        tags: [],
        metadata: nil,
        createdAt: Date().addingTimeInterval(-60),
        updatedAt: Date(),
        replicateModel: ReplicateModel.mockFlux,
        user: nil
    )

    static let mockFailed = Generation(
        id: UUID().uuidString,
        userId: UUID().uuidString,
        organizationId: nil,
        replicateModelId: UUID().uuidString,
        modelId: "openai/sora-2",
        categorySlug: "video-generation",
        input: ["prompt": AnyCodable("Invalid prompt")],
        output: nil,
        outputUrl: nil,
        outputUrls: [],
        replicatePredictionId: "ghi789",
        status: .failed,
        errorMessage: "The prompt contained prohibited content",
        executionTimeMs: 5000,
        creditsUsed: 0,
        isFavorite: false,
        title: nil,
        tags: [],
        metadata: nil,
        createdAt: Date().addingTimeInterval(-7200),
        updatedAt: Date(),
        replicateModel: ReplicateModel.mockSora2,
        user: nil
    )

    static let mockGenerations = [mockCompleted, mockProcessing, mockFailed]
}
