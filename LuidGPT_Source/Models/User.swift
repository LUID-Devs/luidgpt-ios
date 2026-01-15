//
//  User.swift
//  LuidGPT
//
//  User model with authentication and credit information
//

import Foundation

/// Application User
struct User: Identifiable, Codable, Hashable {
    let id: String
    let email: String
    let firstName: String?
    let lastName: String?
    let name: String?
    let avatar: String?
    let credits: Int
    let organizationId: String?
    let cognitoId: String?
    let emailVerified: Bool
    let createdAt: Date
    let updatedAt: Date

    // Relationships
    var organization: Organization?

    enum CodingKeys: String, CodingKey {
        case id, email, firstName, lastName, name, avatar
        case credits, organizationId, cognitoId, emailVerified
        case createdAt, updatedAt, organization
    }

    /// Full name computed property
    var fullName: String {
        if let name = name, !name.isEmpty {
            return name
        }
        let first = firstName ?? ""
        let last = lastName ?? ""
        let combined = "\(first) \(last)".trimmingCharacters(in: .whitespaces)
        return combined.isEmpty ? (email.components(separatedBy: "@").first ?? "User") : combined
    }

    /// Initials for avatar
    var initials: String {
        let components = fullName.components(separatedBy: " ")
        if components.count >= 2 {
            let first = components[0].prefix(1)
            let last = components[1].prefix(1)
            return "\(first)\(last)".uppercased()
        }
        return String(fullName.prefix(2)).uppercased()
    }

    /// Has low credits (warning threshold)
    var hasLowCredits: Bool {
        credits < 10
    }

    /// Credit balance display
    var creditsDisplay: String {
        if credits >= 1000 {
            return String(format: "%.1fk", Double(credits) / 1000.0)
        }
        return "\(credits)"
    }
}

// MARK: - Organization

/// User organization/workspace
struct Organization: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let description: String?
    let logo: String?
    let credits: Int?
    let ownerId: String
    let memberCount: Int?
    let creditsUsed: Int?
    let generationsCount: Int?
    let role: String?
    let createdAt: Date
    let updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id, name, description, logo, credits
        case ownerId, memberCount, creditsUsed, generationsCount, role
        case createdAt, updatedAt
    }

    /// Workspace initials for avatar
    var initials: String {
        let words = name.split(separator: " ")
        if words.count >= 2 {
            return String(words[0].prefix(1) + words[1].prefix(1)).uppercased()
        }
        return String(name.prefix(2)).uppercased()
    }

    /// Credit balance display
    var creditsDisplay: String {
        let creditValue = credits ?? 0
        if creditValue >= 1000 {
            return String(format: "%.1fk", Double(creditValue) / 1000.0)
        }
        return "\(creditValue)"
    }
}

// MARK: - Organization Member

/// Organization member with role
struct OrganizationMember: Identifiable, Codable, Hashable {
    let id: String
    let organizationId: String
    let userId: String
    let role: String
    let joinedAt: Date

    // Relationships
    var user: UserInfo?

    enum CodingKeys: String, CodingKey {
        case id, organizationId, userId, role, joinedAt, user
    }

    /// User info (from join)
    struct UserInfo: Codable, Hashable {
        let id: String
        let email: String
        let firstName: String?
        let lastName: String?

        var fullName: String {
            if let first = firstName, let last = lastName {
                return "\(first) \(last)"
            }
            return firstName ?? lastName ?? email
        }

        var initials: String {
            if let first = firstName?.prefix(1), let last = lastName?.prefix(1) {
                return "\(first)\(last)".uppercased()
            }
            return String(email.prefix(2)).uppercased()
        }
    }

    /// Role display name
    var roleDisplayName: String {
        role.capitalized
    }

    /// Check if can manage members
    var canManageMembers: Bool {
        role == "owner" || role == "admin"
    }

    /// Check if can manage credits
    var canManageCredits: Bool {
        role == "owner" || role == "admin"
    }
}

// MARK: - Organization Invitation

/// Organization invitation
struct OrganizationInvitation: Identifiable, Codable, Hashable {
    let id: String
    let organizationId: String
    let email: String
    let role: String
    let token: String
    let status: String
    let expiresAt: Date
    let invitedBy: String
    let createdAt: Date

    // Organization details (from join)
    let organization: Organization?

    enum CodingKeys: String, CodingKey {
        case id, organizationId, email, role, token, status
        case expiresAt, invitedBy, createdAt, organization
    }

    /// Check if expired
    var isExpired: Bool {
        Date() > expiresAt
    }

    /// Check if pending
    var isPending: Bool {
        status == "pending" && !isExpired
    }
}

// MARK: - API Response Types

struct OrganizationsResponse: Codable {
    let success: Bool
    let data: [Organization]
}

struct OrganizationResponse: Codable {
    let success: Bool
    let data: Organization
}

struct OrganizationMembersResponse: Codable {
    let success: Bool
    let data: [OrganizationMember]
}

struct OrganizationInvitationsResponse: Codable {
    let success: Bool
    let data: [OrganizationInvitation]
}

struct OrganizationInvitationResponse: Codable {
    let success: Bool
    let data: OrganizationInvitation
}

struct MessageResponse: Codable {
    let success: Bool
    let message: String
}

// MARK: - Mock Data

extension User {
    static let mock = User(
        id: UUID().uuidString,
        email: "user@example.com",
        firstName: "John",
        lastName: "Doe",
        name: nil,
        avatar: nil,
        credits: 150,
        organizationId: nil,
        cognitoId: "cognito-123",
        emailVerified: true,
        createdAt: Date().addingTimeInterval(-86400 * 30),
        updatedAt: Date(),
        organization: nil
    )

    static let mockLowCredits = User(
        id: UUID().uuidString,
        email: "lowcredits@example.com",
        firstName: "Jane",
        lastName: "Smith",
        name: nil,
        avatar: nil,
        credits: 5,
        organizationId: nil,
        cognitoId: "cognito-456",
        emailVerified: true,
        createdAt: Date().addingTimeInterval(-86400 * 7),
        updatedAt: Date(),
        organization: nil
    )
}

extension Organization {
    static let mock = Organization(
        id: UUID().uuidString,
        name: "LUID Team",
        description: "Our workspace for AI creations",
        logo: nil,
        credits: 500,
        ownerId: UUID().uuidString,
        memberCount: 5,
        creditsUsed: 250,
        generationsCount: 42,
        role: "owner",
        createdAt: Date().addingTimeInterval(-86400 * 90),
        updatedAt: Date()
    )
}
