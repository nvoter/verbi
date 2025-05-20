//
//  VerbiButton.swift
//  VerbiFrontend
//
//  Created by Анастасия Манушкина on 21.01.2025.
//

import UIKit

final class VerbiButton: UIButton {
    // MARK: - Constants
    private enum Constants {
        static let fontName: String = "RubikOne-Regular"
        static let fontSize: CGFloat = 16
        static let cornerRadius: CGFloat = 10
        static let primaryHeight: CGFloat = 48
        static let secondaryHeight: CGFloat = 20
    }

    // MARK: - LifeCycle
    init(title: String, isPrimary: Bool = false) {
        super.init(frame: .zero)
        configure(title: title, isPrimary: isPrimary)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure(title: "", isPrimary: false)
    }

    // MARK: - Configuration
    private func configure(title: String, isPrimary: Bool) {
        self.setTitle(title, for: .normal)
        self.setTitleColor(isPrimary ? .white : .accent, for: .normal)
        self.backgroundColor = isPrimary ? .accent : .clear
        self.titleLabel?.font = UIFont(name: Constants.fontName, size: Constants.fontSize)
        self.layer.cornerRadius = Constants.cornerRadius
        self.heightAnchor
            .constraint(
                equalToConstant: isPrimary ? Constants.primaryHeight : Constants.secondaryHeight
            ).isActive = true
    }
}
