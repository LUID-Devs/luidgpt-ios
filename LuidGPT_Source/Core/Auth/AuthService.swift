//
//  AuthService.swift
//  LuidGPT
//
//  Authentication service handling AWS Cognito integration and auth API calls
//  Updated to use APIClient and match backend response format
//

import Foundation

// MARK: - Request Models

struct LoginRequest: Codable {
    let email: String
    let password: String
}

struct RegisterRequest: Codable {
    let email: String
    let password: String
    let firstName: String
    let lastName: String
}

struct VerifyEmailRequest: Codable {
    let email: String
    let code: String
}

struct ResendCodeRequest: Codable {
    let email: String
}

struct ForgotPasswordRequest: Codable {
    let email: String
}

struct ResetPasswordRequest: Codable {
    let email: String
    let code: String
    let newPassword: String
}

// MARK: - Response Models

struct AuthTokensResponse: Codable {
    let success: Bool
    let tokens: AuthTokens
}

struct AuthTokens: Codable {
    let accessToken: String
    let idToken: String
    let refreshToken: String
    let expiresIn: Int
}

struct AuthMessageResponse: Codable {
    let success: Bool
    let message: String
}

struct RegisterResponse: Codable {
    let success: Bool
    let userSub: String
    let needsConfirmation: Bool
    let message: String
    let email: String
    let tokens: AuthTokens? // Optional tokens for auto-login
}

struct UserResponse: Codable {
    let success: Bool
    let user: User
}

// MARK: - Auth Errors

enum AuthError: LocalizedError {
    case notAuthenticated
    case tokenExpired
    case networkError
    case httpError(Int)
    case apiError(String)
    case invalidCredentials
    case emailNotVerified
    case weakPassword
    case emailAlreadyExists
    case invalidVerificationCode
    case unknown

    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "You are not authenticated. Please login."
        case .tokenExpired:
            return "Your session has expired. Please login again."
        case .networkError:
            return "Network connection failed. Please check your internet connection."
        case .httpError(let code):
            return "Server error (\(code)). Please try again later."
        case .apiError(let message):
            return message
        case .invalidCredentials:
            return "Invalid email or password."
        case .emailNotVerified:
            return "Please verify your email address."
        case .weakPassword:
            return "Password must be at least 8 characters with uppercase, lowercase, and numbers."
        case .emailAlreadyExists:
            return "An account with this email already exists."
        case .invalidVerificationCode:
            return "Invalid or expired verification code."
        case .unknown:
            return "An unknown error occurred. Please try again."
        }
    }
}

/// Authentication service for managing user authentication
class AuthService {
    static let shared = AuthService()

    private let client = APIClient.shared
    private let keychain = KeychainManager.shared

    private init() {}

    // MARK: - Authentication State

    /// Check if user is authenticated
    func isAuthenticated() -> Bool {
        return keychain.hasAccessToken()
    }

    /// Get current access token
    func getAccessToken() -> String? {
        return keychain.getAccessToken()
    }

    // MARK: - Login

    /// Login with email and password
    func login(email: String, password: String) async throws -> User {
        print("🟢 AuthService.login called with email: \(email)")
        let params: [String: Any] = [
            "email": email,
            "password": password
        ]

        print("🟢 Calling API client.post for /auth/login")
        do {
            let response: AuthTokensResponse = try await client.post(
                "/auth/login",
                parameters: params,
                requiresAuth: false
            )

            // Save tokens to Keychain
            _ = keychain.saveAccessToken(response.tokens.accessToken)
            _ = keychain.saveIdToken(response.tokens.idToken)
            _ = keychain.saveRefreshToken(response.tokens.refreshToken)

            // Fetch user profile
            let user = try await fetchUserProfile()
            _ = keychain.saveUserId(user.id)
            _ = keychain.saveUserEmail(user.email)

            return user

        } catch let error as APIError {
            throw mapAPIErrorToAuthError(error)
        }
    }

    // MARK: - Register

    /// Register new user with email and password
    func register(email: String, password: String, firstName: String, lastName: String) async throws -> RegisterResponse {
        let params: [String: Any] = [
            "email": email,
            "password": password,
            "firstName": firstName,
            "lastName": lastName
        ]

        do {
            let response: RegisterResponse = try await client.post(
                "/auth/register",
                parameters: params,
                requiresAuth: false
            )

            print("Registration successful: \(response.message)")
            return response

        } catch let error as APIError {
            throw mapAPIErrorToAuthError(error)
        }
    }

    // MARK: - Email Verification

    /// Verify email with code
    func verifyEmail(email: String, code: String) async throws -> User {
        let params: [String: Any] = [
            "email": email,
            "code": code
        ]

        do {
            let response: AuthTokensResponse = try await client.post(
                "/auth/verify-email",
                parameters: params,
                requiresAuth: false
            )

            // Save tokens to Keychain
            _ = keychain.saveAccessToken(response.tokens.accessToken)
            _ = keychain.saveIdToken(response.tokens.idToken)
            _ = keychain.saveRefreshToken(response.tokens.refreshToken)

            // Fetch user profile
            let user = try await fetchUserProfile()
            _ = keychain.saveUserId(user.id)
            _ = keychain.saveUserEmail(user.email)

            return user

        } catch let error as APIError {
            throw mapAPIErrorToAuthError(error)
        }
    }

    /// Resend verification code
    func resendVerificationCode(email: String) async throws {
        let params: [String: Any] = ["email": email]

        do {
            let _: AuthMessageResponse = try await client.post(
                "/auth/resend-code",
                parameters: params,
                requiresAuth: false
            )
        } catch let error as APIError {
            throw mapAPIErrorToAuthError(error)
        }
    }

    // MARK: - Password Reset

    /// Request password reset (sends code to email)
    func forgotPassword(email: String) async throws {
        let params: [String: Any] = ["email": email]

        do {
            let _: AuthMessageResponse = try await client.post(
                "/auth/forgot-password",
                parameters: params,
                requiresAuth: false
            )
        } catch let error as APIError {
            throw mapAPIErrorToAuthError(error)
        }
    }

    /// Reset password with code
    func resetPassword(email: String, code: String, newPassword: String) async throws {
        let params: [String: Any] = [
            "email": email,
            "code": code,
            "newPassword": newPassword
        ]

        do {
            let _: AuthMessageResponse = try await client.post(
                "/auth/reset-password",
                parameters: params,
                requiresAuth: false
            )
        } catch let error as APIError {
            throw mapAPIErrorToAuthError(error)
        }
    }

    // MARK: - Logout

    /// Logout user (clear local tokens)
    func logout() async throws {
        // Optionally call backend logout endpoint
        if keychain.hasAccessToken() {
            do {
                let _: AuthMessageResponse = try await client.post(
                    "/auth/logout",
                    requiresAuth: true
                )
            } catch {
                // Ignore logout errors, still clear local tokens
                print("Logout API call failed: \(error)")
            }
        }

        // Clear all stored credentials
        keychain.clearAll()
    }

    // MARK: - User Profile

    /// Fetch current user profile
    func fetchUserProfile() async throws -> User {
        do {
            let response: UserResponse = try await client.get(
                "/auth/me",
                requiresAuth: true
            )
            return response.user
        } catch let error as APIError {
            throw mapAPIErrorToAuthError(error)
        }
    }

    // MARK: - Error Mapping

    private func mapAPIErrorToAuthError(_ error: APIError) -> AuthError {
        switch error {
        case .unauthorized:
            return .tokenExpired
        case .serverError(let message):
            if message.contains("Invalid email or password") {
                return .invalidCredentials
            } else if message.contains("verify your email") || message.contains("USER_NOT_CONFIRMED") {
                return .emailNotVerified
            } else if message.contains("already exists") {
                return .emailAlreadyExists
            } else if message.contains("weak") || message.contains("Password must") {
                return .weakPassword
            } else if message.contains("Invalid") && message.contains("code") {
                return .invalidVerificationCode
            }
            return .apiError(message)
        case .networkError:
            return .networkError
        default:
            return .apiError(error.localizedDescription)
        }
    }
}
