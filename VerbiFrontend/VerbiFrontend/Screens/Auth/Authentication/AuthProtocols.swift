//
//  AuthProtocols.swift
//  VerbiFrontend
//
//  Created by Анастасия Манушкина on 17.01.2025.
//

// MARK: - View Protocols
protocol AuthViewInput: AnyObject {
    func showLoading(_ isLoading: Bool)
    func showError(_ message: String)
    func showUsernameError()
    func showEmailError()
    func showPasswordError()
    func showConfirmPasswordError()
    func transitionToMode(_ mode: AuthMode)
    func navigateToMainScreen()
    func navigateToConfirmationScreen()
}

protocol AuthViewOutput {
    func didTapPrimaryAction(mode: AuthMode, credentials: AuthCredentials)
    func didTapSecondaryAction(mode: AuthMode)
    func didTapForgotPassword()
}

// MARK: - Interactor Protocols
protocol AuthInteractorInput {
    func login(credentials: AuthCredentials)
    func register(credentials: AuthCredentials)
    func resetPassword(email: String)
    func confirmResetPassword(credentials: AuthCredentials)
}

protocol AuthInteractorOutput: AnyObject {
    func didLoginSuccessfully()
    func didRegisterSuccessfully()
    func didResetPasswordSuccessfully()
    func didConfirmResetPasswordSuccessfully()
    func didFailWithError(_ error: Error)
}

// MARK: - Router Protocols
protocol AuthRouterInput {
    func navigateToMainScreen()
    func navigateToConfirmationScreen()
}

// MARK: - Models
enum AuthMode {
    case login
    case registrationFirstStep
    case registrationSecondStep
    case resetPasswordEmailStep
    case resetPasswordPasswordStep
}

struct AuthCredentials {
    let username: String?
    let email: String?
    let password: String?
    let confirmPassword: String?
}
