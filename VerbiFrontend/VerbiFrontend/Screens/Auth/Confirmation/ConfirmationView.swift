//
//  ConfirmationView.swift
//  VerbiFrontend
//
//  Created by Анастасия Манушкина on 12.05.2025.
//

import UIKit

final class ConfirmationView: UIViewController {
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
        static let codeInputFieldCount: Int = 6
        static let codeInputFieldWidth: CGFloat = 50
        static let codeInputFieldHeight: CGFloat = 60
        static let codeInputFieldSpacing: CGFloat = 8
        static let titleText: String = "Введите код подтверждения"
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

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.titleText
        label.font = UIFont(name: Constants.fontName, size: 20)
        label.textColor = UIColor.accent
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

//    private lazy var codeInputFields: [VerbiTextField] = {
//        var fields: [VerbiTextField] = []
//        for _ in 0..<Constants.codeInputFieldCount {
//            let field = VerbiTextField(coder: )
//            field.keyboardType = .numberPad
//            field.textAlignment = .center
//            field.font = UIFont.systemFont(ofSize: Constants.fontSize)
//            field.layer.cornerRadius = Constants.cornerRadius
//            field.layer.borderColor = UIColor.accent.cgColor
//            field.layer.borderWidth = 1
//            field.widthAnchor.constraint(equalToConstant: Constants.codeInputFieldWidth).isActive = true
//            field.heightAnchor.constraint(equalToConstant: Constants.codeInputFieldHeight).isActive = true
//            field.delegate = self
//            fields.append(field)
//        }
//        return fields
//    }()
//    
//    private lazy var codeInputStackView: UIStackView = {
//        let stackView = UIStackView(arrangedSubviews: codeInputFields)
//        stackView.axis = .horizontal
//        stackView.spacing = Constants.codeInputFieldSpacing
//        stackView.distribution = .equalSpacing
//        return stackView
//    }()

    private lazy var actionButton: VerbiButton = {
        let button = VerbiButton(title: "Подтвердить", isPrimary: true)
        button.addTarget(self, action: #selector(handlePrimaryAction), for: .touchUpInside)
        return button
    }()

    private lazy var secondaryActionButton: VerbiButton = {
        let button = VerbiButton(title: "Отправить код повторно")
        button.addTarget(self, action: #selector(resendCode), for: .touchUpInside)
        return button
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }

    // MARK: - Configuration
    private func configureUI() {
        view.backgroundColor = UIColor(named: Constants.backgroundColor)
        configureLogo()
        configureTitle()
//        configureCodeInputStackView()
        configureButtons()
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

    private func configureTitle() {
        view.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(
            [
                titleLabel.topAnchor
                    .constraint(
                        equalTo: logoLabel.bottomAnchor,
                        constant: Constants.logoTopConstant
                    ),
                titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
            ]
        )
    }

//    private func configureCodeInputStackView() {
//        view.addSubview(codeInputStackView)
//        codeInputStackView.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            codeInputStackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Constants.stackTopAnchorConstant),
//            codeInputStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
//        ])
//    }

    private func configureButtons() {
        stackView.addArrangedSubview(actionButton)
        stackView.addArrangedSubview(secondaryActionButton)
        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
//            stackView.topAnchor.constraint(equalTo: codeInputStackView.bottomAnchor, constant: 100),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }

    // MARK: - Actions
    @objc
    private func handlePrimaryAction() {
        print("handle confirmation")
    }

    @objc private func resendCode() {
        print("resend code")
    }
}

extension ConfirmationView: UITextFieldDelegate {
    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        guard let text = textField.text else { return false }
        let newLength = text.count + string.count - range.length
        if newLength > 1 {
            return false
        }
        if newLength == 1 {
//            if let nextField = codeInputFields.first(where: { $0 !== textField && $0.text?.isEmpty == true }) {
//                nextField.becomeFirstResponder()
//            }
        } else if newLength == 0 {
//            if let previousField = codeInputFields.last(where: { $0 !== textField && !$0.text!.isEmpty }) {
//                previousField.becomeFirstResponder()
//            }
        }
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text?.isEmpty == true {
//            if let previousField = codeInputFields.first(where: { $0 !== textField && !$0.text!.isEmpty }) {
//                previousField.becomeFirstResponder()
//            }
        }
    }
}
