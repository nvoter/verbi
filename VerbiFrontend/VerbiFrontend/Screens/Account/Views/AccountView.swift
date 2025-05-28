//
//  AccountView.swift
//  VerbiFrontend
//
//  Created by Анастасия Манушкина on 25.01.2025.
//

import UIKit

final class AccountView: UIViewController {
    // MARK: - Constants
    private enum Constants {
        static let title: String = String(localized: "Account")
        static let fontName: String = "RubikOne-Regular"
        static let fontSize: CGFloat = 26
        static let backButtonImageName: String = "arrowshape.left.circle"
        static let editButtonImageName: String = "pencil.circle"
        static let saveButtonImageName: String = "checkmark.circle"
        static let backgroundColor: String = "backgroundColor"
        static let usernamePlaceholder: String = String(localized: "username")
        static let emailPlaceholder: String = "email"
        static let textFieldHeight: CGFloat = 30
        static let spacing: CGFloat = 16
        static let padding: CGFloat = 20
        static let titlePadding: CGFloat = 25
        static let buttonSize: CGFloat = 36
        static let textFieldFontSize: CGFloat = 18
        static let alpha: CGFloat = 0.5
        static let dividerHeight: CGFloat = 1
        static let animationDuration: TimeInterval = 0.3
        static let textFieldPadding: CGFloat = 10
        static let fatalErrorMessage: String = "init(coder:) has not been implemented"
        static let errorTitle: String = String(localized: "Error")
        static let okButtonTitle: String = String(localized: "OK")
    }

    // MARK: - UI Elements
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.title
        label.font = UIFont(name: Constants.fontName, size: Constants.fontSize)
        label.textColor = .accent
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: Constants.backButtonImageName), for: .normal)
        button.tintColor = .accent
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        button.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var editButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: Constants.editButtonImageName), for: .normal)
        button.tintColor = .accent
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        button.addTarget(self, action: #selector(handleEditProfile), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: Constants.saveButtonImageName), for: .normal)
        button.tintColor = .accent
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        button.isHidden = true
        button.addTarget(self, action: #selector(saveProfileChanges), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var usernameTextField: VerbiTextField = {
        let textField = VerbiTextField(placeholder: Constants.usernamePlaceholder)
        textField.borderStyle = .none
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.heightAnchor.constraint(equalToConstant: Constants.textFieldHeight).isActive = true
        textField.isEnabled = false
        textField.changeBorderStyle(false)
        return textField
    }()

    private lazy var emailTextField: VerbiTextField = {
        let textField = VerbiTextField(placeholder: Constants.emailPlaceholder)
        textField.borderStyle = .none
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.heightAnchor.constraint(equalToConstant: Constants.textFieldHeight).isActive = true
        textField.isEnabled = false
        textField.changeBorderStyle(false)
        return textField
    }()

    private lazy var divider: UIView = {
        let view = UIView()
        view.backgroundColor = .accent.withAlphaComponent(Constants.alpha)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var profileStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [usernameTextField, emailTextField, divider])
        stackView.axis = .vertical
        stackView.spacing = Constants.spacing
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private lazy var settingsView: UIView = {
        let view = SettingsView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // MARK: - Properties
    private let presenter: AccountViewOutput
    private var isEditingMode: Bool = false

    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        presenter.viewDidLoad()
    }

    init(presenter: AccountViewOutput) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError(Constants.fatalErrorMessage)
    }

    // MARK: - Configuration
    private func configureUI() {
        self.navigationItem.hidesBackButton = true
        view.backgroundColor = UIColor(named: Constants.backgroundColor)
        configureTitleLabel()
        configureBackButton()
        configureEditButton()
        configureProfileStackView()
        configureSettingsView()
    }

    private func configureSettingsView() {
        guard let settingsView = settingsView as? SettingsView else { return }
        view.addSubview(settingsView)

        NSLayoutConstraint.activate([
            settingsView.topAnchor.constraint(equalTo: profileStackView.bottomAnchor, constant: Constants.spacing),
            settingsView.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -Constants.spacing
            ),
            settingsView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            settingsView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        settingsView.onThemeSelected = { [weak self] theme in
            self?.presenter.didSelectTheme(theme)
        }

        settingsView.onLanguageSelected = { [weak self] language in
            self?.presenter.didSelectLanguage(language)
        }

        settingsView.onLogout = { [weak self] in
            self?.presenter.didTapLogout()
        }

        settingsView.onDeleteAccount = { [weak self] in
            self?.presenter.didTapDeleteAccount()
        }
    }

    private func configureTitleLabel() {
        view.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: Constants.titlePadding
            ),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.spacing),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.spacing)
        ])
    }

    private func configureBackButton() {
        view.addSubview(backButton)
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.padding),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.spacing),
            backButton.widthAnchor.constraint(equalToConstant: Constants.buttonSize),
            backButton.heightAnchor.constraint(equalToConstant: Constants.buttonSize)
        ])
    }

    private func configureEditButton() {
        view.addSubview(editButton)
        view.addSubview(saveButton)

        NSLayoutConstraint.activate([
            editButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.padding),
            editButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.spacing),
            editButton.widthAnchor.constraint(equalToConstant: Constants.buttonSize),
            editButton.heightAnchor.constraint(equalToConstant: Constants.buttonSize),

            saveButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.padding),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.spacing),
            saveButton.widthAnchor.constraint(equalToConstant: Constants.buttonSize),
            saveButton.heightAnchor.constraint(equalToConstant: Constants.buttonSize)
        ])
    }

    private func configureProfileStackView() {
        view.addSubview(profileStackView)

        NSLayoutConstraint.activate([
            profileStackView.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: Constants.spacing),
            profileStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            profileStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            divider.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            divider.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            divider.heightAnchor.constraint(equalToConstant: Constants.dividerHeight),

            usernameTextField.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: Constants.textFieldPadding
            ),
            usernameTextField.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -Constants.textFieldPadding
            ),

            emailTextField.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: Constants.textFieldPadding
            ),
            emailTextField.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -Constants.textFieldPadding
            )
        ])
    }

    // MARK: - Actions
    @objc private func saveProfileChanges() {
        guard let username = usernameTextField.text, !username.isEmpty else {
            showError("Username cannot be empty")
            return
        }
        guard let email = emailTextField.text, !email.isEmpty else {
            return
        }
        presenter.didTapSaveProfile(username: username, email: email)
    }

    @objc private func backButtonTapped() {
        presenter.didTapBackButton()
        navigationController?.popViewController(animated: true)
    }

    @objc private func handleEditProfile() {
        presenter.didTapEditProfile()
    }
}

// MARK: - AccountViewInput
extension AccountView: AccountViewInput {
    func showError(_ message: String) {
        let alert = UIAlertController(
            title: Constants.errorTitle,
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: Constants.okButtonTitle, style: .default))
        present(alert, animated: true)
    }

    func showThemeChange() {
        NotificationCenter.default.post(name: .themeChanged, object: nil)
    }

    func showLanguageChange() {
        NotificationCenter.default.post(name: .languageChanged, object: nil)
    }

    func updateUserInfo(username: String, email: String) {
        usernameTextField.text = username
        emailTextField.text = email
    }

    func setEditingMode(_ isEditing: Bool) {
        isEditingMode = isEditing
        usernameTextField.isEnabled = isEditing
        editButton.isHidden = isEditing
        saveButton.isHidden = !isEditing

        UIView.animate(withDuration: Constants.animationDuration) {
            self.usernameTextField.changeBorderStyle(self.isEditingMode)
        }
    }
}

extension Notification.Name {
    static let themeChanged = Notification.Name("ThemeChangedNotification")
    static let languageChanged = Notification.Name("LanguageChangedNotification")
}
