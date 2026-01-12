//
//  CreditBalance.swift
//  LuidGPT
//
//  Credit balance and transaction models for Luidhub integration
//

import Foundation

/// Credit balance breakdown from Luidhub
struct CreditBalance: Codable {
    let totalCredits: Int
    let subscriptionCredits: Int
    let purchasedCredits: Int
    let promotionalCredits: Int
    let plan: String
    let periodStart: Date?
    let periodEnd: Date?
    let nextReset: Date?

    enum CodingKeys: String, CodingKey {
        case totalCredits = "total_credits"
        case subscriptionCredits = "subscription_credits"
        case purchasedCredits = "purchased_credits"
        case promotionalCredits = "promotional_credits"
        case plan
        case periodStart = "period_start"
        case periodEnd = "period_end"
        case nextReset = "next_reset"
    }
}

/// Credit balance API response wrapper
struct CreditBalanceResponse: Codable {
    let success: Bool
    let data: CreditBalance
}

/// Credit transaction record
struct CreditTransaction: Codable, Identifiable {
    let id: String
    let type: String // "deduct", "add", "purchase", "subscription"
    let amount: Int
    let balanceBefore: Int
    let balanceAfter: Int
    let description: String?
    let metadata: CreditTransactionMetadata?
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case type
        case amount
        case balanceBefore = "balance_before"
        case balanceAfter = "balance_after"
        case description
        case metadata
        case createdAt = "created_at"
    }
}

/// Transaction metadata (optional details)
struct CreditTransactionMetadata: Codable {
    let modelId: String?
    let modelName: String?
    let generationId: String?
    let requestId: String?

    enum CodingKeys: String, CodingKey {
        case modelId = "model_id"
        case modelName = "model_name"
        case generationId = "generation_id"
        case requestId = "request_id"
    }
}

/// Credit transactions API response wrapper
struct CreditTransactionsResponse: Codable {
    let success: Bool
    let data: [CreditTransaction]
    let pagination: PaginationInfo?
}

/// Pagination info for transaction list
struct PaginationInfo: Codable {
    let page: Int
    let limit: Int
    let total: Int
    let totalPages: Int
    let hasMore: Bool

    enum CodingKeys: String, CodingKey {
        case page
        case limit
        case total
        case totalPages = "total_pages"
        case hasMore = "has_more"
    }
}

/// Credit package for purchase
struct CreditPackage: Codable, Identifiable {
    let id: String
    let name: String
    let credits: Int
    let price: Double // in dollars
    let popular: Bool
    let savings: Int? // percentage saved compared to base rate

    var priceFormatted: String {
        return String(format: "$%.2f", price)
    }

    var creditsPerDollar: Double {
        return Double(credits) / price
    }
}

/// Credit packages API response wrapper
struct CreditPackagesResponse: Codable {
    let success: Bool
    let data: [CreditPackage]
}
