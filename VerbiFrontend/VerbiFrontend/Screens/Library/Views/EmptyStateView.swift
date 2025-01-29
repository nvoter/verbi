//
//  EmptyStateView.swift
//  VerbiFrontend
//
//  Created by Анастасия Манушкина on 24.01.2025.
//

import UIKit

final class EmptyStateView: UIView {
    // MARK: - Constants
    private enum Constants {
        static let fontName: String = "RubikOne-Regular"
        static let imageName: String = "telescope"
        static let title: String = String(localized: "Files not found")
        static let buttonTitle: String = String(localized: "Upload")
        static let fontSize: CGFloat = 24
        static let buttonFontSize: CGFloat = 20
        static let buttonImageName: String = "plus.circle"
        static let spacing: CGFloat = 16
    }

    // MARK: - UI Elements
    lazy var button: UIButton = {
        let button = UIButton(type: .system)
        let title = NSAttributedString(
            string: Constants.buttonTitle,
            attributes: [
                .font: UIFont(
                    name: Constants.fontName,
                    size: Constants.buttonFontSize
                ) as Any,
                .foregroundColor: UIColor.accent,
                .underlineStyle: NSUnderlineStyle.single.rawValue
            ]
        )
        button.setAttributedTitle(title, for: .normal)
        button.setImage(UIImage(systemName: Constants.buttonImageName), for: .normal)
        button.semanticContentAttribute = .forceRightToLeft
        return button
    }()

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: Constants.imageName))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var label: UILabel = {
        let label = UILabel()
        label.text = Constants.title
        label.textColor = .accent
        label.font = UIFont(name: Constants.fontName, size: Constants.fontSize)
        label.textAlignment = .center
        return label
    }()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [imageView, label, button])
        stackView.axis = .vertical
        stackView.spacing = Constants.spacing
        stackView.alignment = .center
        return stackView
    }()

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
        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            stackView.leadingAnchor.constraint(greaterThanOrEqualTo: self.leadingAnchor),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: self.trailingAnchor)
        ])
    }
}
