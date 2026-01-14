//
//  CreditService.swift
//  LuidGPT
//
//  Service for credit operations via Luidhub-backend
//

import Foundation
import os.log

/// Service for managing credits via Luidhub API
class CreditService {
    static let shared = CreditService()

    private let session: URLSession
    private let baseURL: String
    private let keychainManager: KeychainManager
    private let logger = OSLog(subsystem: "com.luidgpt.LuidGPT", category: "CreditService")

    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60

        self.session = URLSession(configuration: configuration)
        self.baseURL = AppConfig.luidhubBaseURL
        self.keychainManager = KeychainManager.shared
    }

    // MARK: - Public Methods

    /// Get current credit balance
    func getBalance() async throws -> CreditBalance {
        NSLog("💳 Fetching credit balance from Luidhub...")
        os_log("💳 Fetching credit balance from Luidhub...", log: logger, type: .info)

        let endpoint = "/api/credits/balance"
        let response: CreditBalanceResponse = try await makeRequest(
            endpoint: endpoint,
            method: "GET"
        )

        NSLog("💳 Credit balance: %d total credits", response.data.totalCredits)
        os_log("💳 Credit balance: %{public}d total credits", log: logger, type: .info, response.data.totalCredits)

        return response.data
    }

    /// Get credit transaction history
    func getTransactions(page: Int = 1, limit: Int = 20) async throws -> (transactions: [CreditTransaction], pagination: PaginationInfo?) {
        NSLog("💳 Fetching credit transactions (page: %d, limit: %d)...", page, limit)
        os_log("💳 Fetching credit transactions (page: %{public}d, limit: %{public}d)...", log: logger, type: .info, page, limit)

        let endpoint = "/api/credits/transactions?page=\(page)&limit=\(limit)"
        let response: CreditTransactionsResponse = try await makeRequest(
            endpoint: endpoint,
            method: "GET"
        )

        NSLog("💳 Fetched %d transactions", response.data.count)
        os_log("💳 Fetched %{public}d transactions", log: logger, type: .info, response.data.count)

        return (response.data, response.pagination)
    }

    /// Get available credit packages for purchase
    func getPackages() async throws -> [CreditPackage] {
        NSLog("💳 Fetching credit packages...")
        os_log("💳 Fetching credit packages...", log: logger, type: .info)

        let endpoint = "/api/credits/packages"
        let response: CreditPackagesResponse = try await makeRequest(
            endpoint: endpoint,
            method: "GET"
        )

        NSLog("💳 Found %d credit packages", response.data.count)
        os_log("💳 Found %{public}d credit packages", log: logger, type: .info, response.data.count)

        return response.data
    }

    /// Create Stripe checkout session for credit purchase
    func createCheckoutSession(packageId: String) async throws -> String {
        NSLog("💳 Creating checkout session for package: %@", packageId)
        os_log("💳 Creating checkout session for package: %{public}@", log: logger, type: .info, packageId)

        let endpoint = "/api/credits/purchase"
        let params: [String: Any] = [
            "packageId": packageId
        ]

        struct CheckoutResponse: Codable {
            let success: Bool
            let url: String
        }

        let response: CheckoutResponse = try await makeRequest(
            endpoint: endpoint,
            method: "POST",
            parameters: params
        )

        return response.url
    }

    // MARK: - Private Helpers

    private func makeRequest<T: Codable>(
        endpoint: String,
        method: String,
        parameters: [String: Any]? = nil
    ) async throws -> T {
        // Build URL
        guard let url = URL(string: baseURL + endpoint) else {
            throw APIError.invalidURL
        }

        // Build request
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        // Add auth token
        guard let token = keychainManager.getAccessToken() else {
            NSLog("❌ No access token found for Luidhub request")
            throw APIError.unauthorized
        }
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        // Add body for POST/PUT/PATCH
        if method != "GET", let parameters = parameters {
            request.httpBody = try? JSONSerialization.data(withJSONObject: parameters)
        }

        // Make request
        do {
            NSLog("🌐 Luidhub Request: %@ %@", method, url.absoluteString)
            os_log("🌐 Luidhub Request: %{public}@ %{public}@", log: logger, type: .info, method, url.absoluteString)

            if let body = request.httpBody, let bodyString = String(data: body, encoding: .utf8) {
                NSLog("📤 Request body: %@", bodyString)
            }

            let (data, response) = try await session.data(for: request)

            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
            NSLog("📊 Luidhub Response status: %d", statusCode)
            NSLog("📦 Response data size: %d bytes", data.count)
            os_log("📊 Luidhub Response status: %{public}d", log: logger, type: .info, statusCode)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.networkError(NSError(domain: "Invalid response", code: 0))
            }

            // Handle errors
            if httpResponse.statusCode == 401 {
                NSLog("❌ Luidhub: Unauthorized")
                throw APIError.unauthorized
            }

            if httpResponse.statusCode >= 400 {
                // Try to parse error response
                if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                    NSLog("❌ Luidhub error: %@", errorResponse.error ?? "Unknown")
                    throw APIError.serverError(
                        errorResponse.error ?? errorResponse.message ?? "Request failed"
                    )
                } else {
                    throw APIError.serverError("Request failed with status \(httpResponse.statusCode)")
                }
            }

            // Decode response
            let decoder = JSONDecoder()
            // Custom date strategy to handle milliseconds
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            decoder.dateDecodingStrategy = .formatted(formatter)

            do {
                // Debug: Print response data
                if let jsonString = String(data: data, encoding: .utf8) {
                    NSLog("📥 Luidhub Response: %@", jsonString)
                }

                let decoded = try decoder.decode(T.self, from: data)
                NSLog("✅ Successfully decoded Luidhub response")
                return decoded

            } catch {
                NSLog("❌ Luidhub decoding error: %@", error.localizedDescription)
                os_log("❌ Luidhub decoding error: %{public}@", log: logger, type: .error, error.localizedDescription)
                if let jsonString = String(data: data, encoding: .utf8) {
                    NSLog("📄 Raw data: %@", jsonString)
                }
                throw APIError.decodingError(error)
            }

        } catch let error as APIError {
            throw error
        } catch {
            NSLog("❌ Luidhub network error: %@", error.localizedDescription)
            throw APIError.networkError(error)
        }
    }
}
