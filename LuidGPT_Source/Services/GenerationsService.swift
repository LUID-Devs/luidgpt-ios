//
//  GenerationsService.swift
//  LuidGPT
//
//  Service for managing user generations (history, details, updates)
//

import Foundation

/// Response models
struct GenerationsResponse: Codable {
    let success: Bool
    let generations: [Generation]
    let total: Int?
    let page: Int?
    let limit: Int?
}

struct GenerationResponse: Codable {
    let success: Bool
    let generation: Generation
}

/// Generations Service - Handles generation history and management
class GenerationsService {
    static let shared = GenerationsService()
    private let client = APIClient.shared

    private init() {}

    // MARK: - Get Generations

    /// Get user's generation history
    func getGenerations(
        status: Generation.Status? = nil,
        page: Int = 1,
        limit: Int = 20
    ) async throws -> [Generation] {
        var params: [String: Any] = [
            "page": page,
            "limit": limit,
            "sort": "createdAt:desc"
        ]

        if let status = status {
            params["status"] = status.rawValue
        }

        let response: GenerationsResponse = try await client.get(
            "/models/user/generations",
            parameters: params,
            requiresAuth: true
        )
        return response.generations
    }

    /// Get generation by ID
    func getGeneration(id: String) async throws -> Generation {
        let response: GenerationResponse = try await client.get(
            "/models/user/generations/\(id)",
            requiresAuth: true
        )
        return response.generation
    }

    // MARK: - Update Generation

    /// Update generation (e.g., add to favorites, rename)
    func updateGeneration(
        id: String,
        updates: [String: Any]
    ) async throws -> Generation {
        let response: GenerationResponse = try await client.patch(
            "/models/user/generations/\(id)",
            parameters: updates,
            requiresAuth: true
        )
        return response.generation
    }

    /// Toggle favorite status
    func toggleFavorite(id: String, isFavorite: Bool) async throws -> Generation {
        return try await updateGeneration(id: id, updates: ["isFavorite": isFavorite])
    }

    // MARK: - Delete Generation

    /// Delete generation
    func deleteGeneration(id: String) async throws {
        struct DeleteResponse: Codable {
            let success: Bool
            let message: String?
        }
        let _: DeleteResponse = try await client.delete(
            "/models/user/generations/\(id)",
            requiresAuth: true
        )
    }

    // MARK: - Cancel Generation

    /// Cancel a running generation
    func cancelGeneration(id: String) async throws -> Generation {
        let response: GenerationResponse = try await client.post(
            "/models/user/generations/\(id)/cancel",
            requiresAuth: true
        )
        return response.generation
    }

    // MARK: - Polling

    /// Poll generation status until complete or failed
    func pollGenerationStatus(
        id: String,
        interval: TimeInterval = 2.0,
        timeout: TimeInterval = 300.0
    ) async throws -> Generation {
        let startTime = Date()

        while Date().timeIntervalSince(startTime) < timeout {
            let generation = try await getGeneration(id: id)

            // Check if generation is in final state
            switch generation.status {
            case .completed, .failed, .cancelled:
                return generation
            case .pending, .processing:
                // Wait before next poll
                try await Task.sleep(nanoseconds: UInt64(interval * 1_000_000_000))
            }
        }

        throw APIError.serverError("Generation timed out")
    }
}
