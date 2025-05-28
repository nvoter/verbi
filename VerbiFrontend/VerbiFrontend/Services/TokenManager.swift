//
//  KeychainManager.swift
//  VerbiFrontend
//
//  Created by Анастасия Манушкина on 21.05.2025.
//

import Foundation
import KeychainAccess

final class TokenManager {
    // MARK: - Constants
    private enum Constants {
        static let service: String = "Verbi"
        static let accessTokenKey: String = "accessToken"
        static let refreshTokenKey: String = "refreshToken"
    }

    // MARK: - Properties
    private let keychain: Keychain = Keychain(service: Constants.service)

    // MARK: - Singleton
    static let shared = TokenManager()

    private init() {}

    // MARK: - Methods
    func save(accessToken: String, refreshToken: String? = nil) {
        do {
            try keychain.set(accessToken, key: Constants.accessTokenKey)
            if let refreshToken {
                try keychain.set(refreshToken, key: Constants.refreshTokenKey)
            }
        } catch {
            print("Failed to save tokens to keychain: \(error.localizedDescription)")
        }
    }

    func getAccessToken() -> String? {
        return try? keychain.get(Constants.accessTokenKey)
    }

    func getRefreshToken() -> String? {
        return try? keychain.get(Constants.refreshTokenKey)
    }

    func clear() {
        do {
            try keychain.remove(Constants.accessTokenKey)
            try keychain.remove(Constants.refreshTokenKey)
        } catch {
            print("Failed to clear keychain: \(error.localizedDescription)")
        }
    }
}
