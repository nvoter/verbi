//
//  AccountInteractor.swift
//  VerbiFrontend
//
//  Created by Анастасия Манушкина on 25.01.2025.
//

import Foundation

final class AccountInteractor: AccountInteractorInput {
    // MARK: - Properties
    weak var output: AccountInteractorOutput?
    private let apiWorker: ApiWorkerProtocol
    private var isRefreshing = false
    private var pendingRequests: [(() -> Void)] = []

    // MARK: - LifeCycle
    init(apiWorker: ApiWorkerProtocol) {
        self.apiWorker = apiWorker
    }

    // MARK: - AccountInteractorInput
    func fetchUserInfo() {
        apiWorker.getUserInfo { [weak self] result in
            switch result {
            case .success(let userInfo):
                self?.output?.didFetchUserInfo(username: userInfo.username, email: userInfo.email)
            case .failure(let error):
                self?.handleError(error, retryAction: { [weak self] in
                    self?.fetchUserInfo()
                })
            }
        }
    }

    func updateUserInfo(username: String, email: String) {
        apiWorker.updateUserInfo(username: username) { [weak self] result in
            switch result {
            case .success:
                self?.output?.didUpdateUserInfoSuccessfully()
            case .failure(let error):
                self?.handleError(error, retryAction: { [weak self] in
                    self?.updateUserInfo(username: username, email: email)
                })
            }
        }
    }

    func changeTheme(_ theme: AppTheme) {
        UserDefaultsService.shared.setTheme(theme)
        output?.didChangeThemeSuccessfully()
    }

    func changeLanguage(_ language: AppLanguage) {
        UserDefaultsService.shared.setLanguage(language)
        output?.didChangeLanguageSuccessfully()
    }

    func logout() {
        guard let refreshToken = KeychainManager.shared.getRefreshToken() else {
            output?.didFailWithError(NSError(domain: "Auth", code: 401, userInfo: nil))
            return
        }

        apiWorker.logout(refreshToken: refreshToken) { [weak self] result in
            switch result {
            case .success:
                KeychainManager.shared.clear()
                UserDefaultsService.shared.setAuthorized(false)
                self?.output?.didLogoutSuccessfully()
            case .failure(let error):
                self?.handleError(error, retryAction: { [weak self] in
                    self?.logout()
                })
            }
        }
    }

    func deleteAccount() {
        apiWorker.deleteAccount { [weak self] result in
            switch result {
            case .success:
                KeychainManager.shared.clear()
                UserDefaultsService.shared.setAuthorized(false)
                self?.output?.didDeleteAccountSuccessfully()
            case .failure(let error):
                self?.handleError(error, retryAction: { [weak self] in
                    self?.deleteAccount()
                })
            }
        }
    }

    // MARK: - Methods
    private func handleError(_ error: Error, retryAction: @escaping () -> Void) {
        if let nsError = error as? NSError, nsError.code == 401 {
            if isRefreshing {
                pendingRequests.append(retryAction)
                return
            }

            isRefreshing = true
            refresh { [weak self] success in
                guard let self = self else { return }

                self.isRefreshing = false

                if success {
                    retryAction()

                    self.pendingRequests.forEach { $0() }
                    self.pendingRequests.removeAll()
                } else {
                    UserDefaultsService.shared.setAuthorized(false)
                    KeychainManager.shared.clear()
                    self.output?.didLogoutSuccessfully()
                }
            }
        } else {
            output?.didFailWithError(error)
        }
    }

    private func refresh(completion: @escaping (Bool) -> Void) {
        guard let refreshToken = KeychainManager.shared.getRefreshToken() else {
            completion(false)
            return
        }

        apiWorker.refresh(refreshToken: refreshToken) { result in
            switch result {
            case .success(let response):
                UserDefaultsService.shared.setAuthorized(true)
                KeychainManager.shared.save(
                    accessToken: response
                )
                completion(true)
            case .failure:
                completion(false)
            }
        }
    }
}
