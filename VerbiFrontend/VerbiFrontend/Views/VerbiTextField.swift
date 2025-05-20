//
//  VerbiTextField.swift
//  VerbiFrontend
//
//  Created by Анастасия Манушкина on 21.01.2025.
//

import UIKit

final class VerbiTextField: UITextField {
    // MARK: - Constants
    private enum Constants {
        static let borderWidth: CGFloat = 1
        static let cornerRadius: CGFloat = 8
        static let fontName: String = "RubikOne-Regular"
        static let fontSize: CGFloat = 16
        static let paddingX: CGFloat = 0
        static let paddingY: CGFloat = 0
        static let paddingWidth: CGFloat = 10
        static let height: CGFloat = 48
        static let alpha: CGFloat = 0.5
        static let containerX: CGFloat = 0
        static let containerY: CGFloat = 0
        static let containerWidth: CGFloat = 50
        static let buttonX: CGFloat = 0
        static let buttonY: CGFloat = 0
        static let buttonWidth: CGFloat = 40
        static let secureImage: String = "eye"
        static let nonSecureImage: String = "eye.slash"
        static let editableBorderWidth: CGFloat = 1.5
        static let uneditableBorderWidth: CGFloat = 0
    }

    // MARK: - LifeCycle
    init(
        placeholder: String,
        keyboardType: UIKeyboardType = .default,
        isSecure: Bool = false
    ) {
        super.init(frame: .zero)
        configure(placeholder: placeholder, keyboardType: keyboardType, isSecure: isSecure)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure(placeholder: "", keyboardType: .default, isSecure: false)
    }

    // MARK: - Configuration
    private func configure(
        placeholder: String,
        keyboardType: UIKeyboardType,
        isSecure: Bool
    ) {
        self.borderStyle = .none
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.accent.cgColor
        self.layer.cornerRadius = Constants.cornerRadius
        self.tintColor = .accent
        self.textColor = .accent
        self.font = UIFont(name: Constants.fontName, size: Constants.fontSize)
        self.keyboardType = keyboardType
        self.heightAnchor.constraint(equalToConstant: Constants.height).isActive = true

        let paddingView = UIView(
            frame: CGRect(
                x: Constants.paddingX,
                y: Constants.paddingY,
                width: Constants.paddingWidth,
                height: Constants.height
            )
        )
        self.leftView = paddingView
        self.leftViewMode = .always

        let placeholderAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.accent.withAlphaComponent(Constants.alpha),
            .font: UIFont(
                name: Constants.fontName,
                size: Constants.fontSize
            ) ?? UIFont
                .systemFont(
                    ofSize: Constants.fontSize
                )
        ]
        self.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: placeholderAttributes)

        if isSecure {
            configureSecurityToggle()
        }
    }

    private func configureSecurityToggle() {
        self.isSecureTextEntry = true

        let toggleButton = UIButton(type: .custom)
        toggleButton.setImage(UIImage(systemName: Constants.secureImage), for: .normal)
        toggleButton.setImage(UIImage(systemName: Constants.nonSecureImage), for: .selected)
        toggleButton.tintColor = .accent
        toggleButton.addTarget(self, action: #selector(toggleSecurity), for: .touchUpInside)

        let rightPaddingView = UIView(
            frame: CGRect(
                x: Constants.paddingX,
                y: Constants.paddingY,
                width: Constants.paddingWidth,
                height: Constants.height
            )
        )
        let containerView = UIView(
            frame: CGRect(
                x: Constants.containerX,
                y: Constants.containerY,
                width: Constants.containerWidth,
                height: Constants.height
            )
        )
        toggleButton.frame = CGRect(
            x: Constants.buttonX,
            y: Constants.buttonY,
            width: Constants.buttonWidth,
            height: Constants.height
        )
        containerView.addSubview(toggleButton)
        rightPaddingView.frame.origin.x = toggleButton.frame.maxX
        containerView.addSubview(rightPaddingView)

        self.rightView = containerView
        self.rightViewMode = .always
    }

    // MARK: - Actions
    @objc private func toggleSecurity(_ sender: UIButton) {
        sender.isSelected.toggle()
        self.isSecureTextEntry.toggle()
    }

    func changeBorderStyle(_ isEditingMode: Bool) {
        self.layer.borderColor = isEditingMode ? UIColor.accent.cgColor : UIColor.clear.cgColor
        self.layer.borderWidth = isEditingMode ? Constants.editableBorderWidth : Constants.uneditableBorderWidth
    }
}
