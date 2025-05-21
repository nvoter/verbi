//
//  ApiModels.swift
//  VerbiFrontend
//
//  Created by Анастасия Манушкина on 30.01.2025.
//

// MARK: - Response Models
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
}
