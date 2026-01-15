//
//  WorkspacesAPIService.swift
//  LuidGPT
//
//  API service for workspace/organization operations
//  Backend uses "organizations" but UI refers to them as "workspaces"
//

import Foundation

/// Service for workspace/organization-related API operations
class WorkspacesAPIService {
    static let shared = WorkspacesAPIService()

    private let apiClient = APIClient.shared

    private init() {}

    // MARK: - Organization CRUD

    /// Create a new organization/workspace
    /// POST /api/organizations
    func createWorkspace(
        name: String,
        description: String? = nil,
        logo: String? = nil
    ) async throws -> Organization {
        let endpoint = "/organizations"

        var params: [String: Any] = ["name": name]
        if let description = description {
            params["description"] = description
        }
        if let logo = logo {
            params["logo"] = logo
        }

        let response: OrganizationResponse = try await apiClient.post(
            endpoint,
            parameters: params,
            requiresAuth: true
        )

        if !response.success {
            throw APIError.serverError("Failed to create workspace")
        }

        return response.data
    }

    /// Get list of user's organizations/workspaces
    /// GET /api/organizations
    func fetchWorkspaces() async throws -> [Organization] {
        let endpoint = "/organizations"

        let response: OrganizationsResponse = try await apiClient.get(
            endpoint,
            requiresAuth: true
        )

        if !response.success {
            throw APIError.serverError("Failed to fetch workspaces")
        }

        return response.data
    }

    /// Get organization/workspace details by ID
    /// GET /api/organizations/:id
    func fetchWorkspace(id: String) async throws -> Organization {
        let endpoint = "/organizations/\(id)"

        let response: OrganizationResponse = try await apiClient.get(
            endpoint,
            requiresAuth: true
        )

        if !response.success {
            throw APIError.serverError("Failed to fetch workspace details")
        }

        return response.data
    }

    /// Update organization/workspace
    /// PUT /api/organizations/:id
    func updateWorkspace(
        id: String,
        name: String? = nil,
        description: String? = nil,
        logo: String? = nil
    ) async throws -> Organization {
        let endpoint = "/organizations/\(id)"

        let params: [String: Any] = [
            "name": name as Any,
            "description": description as Any,
            "logo": logo as Any
        ]

        let response: OrganizationResponse = try await apiClient.put(
            endpoint,
            parameters: params,
            requiresAuth: true
        )

        if !response.success {
            throw APIError.serverError("Failed to update workspace")
        }

        return response.data
    }

    /// Delete organization/workspace
    /// DELETE /api/organizations/:id
    func deleteWorkspace(id: String) async throws {
        let endpoint = "/organizations/\(id)"

        let response: MessageResponse = try await apiClient.delete(
            endpoint,
            requiresAuth: true
        )

        if !response.success {
            throw APIError.serverError(response.message)
        }
    }

    // MARK: - Members Management

    /// Get organization members
    /// GET /api/organizations/:id/members
    func fetchMembers(workspaceId: String) async throws -> [OrganizationMember] {
        let endpoint = "/organizations/\(workspaceId)/members"

        let response: OrganizationMembersResponse = try await apiClient.get(
            endpoint,
            requiresAuth: true
        )

        if !response.success {
            throw APIError.serverError("Failed to fetch members")
        }

        return response.data
    }

    /// Update member role
    /// PUT /api/organizations/:id/members/:userId
    func updateMemberRole(
        workspaceId: String,
        userId: String,
        role: String
    ) async throws -> OrganizationMember {
        let endpoint = "/organizations/\(workspaceId)/members/\(userId)"

        let params: [String: Any] = ["role": role]

        struct Response: Codable {
            let success: Bool
            let data: OrganizationMember
        }

        let response: Response = try await apiClient.put(
            endpoint,
            parameters: params,
            requiresAuth: true
        )

        if !response.success {
            throw APIError.serverError("Failed to update member role")
        }

        return response.data
    }

    /// Remove member from organization
    /// DELETE /api/organizations/:id/members/:userId
    func removeMember(workspaceId: String, userId: String) async throws {
        let endpoint = "/organizations/\(workspaceId)/members/\(userId)"

        let response: MessageResponse = try await apiClient.delete(
            endpoint,
            requiresAuth: true
        )

        if !response.success {
            throw APIError.serverError(response.message)
        }
    }

    /// Leave organization
    /// POST /api/organizations/:id/leave
    func leaveWorkspace(id: String) async throws {
        let endpoint = "/organizations/\(id)/leave"

        let response: MessageResponse = try await apiClient.post(
            endpoint,
            requiresAuth: true
        )

        if !response.success {
            throw APIError.serverError(response.message)
        }
    }

    // MARK: - Invitations

    /// Create invitation to join organization
    /// POST /api/organizations/:id/invitations
    func createInvitation(
        workspaceId: String,
        email: String,
        role: String
    ) async throws -> OrganizationInvitation {
        let endpoint = "/organizations/\(workspaceId)/invitations"

        let params: [String: Any] = [
            "email": email,
            "role": role
        ]

        let response: OrganizationInvitationResponse = try await apiClient.post(
            endpoint,
            parameters: params,
            requiresAuth: true
        )

        if !response.success {
            throw APIError.serverError("Failed to create invitation")
        }

        return response.data
    }

    /// Get organization invitations
    /// GET /api/organizations/:id/invitations
    func fetchInvitations(workspaceId: String) async throws -> [OrganizationInvitation] {
        let endpoint = "/organizations/\(workspaceId)/invitations"

        let response: OrganizationInvitationsResponse = try await apiClient.get(
            endpoint,
            requiresAuth: true
        )

        if !response.success {
            throw APIError.serverError("Failed to fetch invitations")
        }

        return response.data
    }

    /// Revoke/cancel an invitation
    /// DELETE /api/organizations/:id/invitations/:inviteId
    func revokeInvitation(workspaceId: String, inviteId: String) async throws {
        let endpoint = "/organizations/\(workspaceId)/invitations/\(inviteId)"

        let response: MessageResponse = try await apiClient.delete(
            endpoint,
            requiresAuth: true
        )

        if !response.success {
            throw APIError.serverError(response.message)
        }
    }

    /// Resend invitation email
    /// POST /api/organizations/:id/invitations/:inviteId/resend
    func resendInvitation(workspaceId: String, inviteId: String) async throws {
        let endpoint = "/organizations/\(workspaceId)/invitations/\(inviteId)/resend"

        let response: MessageResponse = try await apiClient.post(
            endpoint,
            requiresAuth: true
        )

        if !response.success {
            throw APIError.serverError(response.message)
        }
    }

    // MARK: - Invitation Actions (for invitee)

    /// Get invitation details by token
    /// GET /api/invitations/:token
    func fetchInvitationByToken(token: String) async throws -> OrganizationInvitation {
        let endpoint = "/invitations/\(token)"

        let response: OrganizationInvitationResponse = try await apiClient.get(
            endpoint,
            requiresAuth: true
        )

        if !response.success {
            throw APIError.serverError("Failed to fetch invitation")
        }

        return response.data
    }

    /// Accept invitation by token
    /// POST /api/invitations/:token/accept
    func acceptInvitation(token: String) async throws -> Organization {
        let endpoint = "/invitations/\(token)/accept"

        let response: OrganizationResponse = try await apiClient.post(
            endpoint,
            requiresAuth: true
        )

        if !response.success {
            throw APIError.serverError("Failed to accept invitation")
        }

        return response.data
    }

    /// Get user's pending invitations
    /// GET /api/invitations
    func fetchPendingInvitations() async throws -> [OrganizationInvitation] {
        let endpoint = "/invitations"

        let response: OrganizationInvitationsResponse = try await apiClient.get(
            endpoint,
            requiresAuth: true
        )

        if !response.success {
            throw APIError.serverError("Failed to fetch pending invitations")
        }

        return response.data
    }

    // MARK: - Credits

    /// Get workspace credit balance
    /// GET /api/organizations/:id/credits
    func fetchWorkspaceCredits(workspaceId: String) async throws -> CreditBalance {
        let endpoint = "/organizations/\(workspaceId)/credits"

        struct Response: Codable {
            let success: Bool
            let data: CreditBalance
        }

        let response: Response = try await apiClient.get(
            endpoint,
            requiresAuth: true
        )

        if !response.success {
            throw APIError.serverError("Failed to fetch workspace credits")
        }

        return response.data
    }

    /// Get workspace credit transactions
    /// GET /api/organizations/:id/credits/transactions
    func fetchWorkspaceCreditTransactions(
        workspaceId: String,
        limit: Int? = nil,
        offset: Int? = nil,
        type: String? = nil
    ) async throws -> [CreditTransaction] {
        var queryItems: [URLQueryItem] = []

        if let limit = limit {
            queryItems.append(URLQueryItem(name: "limit", value: String(limit)))
        }

        if let offset = offset {
            queryItems.append(URLQueryItem(name: "offset", value: String(offset)))
        }

        if let type = type {
            queryItems.append(URLQueryItem(name: "type", value: type))
        }

        var components = URLComponents(string: "/organizations/\(workspaceId)/credits/transactions")!
        if !queryItems.isEmpty {
            components.queryItems = queryItems
        }

        let endpoint = components.url!.path + (components.query.map { "?\($0)" } ?? "")

        struct Response: Codable {
            let success: Bool
            let data: [CreditTransaction]
        }

        let response: Response = try await apiClient.get(
            endpoint,
            requiresAuth: true
        )

        if !response.success {
            throw APIError.serverError("Failed to fetch transactions")
        }

        return response.data
    }

    // MARK: - Generations

    /// Get workspace AI generations
    /// GET /api/organizations/:id/generations
    func fetchWorkspaceGenerations(
        workspaceId: String,
        limit: Int? = nil,
        offset: Int? = nil,
        type: String? = nil
    ) async throws -> [ModelGeneration] {
        var queryItems: [URLQueryItem] = []

        if let limit = limit {
            queryItems.append(URLQueryItem(name: "limit", value: String(limit)))
        }

        if let offset = offset {
            queryItems.append(URLQueryItem(name: "offset", value: String(offset)))
        }

        if let type = type {
            queryItems.append(URLQueryItem(name: "type", value: type))
        }

        var components = URLComponents(string: "/organizations/\(workspaceId)/generations")!
        if !queryItems.isEmpty {
            components.queryItems = queryItems
        }

        let endpoint = components.url!.path + (components.query.map { "?\($0)" } ?? "")

        struct Response: Codable {
            let success: Bool
            let data: [ModelGeneration]
        }

        let response: Response = try await apiClient.get(
            endpoint,
            requiresAuth: true
        )

        if !response.success {
            throw APIError.serverError("Failed to fetch generations")
        }

        return response.data
    }

    /// Get workspace generation stats
    /// GET /api/organizations/:id/generations/stats
    func fetchWorkspaceGenerationStats(workspaceId: String) async throws -> GenerationStats {
        let endpoint = "/organizations/\(workspaceId)/generations/stats"

        struct Response: Codable {
            let success: Bool
            let data: GenerationStats
        }

        let response: Response = try await apiClient.get(
            endpoint,
            requiresAuth: true
        )

        if !response.success {
            throw APIError.serverError("Failed to fetch generation stats")
        }

        return response.data
    }
}

// MARK: - Stats Models

struct GenerationStats: Codable {
    let total: Int
    let completed: Int
    let failed: Int
    let processing: Int
    let totalCreditsUsed: Int
}
