//
//  VerbiSearchBar.swift
//  VerbiFrontend
//
//  Created by Анастасия Манушкина on 24.01.2025.
//

import UIKit

final class VerbiSearchBar: UISearchBar {
    // MARK: - Constants
    private enum Constants {
        static let placeholder: String = String(localized: "Search")
        static let fontName: String = "RubikOne-Regular"
        static let fontSize: CGFloat = 18
        static let borderWidth: CGFloat = 2
        static let cornerRadius: CGFloat = 8
        static let alpha: CGFloat = 0.5
        static let clearButtonKey: String = "clearButton"
    }

    // MARK: - LifeCycle
    init() {
        super.init(frame: .zero)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configuration
    private func configure() {
        self.placeholder = Constants.placeholder
        self.tintColor = .accent
        self.searchBarStyle = .minimal

        self.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
        self.setSearchFieldBackgroundImage(UIImage(), for: .normal)

        let textField = self.searchTextField
        textField.font = UIFont(name: Constants.fontName, size: Constants.fontSize)
        textField.textColor = .accent
        textField.attributedPlaceholder = NSAttributedString(
            string: Constants.placeholder,
            attributes: [
                .foregroundColor: UIColor.accent.withAlphaComponent(Constants.alpha)
            ]
        )

        textField.backgroundColor = .clear

        textField.layer.borderColor = UIColor.accent.cgColor
        textField.layer.borderWidth = Constants.borderWidth
        textField.layer.cornerRadius = Constants.cornerRadius

        if let clearButton = textField.value(forKey: Constants.clearButtonKey) as? UIButton {
            clearButton.tintColor = UIColor.accent
            clearButton.setImage(
                clearButton.imageView?.image?.withRenderingMode(.alwaysTemplate),
                for: .normal
            )
        }

        if let iconView = textField.leftView as? UIImageView {
            iconView.tintColor = .accent
        }
    }
}
