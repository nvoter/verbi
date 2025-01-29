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
        static let setPhotoButtonImageName: String = "camera.circle"
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
        static let navigationButtonsSize: CGFloat = 100
        static let navigationButtonsCornerRadius: CGFloat = 50
        static let textFieldFontSize: CGFloat = 18
        static let alpha: CGFloat = 0.5
        static let dividerHeight: CGFloat = 1
        static let animationDuration: TimeInterval = 0.3
        static let textFieldPadding: CGFloat = 10
    }

    // MARK: - UI Elements
    private lazy var profileImageView: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: Constants.setPhotoButtonImageName), for: .normal)
        button.tintColor = .accent
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        button.addTarget(self, action: #selector(handleUploadPhoto), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant: Constants.navigationButtonsSize).isActive = true
        button.heightAnchor.constraint(equalToConstant: Constants.navigationButtonsSize).isActive = true
        button.layer.cornerRadius = Constants.navigationButtonsCornerRadius
        return button
    }()

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
        let stackView = UIStackView(arrangedSubviews: [profileImageView, usernameTextField, emailTextField, divider])
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
    private var isEditingMode: Bool = false

    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
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

    private func configureTitleLabel() {
        view.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
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
            profileStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        NSLayoutConstraint.activate([
            divider.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            divider.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            divider.heightAnchor.constraint(equalToConstant: Constants.dividerHeight)
        ])

        NSLayoutConstraint
            .activate(
                [
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
                ]
            )
    }

    private func configureSettingsView() {
        view.addSubview(settingsView)

        NSLayoutConstraint.activate(
            [
                settingsView.topAnchor.constraint(equalTo: profileStackView.bottomAnchor, constant: Constants.spacing),
                settingsView.bottomAnchor
                    .constraint(
                        equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                        constant: -Constants.spacing
                    ),
                settingsView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                settingsView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            ]
        )
    }

    // MARK: - Actions
    @objc private func backButtonTapped() {
        print("handle back button tap")
    }

    @objc private func handleUploadPhoto() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }

    @objc private func handleEditProfile() {
        isEditingMode.toggle()
        usernameTextField.isEnabled = isEditingMode
        emailTextField.isEnabled = isEditingMode
        editButton.isHidden = isEditingMode
        saveButton.isHidden = !isEditingMode

        UIView.animate(withDuration: Constants.animationDuration) { [self] in
            self.usernameTextField.changeBorderStyle(self.isEditingMode)
            self.emailTextField.changeBorderStyle(self.isEditingMode)
        }
    }

    @objc private func saveProfileChanges() {
        handleEditProfile()
    }
}

extension AccountView: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        if let image = info[.originalImage] as? UIImage {
            profileImageView.setImage(image, for: .normal)
        }
        picker.dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
