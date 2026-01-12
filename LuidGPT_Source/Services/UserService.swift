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

struct CreditBalanceResponse: Codable {
    let success: Bool
    let balance: Int
    let tier: String?
}

struct CreditHistoryResponse: Codable {
    let success: Bool
    let transactions: [CreditTransaction]
    let total: Int?
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

    /// Get credit balance
    func getCreditBalance() async throws -> Int {
        let response: CreditBalanceResponse = try await client.get(
            "/credits/balance",
            requiresAuth: true
        )
        return response.balance
    }

    /// Get credit history
    func getCreditHistory(page: Int = 1, limit: Int = 50) async throws -> [CreditTransaction] {
        let params: [String: Any] = [
            "page": page,
            "limit": limit
        ]
        let response: CreditHistoryResponse = try await client.get(
            "/credits/history",
            parameters: params,
            requiresAuth: true
        )
        return response.transactions
    }

    /// Purchase credits
    func purchaseCredits(amount: Int, paymentMethodId: String) async throws {
        struct PurchaseResponse: Codable {
            let success: Bool
            let message: String?
        }
        let params: [String: Any] = [
            "amount": amount,
            "paymentMethodId": paymentMethodId
        ]
        let _: PurchaseResponse = try await client.post(
            "/credits/purchase",
            parameters: params,
            requiresAuth: true
        )
    }
}
