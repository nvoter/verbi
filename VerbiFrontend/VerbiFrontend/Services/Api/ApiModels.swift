//
//  ApiModels.swift
//  VerbiFrontend
//
//  Created by Анастасия Манушкина on 30.01.2025.
//

import UIKit

// MARK: - Response Models
// MARK: Auth
struct ApiResponse: Decodable {
    let message: String?
}

struct LoginResponse: Decodable {
    let accessToken: String
    let refreshToken: String
    let expiresIn: Int

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case expiresIn = "expires_in"
    }
}

struct RefreshResponse: Decodable {
    let accessToken: String

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
    }
}

struct UserInfoResponse: Decodable {
    let username: String
    let email: String
}

// MARK: Library
struct GetDocumentsResponse: Decodable {
    let documents: [Document]
}

struct GetCredentialsResponse: Decodable {
    let username: String
    let password: String
    let host: String
    let port: String
}

struct CreateDocumentResponse: Decodable {
    let documentId: UInt
    let title: String
    let path: String
    let sftp: GetCredentialsResponse
}

struct DocumentPreview {
    let id: UInt
    let title: String
    let image: UIImage
}

// MARK: LLM
struct LlmResponse: Codable {
    let response: String
}

struct LlmRequest: Codable {
    let query: String
    let queryType: String
    let prompt: String
    let book: String

    enum CodingKeys: String, CodingKey {
        case query
        case queryType = "query_type"
        case prompt
        case book
    }
}
