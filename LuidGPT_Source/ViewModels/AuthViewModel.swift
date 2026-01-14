//
//  AuthViewModel.swift
//  LuidGPT
//
//  ViewModel managing authentication state with Combine
//

import Foundation
import Combine
import os.log

/// Authentication state manager using MVVM + Combine
@MainActor
class AuthViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var currentUser: User?
    @Published var errorMessage: String?

    // For registration flow
    @Published var pendingVerificationEmail: String?

    // MARK: - Services

    private let authService = AuthService.shared
    private var cancellables = Set<AnyCancellable>()
    private let logger = OSLog(subsystem: "com.luidgpt.LuidGPT", category: "AuthViewModel")

    // MARK: - Initialization

    init() {
        checkAuthenticationStatus()
    }

    // MARK: - Authentication Status

    /// Check if user has valid token and load profile
    func checkAuthenticationStatus() {
        isLoading = true

        Task {
            do {
                if authService.isAuthenticated() {
                    // Fetch user profile to validate token
                    let user = try await authService.fetchUserProfile()
                    self.currentUser = user
                    self.isAuthenticated = true
                } else {
                    self.isAuthenticated = false
                    self.currentUser = nil
                }
            } catch {
                // Token invalid or expired - silently fail without showing error
                // User will see login screen instead
                self.isAuthenticated = false
                self.currentUser = nil
                self.errorMessage = nil // Clear any error message
            }

            self.isLoading = false
        }
    }

    // MARK: - Login

    /// Login with email and password
    func login(email: String, password: String) async {
        isLoading = true
        errorMessage = nil

        do {
            let user = try await authService.login(email: email, password: password)
            self.currentUser = user
            self.isAuthenticated = true
        } catch let error as AuthError {
            self.errorMessage = error.errorDescription
        } catch {
            self.errorMessage = "Login failed. Please try again."
        }

        isLoading = false
    }

    // MARK: - Register

    /// Register new user
    func register(email: String, password: String, firstName: String, lastName: String) async {
        os_log("🔵 Starting registration for: %{public}@", log: logger, type: .info, email)
        isLoading = true
        errorMessage = nil

        do {
            os_log("🔵 Calling authService.register...", log: logger, type: .info)
            let response = try await authService.register(
                email: email,
                password: password,
                firstName: firstName,
                lastName: lastName
            )

            os_log("🟢 Registration successful! needsConfirmation: %{public}@, has tokens: %{public}@",
                   log: logger, type: .info,
                   String(response.needsConfirmation),
                   String(response.tokens != nil))

            // Check if email verification is needed
            if response.needsConfirmation {
                os_log("🟡 Email verification needed", log: logger, type: .info)
                // Save email for verification screen
                self.pendingVerificationEmail = email
            } else if let tokens = response.tokens {
                os_log("🟢 Tokens received, saving to keychain...", log: logger, type: .info)
                // Auto-verified with tokens - save them
                let keychain = KeychainManager.shared
                _ = keychain.saveAccessToken(tokens.accessToken)
                _ = keychain.saveIdToken(tokens.idToken)
                _ = keychain.saveRefreshToken(tokens.refreshToken)

                // Fetch user profile
                os_log("🟢 Fetching user profile...", log: logger, type: .info)
                let user = try await authService.fetchUserProfile()
                _ = keychain.saveUserId(user.id)
                _ = keychain.saveUserEmail(user.email)

                os_log("🟢 Registration complete! User: %{public}@", log: logger, type: .info, user.email)
                self.currentUser = user
                self.isAuthenticated = true
            } else {
                os_log("🟡 No tokens, falling back to login", log: logger, type: .info)
                // Fallback: log the user in manually
                await login(email: email, password: password)
            }
        } catch let error as AuthError {
            os_log("🔴 AuthError during registration: %{public}@", log: logger, type: .error, error.errorDescription ?? "Unknown")
            self.errorMessage = error.errorDescription
        } catch {
            os_log("🔴 Unknown error during registration: %{public}@", log: logger, type: .error, error.localizedDescription)
            self.errorMessage = "Registration failed. Please try again."
        }

        isLoading = false
        os_log("🔵 Registration flow complete", log: logger, type: .info)
    }

    // MARK: - Email Verification

    /// Verify email with code
    func verifyEmail(email: String, code: String) async {
        isLoading = true
        errorMessage = nil

        do {
            let user = try await authService.verifyEmail(email: email, code: code)
            self.currentUser = user
            self.isAuthenticated = true
            self.pendingVerificationEmail = nil
        } catch let error as AuthError {
            self.errorMessage = error.errorDescription
        } catch {
            self.errorMessage = "Verification failed. Please try again."
        }

        isLoading = false
    }

    /// Resend verification code
    func resendVerificationCode(email: String) async {
        isLoading = true
        errorMessage = nil

        do {
            try await authService.resendVerificationCode(email: email)
            // Show success message (could use a success state)
        } catch let error as AuthError {
            self.errorMessage = error.errorDescription
        } catch {
            self.errorMessage = "Failed to resend code. Please try again."
        }

        isLoading = false
    }

    // MARK: - Password Reset

    /// Request password reset
    func forgotPassword(email: String) async {
        isLoading = true
        errorMessage = nil

        do {
            try await authService.forgotPassword(email: email)
            // Show success message
        } catch let error as AuthError {
            self.errorMessage = error.errorDescription
        } catch {
            self.errorMessage = "Failed to send reset code. Please try again."
        }

        isLoading = false
    }

    /// Reset password with code
    func resetPassword(email: String, code: String, newPassword: String) async {
        isLoading = true
        errorMessage = nil

        do {
            try await authService.resetPassword(email: email, code: code, newPassword: newPassword)
            // Show success and navigate to login
        } catch let error as AuthError {
            self.errorMessage = error.errorDescription
        } catch {
            self.errorMessage = "Password reset failed. Please try again."
        }

        isLoading = false
    }

    // MARK: - Logout

    /// Logout user
    func logout() async {
        isLoading = true

        do {
            try await authService.logout()
            self.isAuthenticated = false
            self.currentUser = nil
        } catch {
            // Even if API call fails, clear local state
            self.isAuthenticated = false
            self.currentUser = nil
        }

        isLoading = false
    }

    // MARK: - Refresh User

    /// Refresh current user profile
    func refreshUser() async {
        do {
            let user = try await authService.fetchUserProfile()
            self.currentUser = user
        } catch {
            print("Failed to refresh user: \(error)")
        }
    }

    // MARK: - Validation Helpers

    /// Validate email format
    func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }

    /// Validate password strength
    func isValidPassword(_ password: String) -> Bool {
        // AWS Cognito default: min 8 chars, uppercase, lowercase, number
        let passwordRegex = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d).{8,}$"
        let passwordPredicate = NSPredicate(format: "SELF MATCHES %@", passwordRegex)
        return passwordPredicate.evaluate(with: password)
    }

    /// Get password strength description
    func passwordStrengthDescription(_ password: String) -> String {
        if password.isEmpty {
            return ""
        }

        var strength = 0
        if password.count >= 8 { strength += 1 }
        if password.range(of: "[A-Z]", options: .regularExpression) != nil { strength += 1 }
        if password.range(of: "[a-z]", options: .regularExpression) != nil { strength += 1 }
        if password.range(of: "[0-9]", options: .regularExpression) != nil { strength += 1 }
        if password.range(of: "[^A-Za-z0-9]", options: .regularExpression) != nil { strength += 1 }

        switch strength {
        case 0...1: return "Weak"
        case 2...3: return "Fair"
        case 4: return "Good"
        case 5: return "Strong"
        default: return ""
        }
    }

    /// Clear error message
    func clearError() {
        errorMessage = nil
    }
}
