//
//  AccountPresenter.swift
//  VerbiFrontend
//
//  Created by Анастасия Манушкина on 25.01.2025.
//

import Foundation

final class AccountPresenter: AccountViewOutput, AccountInteractorOutput {
    // MARK: - Properties
    weak var view: AccountViewInput?
    private let interactor: AccountInteractorInput
    private let router: AccountRouterInput

    // MARK: - LifeCycle
    init(interactor: AccountInteractorInput, router: AccountRouterInput) {
        self.interactor = interactor
        self.router = router
    }

    // MARK: - AccountViewOutput
    func viewDidLoad() {
        interactor.fetchUserInfo()
    }

    func didTapEditProfile() {
        view?.setEditingMode(true)
    }

    func didTapSaveProfile(username: String, email: String) {
        interactor.updateUserInfo(username: username, email: email)
    }

    func didSelectTheme(_ theme: AppTheme) {
        interactor.changeTheme(theme)
    }

    func didSelectLanguage(_ language: AppLanguage) {
        interactor.changeLanguage(language)
    }

    func didTapLogout() {
        interactor.logout()
        router.navigateToAuthScreen()
    }

    func didTapDeleteAccount() {
        interactor.deleteAccount()
        router.navigateToAuthScreen()
    }

    func didTapBackButton() {
        router.navigateToMainScreen()
    }

    // MARK: - AccountInteractorOutput
    func didFetchUserInfo(username: String, email: String) {
        view?.updateUserInfo(username: username, email: email)
    }

    func didUpdateUserInfoSuccessfully() {
        view?.setEditingMode(false)
    }

    func didChangeThemeSuccessfully() {
        view?.showThemeChange()
    }

    func didChangeLanguageSuccessfully() {
        view?.showLanguageChange()
    }

    func didLogoutSuccessfully() {
        router.navigateToAuthScreen()
    }

    func didDeleteAccountSuccessfully() {
        router.navigateToAuthScreen()
    }

    func didFailWithError(_ error: Error) {
        view?.showError(error.localizedDescription)
    }
}
