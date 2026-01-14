//
//  KeychainManager.swift
//  LuidGPT
//
//  Secure storage for authentication tokens and sensitive data
//

import Foundation
import Security

/// Manages secure storage of sensitive data in iOS Keychain
class KeychainManager {
    static let shared = KeychainManager()

    private init() {}

    // MARK: - Keychain Keys

    private enum Keys {
        static let accessToken = "com.luidgpt.accessToken"
        static let idToken = "com.luidgpt.idToken"
        static let refreshToken = "com.luidgpt.refreshToken"
        static let userId = "com.luidgpt.userId"
        static let userEmail = "com.luidgpt.userEmail"
    }

    // MARK: - Access Token

    /// Save access token to Keychain
    func saveAccessToken(_ token: String) -> Bool {
        return save(token, forKey: Keys.accessToken)
    }

    /// Get access token from Keychain
    func getAccessToken() -> String? {
        return get(forKey: Keys.accessToken)
    }

    /// Delete access token from Keychain
    func deleteAccessToken() -> Bool {
        return delete(forKey: Keys.accessToken)
    }

    // MARK: - ID Token

    /// Save ID token to Keychain
    func saveIdToken(_ token: String) -> Bool {
        return save(token, forKey: Keys.idToken)
    }

    /// Get ID token from Keychain
    func getIdToken() -> String? {
        return get(forKey: Keys.idToken)
    }

    /// Delete ID token from Keychain
    func deleteIdToken() -> Bool {
        return delete(forKey: Keys.idToken)
    }

    // MARK: - Refresh Token

    /// Save refresh token to Keychain
    func saveRefreshToken(_ token: String) -> Bool {
        return save(token, forKey: Keys.refreshToken)
    }

    /// Get refresh token from Keychain
    func getRefreshToken() -> String? {
        return get(forKey: Keys.refreshToken)
    }

    /// Delete refresh token from Keychain
    func deleteRefreshToken() -> Bool {
        return delete(forKey: Keys.refreshToken)
    }

    // MARK: - User ID

    /// Save user ID to Keychain
    func saveUserId(_ userId: String) -> Bool {
        return save(userId, forKey: Keys.userId)
    }

    /// Get user ID from Keychain
    func getUserId() -> String? {
        return get(forKey: Keys.userId)
    }

    /// Delete user ID from Keychain
    func deleteUserId() -> Bool {
        return delete(forKey: Keys.userId)
    }

    // MARK: - User Email

    /// Save user email to Keychain
    func saveUserEmail(_ email: String) -> Bool {
        return save(email, forKey: Keys.userEmail)
    }

    /// Get user email from Keychain
    func getUserEmail() -> String? {
        return get(forKey: Keys.userEmail)
    }

    /// Delete user email from Keychain
    func deleteUserEmail() -> Bool {
        return delete(forKey: Keys.userEmail)
    }

    // MARK: - Clear All

    /// Clear all stored credentials
    func clearAll() {
        _ = deleteAccessToken()
        _ = deleteIdToken()
        _ = deleteRefreshToken()
        _ = deleteUserId()
        _ = deleteUserEmail()
    }

    // MARK: - Generic Keychain Operations

    /// Save string value to Keychain (with UserDefaults fallback for simulator)
    private func save(_ value: String, forKey key: String) -> Bool {
        guard let data = value.data(using: .utf8) else {
            return false
        }

        // Delete existing item if present
        delete(forKey: key)

        // Add new item
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]

        let status = SecItemAdd(query as CFDictionary, nil)

        // If keychain fails with entitlement error (common in simulator), use UserDefaults fallback
        if status == errSecMissingEntitlement || status == -34018 {
            print("⚠️ Keychain unavailable (error \(status)), using UserDefaults fallback for: \(key)")
            UserDefaults.standard.set(value, forKey: key)
            return true
        }

        return status == errSecSuccess
    }

    /// Get string value from Keychain (with UserDefaults fallback for simulator)
    private func get(forKey key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        if status == errSecSuccess,
           let data = result as? Data,
           let value = String(data: data, encoding: .utf8) {
            return value
        }

        // If keychain fails (common in simulator), try UserDefaults fallback
        if status == errSecMissingEntitlement || status == -34018 || status == errSecItemNotFound {
            if let value = UserDefaults.standard.string(forKey: key) {
                print("📦 Retrieved from UserDefaults fallback: \(key)")
                return value
            }
        }

        return nil
    }

    /// Delete item from Keychain (and UserDefaults fallback)
    private func delete(forKey key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]

        let status = SecItemDelete(query as CFDictionary)

        // Also remove from UserDefaults fallback storage
        UserDefaults.standard.removeObject(forKey: key)

        return status == errSecSuccess || status == errSecItemNotFound
    }

    /// Check if token exists
    func hasAccessToken() -> Bool {
        return getAccessToken() != nil
    }
}

// MARK: - Biometric Authentication Support

extension KeychainManager {
    /// Save token with biometric protection
    func saveBiometricToken(_ token: String, forKey key: String) -> Bool {
        guard let data = token.data(using: .utf8) else {
            return false
        }

        // Delete existing item
        delete(forKey: key)

        // Create access control for biometric authentication
        var error: Unmanaged<CFError>?
        guard let access = SecAccessControlCreateWithFlags(
            nil,
            kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly,
            .biometryCurrentSet,
            &error
        ) else {
            return false
        }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessControl as String: access
        ]

        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }
}
