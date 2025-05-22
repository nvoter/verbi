//
//  SettingsRowCell.swift
//  VerbiFrontend
//
//  Created by Анастасия Манушкина on 29.01.2025.
//

import UIKit

final class SettingsRowCell: UITableViewCell {
    // MARK: - Constants
    private enum Constants {
        static let fontName: String = "RubikOne-Regular"
        static let fontSize: CGFloat = 16
        static let fatalErrorMessage: String = "init(coder:) has not been implemented"
        static let destructiveButtonColor: String = "destructiveButtonColor"
        static let checkmarkTintColor: String = "accent"
    }

    // MARK: - LifeCycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureUI()
    }

    required init?(coder: NSCoder) {
        fatalError(Constants.fatalErrorMessage)
    }

    // MARK: - Configuration
    private func configureUI() {
        backgroundColor = .clear
        textLabel?.font = UIFont(name: Constants.fontName, size: Constants.fontSize)
        textLabel?.textColor = .accent
        tintColor = UIColor(named: Constants.checkmarkTintColor)
        selectionStyle = .none
    }

    func configure(with title: String, isDestructive: Bool = false, isSelected: Bool = false) {
        textLabel?.text = title
        textLabel?.textColor = isDestructive ? UIColor(named: Constants.destructiveButtonColor) : .accent
        accessoryType = isSelected ? .checkmark : .none
    }
}
