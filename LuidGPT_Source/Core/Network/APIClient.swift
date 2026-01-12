//
//  APIClient.swift
//  LuidGPT
//
//  Core HTTP client using URLSession (NO external dependencies!)
//  Handles authentication, token injection, and error handling
//

import Foundation
import os.log

/// API Error types
enum APIError: Error {
    case invalidURL
    case noData
    case decodingError(Error)
    case serverError(String)
    case unauthorized
    case insufficientCredits(required: Int, available: Int)
    case networkError(Error)
    case unknown

    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received from server"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .serverError(let message):
            return message
        case .unauthorized:
            return "Your session has expired. Please login again."
        case .insufficientCredits(let required, let available):
            return "Insufficient credits. Need \(required) but only have \(available)."
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .unknown:
            return "An unknown error occurred"
        }
    }
}

/// HTTP Methods
enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

/// API Client - Singleton for making HTTP requests
class APIClient {
    static let shared = APIClient()

    private let session: URLSession
    private let baseURL: String
    private let keychainManager: KeychainManager
    private let logger = OSLog(subsystem: "com.luidgpt.LuidGPT", category: "APIClient")

    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60

        self.session = URLSession(configuration: configuration)
        self.baseURL = AppConfig.apiBaseURL
        self.keychainManager = KeychainManager.shared
    }

    // MARK: - Request Methods

    /// Generic GET request
    func get<T: Codable>(
        _ endpoint: String,
        parameters: [String: Any]? = nil,
        requiresAuth: Bool = true
    ) async throws -> T {
        return try await request(
            endpoint: endpoint,
            method: .get,
            parameters: parameters,
            requiresAuth: requiresAuth
        )
    }

    /// Generic POST request
    func post<T: Codable>(
        _ endpoint: String,
        parameters: [String: Any]? = nil,
        requiresAuth: Bool = true
    ) async throws -> T {
        return try await request(
            endpoint: endpoint,
            method: .post,
            parameters: parameters,
            requiresAuth: requiresAuth
        )
    }

    /// Generic PUT request
    func put<T: Codable>(
        _ endpoint: String,
        parameters: [String: Any]? = nil,
        requiresAuth: Bool = true
    ) async throws -> T {
        return try await request(
            endpoint: endpoint,
            method: .put,
            parameters: parameters,
            requiresAuth: requiresAuth
        )
    }

    /// Generic PATCH request
    func patch<T: Codable>(
        _ endpoint: String,
        parameters: [String: Any]? = nil,
        requiresAuth: Bool = true
    ) async throws -> T {
        return try await request(
            endpoint: endpoint,
            method: .patch,
            parameters: parameters,
            requiresAuth: requiresAuth
        )
    }

    /// Generic DELETE request
    func delete<T: Codable>(
        _ endpoint: String,
        parameters: [String: Any]? = nil,
        requiresAuth: Bool = true
    ) async throws -> T {
        return try await request(
            endpoint: endpoint,
            method: .delete,
            parameters: parameters,
            requiresAuth: requiresAuth
        )
    }

    // MARK: - Core Request Method

    private func request<T: Codable>(
        endpoint: String,
        method: HTTPMethod,
        parameters: [String: Any]? = nil,
        requiresAuth: Bool
    ) async throws -> T {
        // Build URL
        var urlString = baseURL + endpoint

        // Add query parameters for GET requests
        if method == .get, let parameters = parameters {
            var components = URLComponents(string: urlString)
            components?.queryItems = parameters.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
            urlString = components?.url?.absoluteString ?? urlString
        }

        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }

        // Build request
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        // Add auth token if required
        if requiresAuth {
            guard let token = keychainManager.getAccessToken() else {
                throw APIError.unauthorized
            }
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        // Add body for POST/PUT/PATCH
        if method != .get, let parameters = parameters {
            request.httpBody = try? JSONSerialization.data(withJSONObject: parameters)
        }

        // Make request
        do {
            NSLog("🌐 Request: \(method.rawValue) \(urlString)")
            os_log("🌐 Request: %{public}@ %{public}@", log: logger, type: .info, method.rawValue, urlString)
            if let body = request.httpBody, let bodyString = String(data: body, encoding: .utf8) {
                NSLog("📤 Request body: \(bodyString)")
                os_log("📤 Request body: %{public}@", log: logger, type: .info, bodyString)
            }

            let (data, response) = try await session.data(for: request)

            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
            NSLog("📊 Response status: \(statusCode)")
            NSLog("📦 Response data size: \(data.count) bytes")
            os_log("📊 Response status: %{public}d", log: logger, type: .info, statusCode)
            os_log("📦 Response data size: %{public}d bytes", log: logger, type: .info, data.count)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.networkError(NSError(domain: "Invalid response", code: 0))
            }

            // Handle errors
            if httpResponse.statusCode == 401 {
                keychainManager.clearAll()
                throw APIError.unauthorized
            }

            if httpResponse.statusCode == 402 {
                // Insufficient credits
                if let errorResponse = try? JSONDecoder().decode(CreditErrorResponse.self, from: data) {
                    throw APIError.insufficientCredits(
                        required: errorResponse.details?.required ?? 0,
                        available: errorResponse.details?.available ?? 0
                    )
                } else {
                    throw APIError.serverError("Insufficient credits")
                }
            }

            if httpResponse.statusCode >= 400 {
                // Client or server error
                if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
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
                    NSLog("📥 Response data: \(jsonString)")
                    os_log("📥 Response data: %{public}@", log: logger, type: .info, jsonString)
                }
                let decoded = try decoder.decode(T.self, from: data)
                NSLog("✅ Successfully decoded response")
                return decoded
            } catch {
                NSLog("❌ Decoding error: \(error)")
                NSLog("❌ Error details: \(error.localizedDescription)")
                os_log("❌ Decoding error: %{public}@", log: logger, type: .error, error.localizedDescription)
                if let jsonString = String(data: data, encoding: .utf8) {
                    NSLog("📄 Raw data: \(jsonString)")
                    os_log("📄 Raw data: %{public}@", log: logger, type: .error, jsonString)
                }
                throw APIError.decodingError(error)
            }

        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }

    // MARK: - File Upload

    /// Upload file with multipart form data
    func uploadFile<T: Codable>(
        _ endpoint: String,
        fileData: Data,
        fileName: String,
        mimeType: String,
        parameters: [String: String]? = nil,
        requiresAuth: Bool = true
    ) async throws -> T {
        guard let url = URL(string: baseURL + endpoint) else {
            throw APIError.invalidURL
        }

        // Create multipart form data
        let boundary = UUID().uuidString
        var body = Data()

        // Add file
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
        body.append(fileData)
        body.append("\r\n".data(using: .utf8)!)

        // Add other parameters
        if let parameters = parameters {
            for (key, value) in parameters {
                body.append("--\(boundary)\r\n".data(using: .utf8)!)
                body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
                body.append("\(value)\r\n".data(using: .utf8)!)
            }
        }

        body.append("--\(boundary)--\r\n".data(using: .utf8)!)

        // Build request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.httpBody = body

        // Add auth token
        if requiresAuth {
            guard let token = keychainManager.getAccessToken() else {
                throw APIError.unauthorized
            }
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        // Make request
        do {
            let (data, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.networkError(NSError(domain: "Invalid response", code: 0))
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                throw APIError.serverError("Upload failed with status \(httpResponse.statusCode)")
            }

            return try JSONDecoder().decode(T.self, from: data)

        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }
}

// MARK: - Error Response Models

struct ErrorResponse: Codable {
    let error: String?
    let message: String?
    let code: String?
}

struct CreditErrorResponse: Codable {
    let error: String?
    let message: String?
    let code: String?
    let details: CreditErrorDetails?
}

struct CreditErrorDetails: Codable {
    let required: Int
    let available: Int
    let deficit: Int
}
