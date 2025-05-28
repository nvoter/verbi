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
    private let apiWorker: AuthApiWorkerProtocol

    // MARK: - LifeCycle
    init(apiWorker: AuthApiWorkerProtocol) {
        self.apiWorker = apiWorker
    }

    // MARK: - AuthInteractorInput
    func login(credentials: AuthCredentials) {
        guard let emailOrUsername = credentials.username else {
            fatalError("Email or username is required")
        }
        guard let password = credentials.password else {
            fatalError("Password is required")
        }
        apiWorker.login(
            emailOrUsername: emailOrUsername,
            password: password
        ) { [weak self] result in
            TokenManager.shared.clear()
            switch result {
            case .success(let loginResponse):
                TokenManager.shared
                    .save(
                        accessToken: loginResponse.accessToken,
                        refreshToken: loginResponse.refreshToken
                    )
                self?.output?.didLoginSuccessfully()
            case .failure(let error):
                self?.output?.didFailWithError(error)
            }
        }
    }

    func register(credentials: AuthCredentials) {
        apiWorker
            .register(
                email: credentials.email ?? "",
                username: credentials.username ?? "",
                password: credentials.password ?? ""
            ) { [weak self] result in
            switch result {
            case .success:
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
                self?.output?.didSendCodeSuccessfully()
            case .failure(let error):
                self?.output?.didFailWithError(error)
            }
        }
    }

    func confirmResetPassword(credentials: AuthCredentials) {
        guard let email = credentials.email, !email.isEmpty else {
            fatalError("Email is required")
        }
        apiWorker
            .confirmResetPassword(
                email: credentials.email ?? "",
                newPassword: credentials.password ?? "",
                code: credentials.code ?? ""
            ) { [weak self] result in
            switch result {
            case .success:
                self?.output?.didConfirmResetPasswordSuccessfully()
            case .failure(let error):
                self?.output?.didFailWithError(error)
            }
        }
    }

    func confirmEmail(credentials: AuthCredentials) {
        guard let email = credentials.email, !email.isEmpty else {
            fatalError("Email is required")
        }

        guard let code = credentials.code, !code.isEmpty else {
            fatalError("Code is required")
        }

        apiWorker.confirmEmail(email: email, code: code) { [weak self] result in
            switch result {
            case .success:
                self?.output?.didConfirmEmailSuccessfully()
            case .failure(let error):
                self?.output?.didFailWithError(error)
            }
        }
    }

    func resendCode(email: String, mode: AuthMode) {
        guard mode == .confirmEmail || mode == .confirmResetPassword else { return }
        let codeType: String = mode == .confirmEmail ? "EmailConfirmation" : "PasswordReset"
        apiWorker.resendCode(email: email, codeType: codeType) { [weak self] result in
            switch result {
            case .success:
                self?.output?.didResendCodeSuccessfully()
            case .failure(let error):
                self?.output?.didFailWithError(error)
            }
        }
    }
}
