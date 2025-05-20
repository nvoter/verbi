//
//  AuthInteractor.swift
//  VerbiFrontend
//
//  Created by Анастасия Манушкина on 17.01.2025.
//

import Foundation

final class AuthInteractor: AuthInteractorInput {
    // MARK: - Properties
    weak var output: AuthInteractorOutput?
    private let apiWorker: ApiWorkerProtocol

    // MARK: - LifeCycle
    init(apiWorker: ApiWorkerProtocol) {
        self.apiWorker = apiWorker
    }

    // MARK: - AuthInteractorInput
    func login(credentials: AuthCredentials) {
        apiWorker.login(email: credentials.email ?? "", password: credentials.password ?? "") { [weak self] result in
            switch result {
            case .success:
                self?.output?.didLoginSuccessfully()
            case .failure(let error):
                self?.output?.didFailWithError(error)
            }
        }
    }

    func register(credentials: AuthCredentials) {
        apiWorker
            .register(
                username: credentials.username ?? "",
                email: credentials.email ?? "",
                password: credentials.password ?? ""
            ) { [weak self] result in
            switch result {
            case .success:
                print("Successfully registered. AuthInteractor")
                self?.output?.didRegisterSuccessfully()
            case .failure(let error):
                self?.output?.didFailWithError(error)
            }
        }
    }

    func resetPassword(email: String) {
        apiWorker.resetPassword(email: email) { [weak self] result in
            switch result {
            case .success:
                self?.output?.didResetPasswordSuccessfully()
            case .failure(let error):
                self?.output?.didFailWithError(error)
            }
        }
    }

    func confirmResetPassword(credentials: AuthCredentials) {
        apiWorker
            .confirmResetPassword(
                email: credentials.email ?? "",
                newPassword: credentials.password ?? ""
            ) { [weak self] result in
            switch result {
            case .success:
                self?.output?.didConfirmResetPasswordSuccessfully()
            case .failure(let error):
                self?.output?.didFailWithError(error)
            }
        }
    }
}
