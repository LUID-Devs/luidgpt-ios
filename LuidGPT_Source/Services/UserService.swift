//
//  UserService.swift
//  LuidGPT
//
//  Service for user profile and account management
//

import Foundation

/// Response models
struct UserProfileResponse: Codable {
    let success: Bool
    let user: User
}

/// User Service - Handles user profile and account operations
class UserService {
    static let shared = UserService()
    private let client = APIClient.shared

    private init() {}

    // MARK: - Profile

    /// Get current user profile
    func getProfile() async throws -> User {
        let response: UserProfileResponse = try await client.get(
            "/auth/profile",
            requiresAuth: true
        )
        return response.user
    }

    /// Update user profile
    func updateProfile(updates: [String: Any]) async throws -> User {
        let response: UserProfileResponse = try await client.put(
            "/users/profile",
            parameters: updates,
            requiresAuth: true
        )
        return response.user
    }

    // MARK: - Credits
    // Note: Credit operations have been moved to CreditService for Luidhub integration
}
