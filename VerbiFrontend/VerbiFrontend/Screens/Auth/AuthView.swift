//
//  LoginView.swift
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
        static let backgroundColor: String = "backgroundColor"
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

    // MARK: - Properties
    private var isLoginMode = true {
        didSet {
            configureView()
        }
    }

    private var isSecondStepMode = false {
        didSet {
            configureView()
        }
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
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

        stackView.addArrangedSubview(usernameTextField)
        stackView.addArrangedSubview(emailTextField)
        stackView.addArrangedSubview(passwordTextField)
        stackView.addArrangedSubview(confirmPasswordTextField)
        stackView.addArrangedSubview(actionButton)
        stackView.addArrangedSubview(secondaryActionButton)
        stackView.addArrangedSubview(forgotPasswordButton)

        configureView()
    }

    private func configureView() {
        usernameTextField.text = ""
        emailTextField.text = ""
        passwordTextField.text = ""
        confirmPasswordTextField.text = ""

        if isLoginMode {
            usernameTextField.isHidden = true
            emailTextField.isHidden = false
            passwordTextField.isHidden = false
            confirmPasswordTextField.isHidden = true
            forgotPasswordButton.isHidden = false
            actionButton.setTitle(Constants.loginButtonTitle, for: .normal)
            secondaryActionButton.setTitle(Constants.signupButtonTitle, for: .normal)
        } else if isSecondStepMode {
            usernameTextField.isHidden = true
            emailTextField.isHidden = true
            passwordTextField.isHidden = false
            confirmPasswordTextField.isHidden = false
            forgotPasswordButton.isHidden = true
            secondaryActionButton.setTitle(Constants.loginButtonTitle, for: .normal)
            actionButton.setTitle(Constants.signupButtonTitle, for: .normal)
        } else {
            usernameTextField.isHidden = false
            emailTextField.isHidden = false
            passwordTextField.isHidden = true
            confirmPasswordTextField.isHidden = true
            forgotPasswordButton.isHidden = true
            secondaryActionButton.setTitle(Constants.loginButtonTitle, for: .normal)
            actionButton.setTitle(Constants.nextButtonTitle, for: .normal)
        }
    }

    // MARK: - Actions
    @objc
    private func handlePrimaryAction() {
        if isLoginMode {
            print("handle login")
        } else if isSecondStepMode {
            print("handle registration")
        } else {
            isSecondStepMode.toggle()
            UIView.transition(with: stackView, duration: 0.3, options: .transitionCrossDissolve, animations: {
                self.configureView()
            })
        }
    }

    @objc private func toggleAuthMode() {
        isLoginMode.toggle()
        isSecondStepMode = false
        UIView.transition(with: stackView, duration: 0.3, options: .transitionCrossDissolve, animations: {
            self.configureView()
        })
    }

    @objc private func handleForgotPassword() {
        print("а голову ты дома не забыл?")
    }
}
