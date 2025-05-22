//
//  AccountProtocols.swift
//  VerbiFrontend
//
//  Created by Анастасия Манушкина on 25.01.2025.
//

// MARK: - View Protocols
protocol AccountViewInput: AnyObject {
    func showError(_ message: String)
    func updateUserInfo(username: String, email: String)
    func setEditingMode(_ isEditing: Bool)
    func showThemeChange()
    func showLanguageChange()
}

protocol AccountViewOutput {
    func viewDidLoad()
    func didTapEditProfile()
    func didTapSaveProfile(username: String, email: String)
    func didSelectTheme(_ theme: AppTheme)
    func didSelectLanguage(_ language: AppLanguage)
    func didTapLogout()
    func didTapDeleteAccount()
    func didTapBackButton()
}

// MARK: - Interactor Protocols
protocol AccountInteractorInput {
    func fetchUserInfo()
    func updateUserInfo(username: String, email: String)
    func changeTheme(_ theme: AppTheme)
    func changeLanguage(_ language: AppLanguage)
    func logout()
    func deleteAccount()
}

protocol AccountInteractorOutput: AnyObject {
    func didFetchUserInfo(username: String, email: String)
    func didUpdateUserInfoSuccessfully()
    func didChangeThemeSuccessfully()
    func didChangeLanguageSuccessfully()
    func didLogoutSuccessfully()
    func didDeleteAccountSuccessfully()
    func didFailWithError(_ error: Error)
}

// MARK: - Router Protocols
protocol AccountRouterInput {
    func navigateToMainScreen()
    func navigateToAuthScreen()
}

// MARK: - Models
enum AppTheme: String, CaseIterable {
    case light
    case dark
    case system

    var localizedTitle: String {
        switch self {
        case .light: return String(localized: "Light")
        case .dark: return String(localized: "Dark")
        case .system: return String(localized: "System")
        }
    }
}

enum AppLanguage: String, CaseIterable {
    case russian = "ru"
    case english = "en"

    var localizedTitle: String {
        switch self {
        case .russian: return String(localized: "Russian")
        case .english: return String(localized: "English")
        }
    }
}
