//
//  AuthView.swift
//  VerbiFrontend
//
//  Created by Анастасия Манушкина on 17.01.2025.
//

import UIKit

final class AuthView: UIViewController {
    // MARK: - Constants
    private enum Constants {
        static let fontName: String = "RubikOne-Regular"
        static let logoName: String = "verbi"
        static let logoFontSize: CGFloat = 48
        static let logoTopConstant: CGFloat = 30
        static let textFieldHeight: CGFloat = 48
        static let textFieldPadding: CGFloat = 12
        static let buttonHeight: CGFloat = 48
        static let cornerRadius: CGFloat = 8
        static let stackSpacing: CGFloat = 16
        static let fontSize: CGFloat = 16
        static let stackTopAnchorConstant: CGFloat = 40
        static let stackLeadingAnchorConstant: CGFloat = 20
        static let stackTrailingAnchorConstant: CGFloat = -20
        static let usernamePlaceholder: String = String(localized: "username")
        static let emailPlaceholder: String = "email"
        static let passwordPlaceholder: String = String(localized: "password")
        static let confirmPasswordPlaceholder: String = String(localized: "confirm password")
        static let loginButtonTitle: String = String(localized: "Login")
        static let signupButtonTitle: String = String(localized: "Sign up")
        static let forgotPasswordButtonTitle: String = String(localized: "Forgot your password?")
        static let nextButtonTitle: String = String(localized: "Next")
        static let getCodeButtonTitle: String = String(localized: "Get code")
        static let resetPasswordButtonTitle: String = String(localized: "Reset password")
        static let fatalErrorMessage: String = "init(coder:) has not been implemented"
        static let backgroundColor: String = "backgroundColor"
        static let usernameError: String = String(localized: "Field cannot be empty")
        static let emailError: String = String(localized: "Invalid email format")
        static let passwordError: String = String(localized: "Password should contain at least 8 characters")
        static let confirmPasswordError: String = String(localized: "Passwords do not match")
        static let errorFontSize: CGFloat = 10
        static let error: String = "Error"
        static let okString: String = "OK"
        static let transitionDuration: TimeInterval = 0.3
        static let titleText: String = String(localized: "Enter confirmation code")
        static let confirmButtonTitle: String = String(localized: "Confirm")
        static let resendCodeButtonTitle: String = String(localized: "Resend code")
        static let codeInputFieldCount: Int = 6
        static let codeInputFieldWidth: CGFloat = 50
        static let codeInputFieldHeight: CGFloat = 60
        static let codeInputFieldSpacing: CGFloat = 8
        static let cooldown: Int = 60
        static let timerText1: String = String(localized: "Resend code in")
        static let timerText2: String = String(localized: "s")
    }

    // MARK: - UI Elements
    private let logoLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.logoName
        label.font = UIFont(name: Constants.fontName, size: Constants.logoFontSize)
        label.textColor = .accent
        label.textAlignment = .center
        return label
    }()

    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = Constants.stackSpacing
        stackView.alignment = .fill
        return stackView
    }()

    private lazy var usernameTextField: VerbiTextField = VerbiTextField(placeholder: Constants.usernamePlaceholder)
    private lazy var emailTextField: VerbiTextField = VerbiTextField(
        placeholder: Constants.emailPlaceholder,
        keyboardType: .emailAddress
    )
    private lazy var passwordTextField: VerbiTextField = VerbiTextField(
        placeholder: Constants.passwordPlaceholder,
        isSecure: true
    )
    private lazy var confirmPasswordTextField: VerbiTextField = VerbiTextField(
        placeholder: Constants.confirmPasswordPlaceholder,
        isSecure: true
    )

    private let usernameErrorLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.usernameError
        label.font = UIFont(name: Constants.fontName, size: Constants.errorFontSize)
        label.textColor = .red
        label.isHidden = true
        return label
    }()
    private let emailErrorLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.emailError
        label.font = UIFont(name: Constants.fontName, size: Constants.errorFontSize)
        label.textColor = .red
        label.isHidden = true
        return label
    }()
    private let passwordErrorLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.passwordError
        label.font = UIFont(name: Constants.fontName, size: Constants.errorFontSize)
        label.textColor = .red
        label.isHidden = true
        return label
    }()
    private let confirmPasswordErrorLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.confirmPasswordError
        label.font = UIFont(name: Constants.fontName, size: Constants.errorFontSize)
        label.textColor = .red
        label.isHidden = true
        return label
    }()

    private lazy var actionButton: VerbiButton = {
        let button = VerbiButton(title: Constants.loginButtonTitle, isPrimary: true)
        button.addTarget(self, action: #selector(handlePrimaryAction), for: .touchUpInside)
        return button
    }()

    private lazy var secondaryActionButton: VerbiButton = {
        let button = VerbiButton(title: Constants.signupButtonTitle)
        button.addTarget(self, action: #selector(toggleAuthMode), for: .touchUpInside)
        return button
    }()

    private lazy var forgotPasswordButton: VerbiButton = {
        let button = VerbiButton(title: Constants.forgotPasswordButtonTitle)
        button.addTarget(self, action: #selector(handleForgotPassword), for: .touchUpInside)
        return button
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.titleText
        label.font = UIFont(name: Constants.fontName, size: 20)
        label.textColor = UIColor.accent
        label.textAlignment = .center
        return label
    }()

    private lazy var codeInputFields: [VerbiTextField] = {
        var fields: [VerbiTextField] = []
        for _ in 0..<Constants.codeInputFieldCount {
            let field = VerbiTextField()
            field.keyboardType = .numberPad
            field.textAlignment = .center
            field.font = UIFont(name: Constants.fontName, size: Constants.fontSize)
            field.layer.cornerRadius = Constants.cornerRadius
            field.layer.borderColor = UIColor.accent.cgColor
            field.layer.borderWidth = 1
            field.widthAnchor.constraint(equalToConstant: Constants.codeInputFieldWidth).isActive = true
            field.heightAnchor.constraint(equalToConstant: Constants.codeInputFieldHeight).isActive = true
            field.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
            fields.append(field)
        }
        return fields
    }()

    private lazy var codeInputStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: codeInputFields)
        stackView.axis = .horizontal
        stackView.spacing = Constants.codeInputFieldSpacing
        stackView.distribution = .equalSpacing
        return stackView
    }()

    private lazy var resendCodeButton: VerbiButton = {
        let button = VerbiButton(title: Constants.resendCodeButtonTitle)
        button.addTarget(self, action: #selector(handleResendCode), for: .touchUpInside)
        return button
    }()

    // MARK: - Properties
    private var mode: AuthMode = .login {
        didSet {
            configureView()
        }
    }
    private var timer: Timer?
    private var remainingSeconds: Int = 0
    private let presenter: AuthViewOutput

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }

    init(presenter: AuthViewOutput) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError(Constants.fatalErrorMessage)
    }

    // MARK: - Configuration
    private func configureUI() {
        view.backgroundColor = UIColor(named: Constants.backgroundColor)
        configureLogo()
        configureStackView()
    }

    private func configureLogo() {
        view.addSubview(logoLabel)
        logoLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(
            [
                logoLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                logoLabel.topAnchor
                    .constraint(
                        equalTo: view.safeAreaLayoutGuide.topAnchor,
                        constant: Constants.logoTopConstant
                    )
            ]
        )
    }

    private func configureStackView() {
        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(
            [
                stackView.topAnchor
                    .constraint(
                        equalTo: logoLabel.bottomAnchor,
                        constant: Constants.stackTopAnchorConstant
                    ),
                stackView.leadingAnchor
                    .constraint(
                        equalTo: view.leadingAnchor,
                        constant: Constants.stackLeadingAnchorConstant
                    ),
                stackView.trailingAnchor
                    .constraint(
                        equalTo: view.trailingAnchor,
                        constant: Constants.stackTrailingAnchorConstant
                    )
            ]
        )

        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(codeInputStackView)
        stackView.addArrangedSubview(usernameTextField)
        stackView.addArrangedSubview(usernameErrorLabel)
        stackView.addArrangedSubview(emailTextField)
        stackView.addArrangedSubview(emailErrorLabel)
        stackView.addArrangedSubview(passwordTextField)
        stackView.addArrangedSubview(passwordErrorLabel)
        stackView.addArrangedSubview(confirmPasswordTextField)
        stackView.addArrangedSubview(confirmPasswordErrorLabel)
        stackView.addArrangedSubview(actionButton)
        stackView.addArrangedSubview(secondaryActionButton)
        stackView.addArrangedSubview(forgotPasswordButton)
        stackView.addArrangedSubview(resendCodeButton)

        configureView()
    }

    private func configureView() {
        usernameTextField.isHidden = mode != .registrationFirstStep && mode != .login
        emailTextField.isHidden = mode != .registrationFirstStep && mode != .resetPasswordEmailStep
        passwordTextField.isHidden = mode != .login && mode != .registrationSecondStep && mode != .resetPasswordPasswordStep
        confirmPasswordTextField.isHidden = mode != .registrationSecondStep && mode != .resetPasswordPasswordStep
        forgotPasswordButton.isHidden = mode != .login
        titleLabel.isHidden = mode != .confirmEmail && mode != .confirmResetPassword
        codeInputStackView.isHidden = mode != .confirmEmail && mode != .confirmResetPassword
        resendCodeButton.isHidden = mode != .confirmEmail && mode != .confirmResetPassword
        secondaryActionButton.isHidden = mode == .confirmEmail || mode == .confirmResetPassword

        switch mode {
        case .login:
            actionButton.setTitle(Constants.loginButtonTitle, for: .normal)
            secondaryActionButton.setTitle(Constants.signupButtonTitle, for: .normal)
        case .registrationFirstStep:
            actionButton.setTitle(Constants.nextButtonTitle, for: .normal)
            secondaryActionButton.setTitle(Constants.loginButtonTitle, for: .normal)
        case .registrationSecondStep:
            actionButton.setTitle(Constants.signupButtonTitle, for: .normal)
            secondaryActionButton.setTitle(Constants.loginButtonTitle, for: .normal)
        case .resetPasswordEmailStep:
            actionButton.setTitle(Constants.getCodeButtonTitle, for: .normal)
            secondaryActionButton.setTitle(Constants.loginButtonTitle, for: .normal)
        case .resetPasswordPasswordStep:
            actionButton.setTitle(Constants.resetPasswordButtonTitle, for: .normal)
            secondaryActionButton.setTitle(Constants.loginButtonTitle, for: .normal)
        case .confirmEmail, .confirmResetPassword:
            actionButton.setTitle(Constants.confirmButtonTitle, for: .normal)
        }
    }

    // MARK: - Actions
    @objc
    private func handlePrimaryAction() {
        hideErrors()
        let credentials: AuthCredentials = AuthCredentials(
            username: usernameTextField.text,
            email: emailTextField.text,
            password: passwordTextField.text,
            confirmPassword: confirmPasswordTextField.text,
            code: getCodeFromFields()
        )
        presenter.didTapPrimaryAction(mode: mode, credentials: credentials)
    }

    @objc private func toggleAuthMode() {
        hideErrors()
        presenter.didTapSecondaryAction(mode: mode)
    }

    @objc private func handleForgotPassword() {
        hideErrors()
        presenter.didTapForgotPassword()
    }

    @objc private func textFieldDidChange(_ textField: UITextField) {
        guard let text = textField.text, !text.isEmpty else {
            moveFocus(toPreviousTextField: textField)
            actionButton.isEnabled = false
            UIView.animate(withDuration: Constants.transitionDuration) {
                self.actionButton.alpha = 0.5
            }
            return
        }

        if text.count > 1 {
            textField.text = String(text.last ?? " ")
        }

        moveFocus(toNextTextField: textField)

        if allFilled() {
            actionButton.isEnabled = true
            UIView.animate(withDuration: Constants.transitionDuration) {
                self.actionButton.alpha = 1
            }
        } else {
            actionButton.isEnabled = false
            UIView.animate(withDuration: Constants.transitionDuration) {
                self.actionButton.alpha = 0.5
            }
        }
    }

    @objc private func handleResendCode() {
        guard let email = emailTextField.text else { return }
        presenter.didTapResendCode(mode: mode, email: email)
    }

    // MARK: - Methods
    private func getCodeFromFields() -> String? {
        let code = codeInputFields.compactMap(\.text).joined()
        return code.isEmpty ? nil : code
    }

    private func moveFocus(toNextTextField currentTextField: UITextField) {
        guard let textField = currentTextField as? VerbiTextField else { return }
        guard let currentIndex = codeInputFields.firstIndex(
            of: textField
        ), currentIndex < codeInputFields.count - 1 else {
            return
        }

        codeInputFields[currentIndex + 1].becomeFirstResponder()
    }

    private func moveFocus(toPreviousTextField currentTextField: UITextField) {
        guard let textField = currentTextField as? VerbiTextField else { return }
        guard let currentIndex = codeInputFields.firstIndex(
            of: textField
        ), currentIndex > 0 else {
            return
        }

        codeInputFields[currentIndex - 1].becomeFirstResponder()
    }

    private func allFilled() -> Bool {
        for textField in codeInputFields {
            guard let text = textField.text, !text.isEmpty else {
                return false
            }
        }
        return true
    }
}

// MARK: - AuthViewInput
extension AuthView: AuthViewInput {
    func showLoading(_ isLoading: Bool) {
        actionButton.isLoading = isLoading
    }

    func showError(_ message: String) {
        let alert = UIAlertController(
            title: Constants.error,
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: Constants.okString, style: .default))
        present(alert, animated: true)
    }

    func showUsernameError() {
        usernameErrorLabel.isHidden = false
        usernameTextField.changeBorderColor(to: .red)
    }

    func showEmailError() {
        emailErrorLabel.isHidden = false
        emailTextField.changeBorderColor(to: .red)
    }

    func showPasswordError() {
        passwordErrorLabel.isHidden = false
        passwordTextField.changeBorderColor(to: .red)
    }

    func showConfirmPasswordError() {
        confirmPasswordErrorLabel.isHidden = false
        confirmPasswordTextField.changeBorderColor(to: .red)
    }

    func hideErrors() {
        usernameErrorLabel.isHidden = true
        usernameTextField.resetBorderColor()
        emailErrorLabel.isHidden = true
        emailTextField.resetBorderColor()
        passwordErrorLabel.isHidden = true
        passwordTextField.resetBorderColor()
        confirmPasswordErrorLabel.isHidden = true
        confirmPasswordTextField.resetBorderColor()
    }

    func transitionToMode(_ mode: AuthMode) {
        self.mode = mode
        UIView
            .transition(
                with: stackView,
                duration: Constants.transitionDuration,
                options: .transitionFlipFromLeft,
                animations: {
            self.configureView()
        })
        if mode == .confirmEmail || mode == .confirmResetPassword {
            actionButton.isEnabled = false
            UIView.animate(withDuration: Constants.transitionDuration) {
                self.actionButton.alpha = 0.5
            }
        }
    }

    func highlightEmptyFields() {
        for index in 0..<Constants.codeInputFieldCount {
            if codeInputFields[index].text?.isEmpty ?? true {
                UIView.animate(withDuration: Constants.transitionDuration) {
                    self.codeInputFields[index].changeBorderColor(to: .red)
                }
            }
        }
    }

    func showTimer() {
        remainingSeconds = Constants.cooldown
        resendCodeButton.isEnabled = false
        resendCodeButton.setTitle("\(Constants.timerText1) \(remainingSeconds) \(Constants.timerText2)", for: .disabled)
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            guard let self else { return }
            self.remainingSeconds -= 1
            self.secondaryActionButton
                .setTitle(
                    "\(Constants.timerText1) \(self.remainingSeconds) \(Constants.timerText2)",
                    for: .normal
                )
            if self.remainingSeconds <= 0 {
                timer.invalidate()
                self.timer = nil
                self.secondaryActionButton.isEnabled = true
                self.secondaryActionButton
                    .setTitle(
                        Constants.resendCodeButtonTitle,
                        for: .normal
                    )
            }
        }
    }
}
