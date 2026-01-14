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
    let credits: Int
    let createdById: String
    let memberCount: Int?
    let createdAt: Date
    let updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id, name, description, credits, createdById, memberCount
        case createdAt, updatedAt
    }

    /// Credit balance display
    var creditsDisplay: String {
        if credits >= 1000 {
            return String(format: "%.1fk", Double(credits) / 1000.0)
        }
        return "\(credits)"
    }
}

// MARK: - Organization Member

/// Organization member with role
struct OrganizationMember: Identifiable, Codable, Hashable {
    let id: String
    let organizationId: String
    let userId: String
    let role: Role
    let joinedAt: Date

    // Relationships
    var user: User?

    enum Role: String, Codable {
        case owner
        case admin
        case member
        case viewer

        var displayName: String {
            rawValue.capitalized
        }

        var canManageMembers: Bool {
            self == .owner || self == .admin
        }

        var canManageCredits: Bool {
            self == .owner || self == .admin
        }

        var canGenerate: Bool {
            true // All members can generate
        }
    }

    enum CodingKeys: String, CodingKey {
        case id, organizationId, userId, role, joinedAt, user
    }
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
        credits: 500,
        createdById: UUID().uuidString,
        memberCount: 5,
        createdAt: Date().addingTimeInterval(-86400 * 90),
        updatedAt: Date()
    )
}
