//
//  UserDefaultsService.swift
//  VerbiFrontend
//
//  Created by Анастасия Манушкина on 21.05.2025.
//

import Foundation

final class UserDefaultsService {
    // MARK: - Properties
    private let userDefaults = UserDefaults.standard

    // MARK: - Singleton
    static let shared = UserDefaultsService()

    private init() {}

    // MARK: - Keys
    private enum Keys {
        static let isAuthorized = "isAuthorized"
        static let theme = "appTheme"
        static let language = "appLanguage"
    }

    // MARK: - Methods
    func setAuthorized(_ isAuthorized: Bool) {
        userDefaults.set(isAuthorized, forKey: Keys.isAuthorized)
    }

    func isAuthorized() -> Bool {
        return userDefaults.bool(forKey: Keys.isAuthorized)
    }

    func setTheme(_ theme: AppTheme) {
        userDefaults.set(theme.rawValue, forKey: Keys.theme)
    }

    func getTheme() -> AppTheme {
        guard let themeString = userDefaults.string(forKey: Keys.theme),
              let theme = AppTheme(rawValue: themeString) else {
            return .system
        }
        return theme
    }

    func setLanguage(_ language: AppLanguage) {
        userDefaults.set(language.rawValue, forKey: Keys.language)
    }

    func getLanguage() -> AppLanguage {
        guard let languageString = userDefaults.string(forKey: Keys.language),
              let language = AppLanguage(rawValue: languageString) else {
            return .english
        }
        return language
    }
}
