//
//  UserDefaultsService.swift
//  VerbiFrontend
//
//  Created by Анастасия Манушкина on 21.05.2025.
//

import Foundation

final class UserDefaultsService {
    // MARK: - Constants
    private enum Constants {
        static let authorizedKey: String = "authorized"
    }

    // MARK: - Properties
    private let userDefaults = UserDefaults.standard

    // MARK: - Sigleton
    static let shared = UserDefaultsService()

    private init() {}

    // MARK: - Methods
    func getAuthorized() -> Bool {
        return userDefaults.bool(forKey: Constants.authorizedKey)
    }

    func setAuthorized(_ authorized: Bool) {
        userDefaults.set(authorized, forKey: Constants.authorizedKey)
    }
}
