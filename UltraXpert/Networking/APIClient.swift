import Foundation
import SwiftUI

class APIClient {
    static let shared = APIClient()
    
    // Single source of truth → AppConfig.swift
    private let baseURL = AppConfig.backendURL
    
    private init() {}
    
    // Convenience method for requests with no body
    func request<T: Decodable>(
        endpoint: String,
        method: String = "GET",
        responseType: T.Type
    ) async throws -> T {
        return try await request(
            endpoint: endpoint,
            method: method,
            body: String?.none,
            responseType: responseType
        )
    }
    
    func request<T: Decodable, U: Encodable>(
        endpoint: String,
        method: String = "GET",
        body: U? = nil,
        responseType: T.Type,
        isFormURLEncoded: Bool = false
    ) async throws -> T {
        
        guard let url = URL(string: baseURL + endpoint) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        
        if let token = UserDefaults.standard.string(forKey: "access_token") {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        if let body = body {
            if isFormURLEncoded, let dict = body as? [String: String] {
                // Form URL Encoding (Typically used by FastAPI OAuth2)
                request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                let formDataString = dict.map { "\($0.key)=\($0.value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")" }.joined(separator: "&")
                request.httpBody = formDataString.data(using: .utf8)
            } else {
                // Default JSON Encoding
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                do {
                    request.httpBody = try JSONEncoder().encode(body)
                } catch {
                    throw APIError.requestFailed
                }
            }
        }
        
        // Basic configuration
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        let session = URLSession(configuration: config)
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.requestFailed
        }
        
        if !(200...299).contains(httpResponse.statusCode) {
            // Attempt to parse server error payload
            if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data), let detail = errorResponse.detail {
                throw APIError.serverError(detail)
            }
            throw APIError.serverError("Server HTTP Status Code \(httpResponse.statusCode)")
        }
        
        do {
            let decodedData = try JSONDecoder().decode(T.self, from: data)
            return decodedData
        } catch {
            print("Decoding Error: \(error)")
            throw APIError.decodingError
        }
    }
}
