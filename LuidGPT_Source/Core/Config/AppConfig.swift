//
//  AppConfig.swift
//  LuidGPT
//
//  Application configuration and environment variables
//

import Foundation

enum AppConfig {
    // MARK: - API Configuration

    /// Base API URL (luidgpt-backend)
    static let apiBaseURL = "http://localhost:3001/api"

    /// Luidhub API URL (credit system)
    static let luidhubBaseURL = "http://localhost:4000"

    /// API timeout in seconds
    static let apiTimeout: TimeInterval = 30

    // MARK: - AWS Cognito Configuration

    /// Cognito User Pool ID
    static let cognitoPoolId = "us-east-1_SpqXBs7w9"

    /// Cognito App Client ID
    static let cognitoClientId = "7kjhjlipd9140o02vi9ndifb51"

    /// Cognito Region
    static let cognitoRegion = "us-east-1"

    // MARK: - Google OAuth Configuration

    /// Google OAuth Client ID (iOS)
    static let googleClientId = "YOUR_GOOGLE_CLIENT_ID.apps.googleusercontent.com"

    // MARK: - Stripe Configuration

    /// Stripe Publishable Key
    static let stripePublishableKey = "pk_test_..."

    // MARK: - App Configuration

    /// App version
    static let appVersion = "1.0.0"

    /// Build number
    static let buildNumber = "1"

    /// Minimum credits warning threshold
    static let lowCreditsThreshold = 10

    /// Default page size for pagination
    static let defaultPageSize = 20

    // MARK: - Feature Flags

    /// Enable Google OAuth login
    static let enableGoogleOAuth = true

    /// Enable Apple Sign In
    static let enableAppleSignIn = false

    /// Enable biometric authentication
    static let enableBiometrics = true

    // MARK: - Helper Methods

    /// Check if running in development mode
    static var isDevelopment: Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }

    /// Get full API URL for endpoint
    static func apiURL(for endpoint: String) -> String {
        let cleanEndpoint = endpoint.hasPrefix("/") ? endpoint : "/\(endpoint)"
        return "\(apiBaseURL)\(cleanEndpoint)"
    }
}

// MARK: - API Endpoints

enum APIEndpoint {
    // MARK: - Authentication
    static let login = "/auth/login"
    static let register = "/auth/register"
    static let verifyEmail = "/auth/verify-email"
    static let resendCode = "/auth/resend-code"
    static let forgotPassword = "/auth/forgot-password"
    static let resetPassword = "/auth/reset-password"
    static let googleAuth = "/auth/google"
    static let refreshToken = "/auth/refresh"
    static let logout = "/auth/logout"

    // MARK: - User
    static let profile = "/user/profile"
    static let updateProfile = "/user/profile"
    static let credits = "/user/credits"

    // MARK: - Categories
    static let categories = "/categories"
    static func category(_ slug: String) -> String {
        "/categories/\(slug)"
    }

    // MARK: - Models
    static let models = "/models"
    static func modelsByCategory(_ categorySlug: String) -> String {
        "/models?category=\(categorySlug)"
    }
    static func model(_ id: String) -> String {
        "/models/\(id)"
    }
    static let featuredModels = "/models/featured"

    // MARK: - Generations
    static let generations = "/generations"
    static let createGeneration = "/generations"
    static func generation(_ id: String) -> String {
        "/generations/\(id)"
    }
    static func updateGeneration(_ id: String) -> String {
        "/generations/\(id)"
    }
    static func deleteGeneration(_ id: String) -> String {
        "/generations/\(id)"
    }

    // MARK: - Organizations
    static let organizations = "/organizations"
    static func organization(_ id: String) -> String {
        "/organizations/\(id)"
    }
    static func organizationMembers(_ id: String) -> String {
        "/organizations/\(id)/members"
    }

    // MARK: - Billing
    static let createCheckoutSession = "/billing/create-checkout-session"
    static let billingPortal = "/billing/portal"
}
