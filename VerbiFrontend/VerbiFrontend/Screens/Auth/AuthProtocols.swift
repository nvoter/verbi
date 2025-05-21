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
    func highlightEmptyFields()
    func transitionToMode(_ mode: AuthMode)
    func showTimer()
}

protocol AuthViewOutput {
    func didTapPrimaryAction(mode: AuthMode, credentials: AuthCredentials)
    func didTapSecondaryAction(mode: AuthMode)
    func didTapForgotPassword()
    func didTapResendCode(mode: AuthMode, email: String)
}

// MARK: - Interactor Protocols
protocol AuthInteractorInput {
    func login(credentials: AuthCredentials)
    func register(credentials: AuthCredentials)
    func confirmEmail(credentials: AuthCredentials)
    func resetPassword(email: String)
    func confirmResetPassword(credentials: AuthCredentials)
    func resendCode(email: String, mode: AuthMode)
}

protocol AuthInteractorOutput: AnyObject {
    func didLoginSuccessfully()
    func didRegisterSuccessfully()
    func didResetPasswordSuccessfully()
    func didConfirmResetPasswordSuccessfully()
    func didResendCodeSuccessfully()
    func didConfirmEmailSuccessfully()
    func didFailWithError(_ error: Error)
    func didSendCodeSuccessfully()
}

// MARK: - Router Protocols
protocol AuthRouterInput {
    func navigateToMainScreen()
}

// MARK: - Models
enum AuthMode {
    case login
    case registrationFirstStep
    case registrationSecondStep
    case resetPasswordEmailStep
    case resetPasswordPasswordStep
    case confirmEmail
    case confirmResetPassword
}

struct AuthCredentials {
    let username: String?
    let email: String?
    let password: String?
    let confirmPassword: String?
    let code: String?
}
