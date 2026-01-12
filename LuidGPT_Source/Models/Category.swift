//
//  Category.swift
//  LuidGPT
//
//  Model for AI model categories (11 categories)
//

import Foundation

/// Replicate Model Category
struct Category: Identifiable, Codable, Hashable {
    let id: String
    let slug: String
    let name: String
    let description: String?
    let iconEmoji: String?
    let creditCostDefault: Int
    let outputType: OutputType
    let sortOrder: Int
    let isActive: Bool
    let metadata: [String: AnyCodable]?
    let createdAt: Date?
    let updatedAt: Date?

    // Computed: Model count (from API relationship)
    var modelCount: Int?

    enum OutputType: String, Codable {
        case video
        case image
        case audio
        case text
        case threeDModel = "3d"
        case utility
    }

    enum CodingKeys: String, CodingKey {
        case id, slug, name, description, iconEmoji, creditCostDefault
        case outputType, sortOrder, isActive, metadata, createdAt, updatedAt
        case modelCount
    }
}

// MARK: - Static Category Definitions

extension Category {
    /// Static list of 11 categories matching the backend
    static let allCategories: [CategoryDefinition] = [
        CategoryDefinition(
            slug: "video-generation",
            name: "Video Generation",
            description: "Generate videos from text prompts or images",
            icon: "video.fill",
            outputType: .video,
            sortOrder: 1
        ),
        CategoryDefinition(
            slug: "image-generation",
            name: "Image Generation",
            description: "Generate images from text prompts",
            icon: "photo.fill",
            outputType: .image,
            sortOrder: 2
        ),
        CategoryDefinition(
            slug: "image-editing",
            name: "Image Editing",
            description: "Edit, enhance, and transform images",
            icon: "wand.and.stars",
            outputType: .image,
            sortOrder: 3
        ),
        CategoryDefinition(
            slug: "text-generation",
            name: "Text Generation",
            description: "Large language models for text generation",
            icon: "message.fill",
            outputType: .text,
            sortOrder: 4
        ),
        CategoryDefinition(
            slug: "audio-speech",
            name: "Audio & Speech",
            description: "Text-to-speech, voice cloning, and audio generation",
            icon: "mic.fill",
            outputType: .audio,
            sortOrder: 5
        ),
        CategoryDefinition(
            slug: "music-generation",
            name: "Music Generation",
            description: "Generate music and songs with AI",
            icon: "music.note",
            outputType: .audio,
            sortOrder: 6
        ),
        CategoryDefinition(
            slug: "upscaling",
            name: "Upscaling",
            description: "Enhance image and video resolution",
            icon: "arrow.up.right.square.fill",
            outputType: .image,
            sortOrder: 7
        ),
        CategoryDefinition(
            slug: "vision-documents",
            name: "Vision & Documents",
            description: "OCR, document analysis, and visual understanding",
            icon: "doc.text.magnifyingglass",
            outputType: .text,
            sortOrder: 8
        ),
        CategoryDefinition(
            slug: "3d-models",
            name: "3D Models",
            description: "Generate 3D content from images or text",
            icon: "cube.fill",
            outputType: .threeDModel,
            sortOrder: 9
        ),
        CategoryDefinition(
            slug: "face-avatar",
            name: "Face & Avatar",
            description: "Face generation, swapping, and avatar creation",
            icon: "person.fill",
            outputType: .image,
            sortOrder: 10
        ),
        CategoryDefinition(
            slug: "utility",
            name: "Utility",
            description: "Background removal, NSFW detection, and other utilities",
            icon: "wrench.and.screwdriver.fill",
            outputType: .utility,
            sortOrder: 11
        ),
    ]

    struct CategoryDefinition {
        let slug: String
        let name: String
        let description: String
        let icon: String // SF Symbol name
        let outputType: OutputType
        let sortOrder: Int
    }

    /// Get SF Symbol icon name for a category slug
    static func icon(for slug: String) -> String {
        allCategories.first { $0.slug == slug }?.icon ?? "square.grid.2x2"
    }

    /// Get default credit cost for a category
    static func defaultCredits(for slug: String) -> Int {
        switch slug {
        case "video-generation": return 10
        case "image-generation": return 2
        case "image-editing": return 2
        case "text-generation": return 1
        case "audio-speech": return 3
        case "music-generation": return 5
        case "upscaling": return 2
        case "vision-documents": return 1
        case "3d-models": return 8
        case "face-avatar": return 5
        case "utility": return 1
        default: return 2
        }
    }
}

// MARK: - Mock Data

extension Category {
    static let mockVideoGeneration = Category(
        id: UUID().uuidString,
        slug: "video-generation",
        name: "Video Generation",
        description: "Generate videos from text prompts or images",
        iconEmoji: "🎬",
        creditCostDefault: 10,
        outputType: .video,
        sortOrder: 1,
        isActive: true,
        metadata: nil,
        createdAt: Date(),
        updatedAt: Date(),
        modelCount: 15
    )

    static let mockImageGeneration = Category(
        id: UUID().uuidString,
        slug: "image-generation",
        name: "Image Generation",
        description: "Generate images from text prompts",
        iconEmoji: "🎨",
        creditCostDefault: 2,
        outputType: .image,
        sortOrder: 2,
        isActive: true,
        metadata: nil,
        createdAt: Date(),
        updatedAt: Date(),
        modelCount: 45
    )

    static let mockCategories = [mockVideoGeneration, mockImageGeneration]
}

// MARK: - AnyCodable Helper

/// Helper for decoding arbitrary JSON values
struct AnyCodable: Codable, Hashable {
    let value: Any

    init(_ value: Any) {
        self.value = value
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let intValue = try? container.decode(Int.self) {
            value = intValue
        } else if let doubleValue = try? container.decode(Double.self) {
            value = doubleValue
        } else if let stringValue = try? container.decode(String.self) {
            value = stringValue
        } else if let boolValue = try? container.decode(Bool.self) {
            value = boolValue
        } else if let arrayValue = try? container.decode([AnyCodable].self) {
            value = arrayValue.map { $0.value }
        } else if let dictionaryValue = try? container.decode([String: AnyCodable].self) {
            value = dictionaryValue.mapValues { $0.value }
        } else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Unsupported type"
            )
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch value {
        case let intValue as Int:
            try container.encode(intValue)
        case let doubleValue as Double:
            try container.encode(doubleValue)
        case let stringValue as String:
            try container.encode(stringValue)
        case let boolValue as Bool:
            try container.encode(boolValue)
        case let arrayValue as [Any]:
            try container.encode(arrayValue.map { AnyCodable($0) })
        case let dictionaryValue as [String: Any]:
            try container.encode(dictionaryValue.mapValues { AnyCodable($0) })
        default:
            throw EncodingError.invalidValue(
                value,
                EncodingError.Context(
                    codingPath: container.codingPath,
                    debugDescription: "Unsupported type"
                )
            )
        }
    }

    func hash(into hasher: inout Hasher) {
        // Basic hashing - may need refinement
        switch value {
        case let intValue as Int:
            hasher.combine(intValue)
        case let doubleValue as Double:
            hasher.combine(doubleValue)
        case let stringValue as String:
            hasher.combine(stringValue)
        case let boolValue as Bool:
            hasher.combine(boolValue)
        default:
            break
        }
    }

    static func == (lhs: AnyCodable, rhs: AnyCodable) -> Bool {
        // Basic equality - may need refinement
        switch (lhs.value, rhs.value) {
        case let (lInt as Int, rInt as Int):
            return lInt == rInt
        case let (lDouble as Double, rDouble as Double):
            return lDouble == rDouble
        case let (lString as String, rString as String):
            return lString == rString
        case let (lBool as Bool, rBool as Bool):
            return lBool == rBool
        default:
            return false
        }
    }
}
