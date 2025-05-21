//
//  AuthPresenter.swift
//  VerbiFrontend
//
//  Created by Анастасия Манушкина on 17.01.2025.
//

import Foundation

final class AuthPresenter: AuthViewOutput, AuthInteractorOutput {
    // MARK: - Properties
    weak var view: AuthViewInput?
    private let interactor: AuthInteractorInput
    private let router: AuthRouterInput

    // MARK: - LifeCycle
    init(interactor: AuthInteractorInput, router: AuthRouterInput) {
        self.interactor = interactor
        self.router = router
    }

    // MARK: - AuthViewOutput
    func didTapPrimaryAction(mode: AuthMode, credentials: AuthCredentials) {
        if !checkCredentials(credentials, mode: mode) {
            return
        }

        switch mode {
        case .login:
            interactor.login(credentials: credentials)
            view?.showLoading(true)
        case .registrationFirstStep:
            view?.transitionToMode(.registrationSecondStep)
        case .registrationSecondStep:
            view?.showLoading(true)
            interactor.register(credentials: credentials)
        case .resetPasswordEmailStep:
            guard let email = credentials.email else { return }
            interactor.resetPassword(email: email)
            view?.showLoading(true)
        case .resetPasswordPasswordStep:
            interactor.confirmResetPassword(credentials: credentials)
            view?.showLoading(true)
        case .confirmEmail:
            interactor.confirmEmail(credentials: credentials)
            view?.showLoading(true)
        case .confirmResetPassword:
            interactor.confirmResetPassword(credentials: credentials)
            view?.showLoading(true)
        }
    }

    func didTapSecondaryAction(mode: AuthMode) {
        switch mode {
        case .login:
            view?.transitionToMode(.registrationFirstStep)
        case .registrationFirstStep:
            view?.transitionToMode(.login)
        case .registrationSecondStep:
            view?.transitionToMode(.login)
        case .resetPasswordEmailStep:
            view?.transitionToMode(.login)
        case .resetPasswordPasswordStep:
            view?.transitionToMode(.resetPasswordEmailStep)
        case .confirmEmail, .confirmResetPassword:
            break
        }
    }

    func didTapForgotPassword() {
        view?.transitionToMode(.resetPasswordEmailStep)
    }

    func didTapResendCode(mode: AuthMode, email: String) {
        print("Resend code tapped")
    }

    // MARK: - AuthInteractorOutput
    func didLoginSuccessfully() {
        view?.showLoading(false)
        UserDefaultsService.shared.setAuthorized(true)
        router.navigateToMainScreen()
    }

    func didRegisterSuccessfully() {
        view?.showLoading(false)
        view?.transitionToMode(.confirmEmail)
    }

    func didResetPasswordSuccessfully() {
        view?.showLoading(false)
        view?.transitionToMode(.resetPasswordPasswordStep)
    }

    func didConfirmResetPasswordSuccessfully() {
        view?.showLoading(false)
        view?.transitionToMode(.login)
    }

    func didFailWithError(_ error: Error) {
        view?.showLoading(false)
        view?.showError(error.localizedDescription)
    }

    func didSendCodeSuccessfully() {
        view?.showLoading(false)
        view?.transitionToMode(.confirmResetPassword)
    }

    func didResendCodeSuccessfully() {
        view?.showTimer()
    }

    func didConfirmEmailSuccessfully() {
        view?.showLoading(false)
        view?.transitionToMode(.login)
    }

    // MARK: - Methods
    private func checkCredentials(_ credentials: AuthCredentials, mode: AuthMode) -> Bool {
        if mode == .login || mode == .registrationFirstStep {
            guard let usernameOrEmail = credentials.username, !usernameOrEmail.isEmpty else {
                view?.showUsernameError()
                return false
            }
        }
        if mode == .registrationFirstStep || mode == .resetPasswordEmailStep {
            guard let email = credentials.email, isValidEmail(email) else {
                view?.showEmailError()
                return false
            }
        }
        if mode == .resetPasswordPasswordStep || mode == .registrationSecondStep || mode == .login {
            guard let password = credentials.password, !password.isEmpty, password.count >= 8 else {
                view?.showPasswordError()
                return false
            }
        }
        if mode == .resetPasswordPasswordStep || mode == .registrationSecondStep {
            guard let confirmPassword = credentials.confirmPassword,
            !confirmPassword.isEmpty, confirmPassword == credentials.password else {
                view?.showConfirmPasswordError()
                return false
            }
        }
        if mode == .confirmEmail || mode == .confirmResetPassword {
            guard let code = credentials.code, !code.isEmpty, code.count == 6 else {
                view?.highlightEmptyFields()
                return false
            }
        }
        return true
    }

    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
}
