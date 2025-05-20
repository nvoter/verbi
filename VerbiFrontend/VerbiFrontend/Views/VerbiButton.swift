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

    // MARK: - Properties
    var isPrimary: Bool = false
    var title: String?
    var activityIndicator: UIActivityIndicatorView?

    var isLoading: Bool = false {
        didSet {
            updateLoadingState()
        }
    }

    // MARK: - LifeCycle
    init(title: String, isPrimary: Bool = false) {
        super.init(frame: .zero)
        self.isPrimary = isPrimary
        configure(title: title, isPrimary: isPrimary)
        if isPrimary {
            setupActivityIndicator()
        }
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }

    // MARK: - Configuration
    private func configure(title: String = "", isPrimary: Bool = false) {
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

    private func setupActivityIndicator() {
        activityIndicator = UIActivityIndicatorView(style: .medium)
        guard let activityIndicator else { return }
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = .white
        addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    private func updateLoadingState() {
        guard let activityIndicator else { return }
        if isLoading {
            title = self.title(for: .normal)
            setTitle(nil, for: .normal)
            activityIndicator.startAnimating()
            isEnabled = false
        } else {
            setTitle(title, for: .normal)
            activityIndicator.stopAnimating()
            isEnabled = true
        }
    }
}
