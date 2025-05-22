//
//  SettingsView.swift
//  VerbiFrontend
//
//  Created by Анастасия Манушкина on 28.01.2025.
//

import UIKit

final class SettingsView: UIView {
    // MARK: - Constants
    private enum Constants {
        static let fontName: String = "RubikOne-Regular"
        static let fontSize: CGFloat = 16
        static let cellReuseId: String = "SettingsRowCell"
        static let logoutTitle: String = String(localized: "Logout")
        static let deleteAccountTitle: String = String(localized: "Delete account")
        static let languageSection: Int = 0
        static let themeSection: Int = 1
        static let actionsSection: Int = 2
        static let numberOfSections: Int = 3
        static let languageSectionTitle: String = String(localized: "Language").uppercased()
        static let themeSectionTitle: String = String(localized: "Theme").uppercased()
        static let fatalErrorMessage: String = "init(coder:) has not been implemented"
        static let alpha: CGFloat = 0.5
        static let headerFontSize: CGFloat = 14
        static let backgroundColor: String = "backgroundColor"
        static let headerFrameX: CGFloat = 17
        static let headerFrameY: CGFloat = 0
        static let headerWidthPadding: CGFloat = 32
        static let headerHeight: CGFloat = 20
        static let defaultNumberOfRowsInSection: Int = 0
        static let heightForFooter: CGFloat = 0
    }

    // MARK: - UI Elements
    private lazy var tableView = UITableView(frame: .zero, style: .plain)

    // MARK: - Properties
    var onThemeSelected: ((AppTheme) -> Void)?
    var onLanguageSelected: ((AppLanguage) -> Void)?
    var onLogout: (() -> Void)?
    var onDeleteAccount: (() -> Void)?
    private let languages = AppLanguage.allCases
    private let themes = AppTheme.allCases
    private let actions = [Constants.logoutTitle, Constants.deleteAccountTitle]
    private var selectedLanguageIndex: Int = 0
    private var selectedThemeIndex: Int = 0

    // MARK: - LifeCycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureTableView()
        setupInitialSelections()
    }

    required init?(coder: NSCoder) {
        fatalError(Constants.fatalErrorMessage)
    }

    // MARK: - Configuration
    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(SettingsRowCell.self, forCellReuseIdentifier: Constants.cellReuseId)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none

        addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: topAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }

    private func setupInitialSelections() {
        let currentTheme = UserDefaultsService.shared.getTheme()
        selectedThemeIndex = AppTheme.allCases.firstIndex { $0.rawValue == currentTheme.rawValue } ?? 0

        let currentLanguage = UserDefaultsService.shared.getLanguage()
        selectedLanguageIndex = AppLanguage.allCases.firstIndex { $0.rawValue == currentLanguage.rawValue } ?? 0
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension SettingsView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerLabel = UILabel()
        headerLabel.backgroundColor = UIColor(named: Constants.backgroundColor)
        headerLabel.font = UIFont(name: Constants.fontName, size: Constants.headerFontSize)
        headerLabel.textColor = .accent.withAlphaComponent(Constants.alpha)
        headerLabel.textAlignment = .left
        headerLabel.frame = CGRect(
            x: Constants.headerFrameX,
            y: Constants.headerFrameY,
            width: tableView.bounds.width - Constants.headerWidthPadding,
            height: Constants.headerHeight
        )

        switch section {
        case Constants.languageSection:
            headerLabel.text = Constants.languageSectionTitle
        case Constants.themeSection:
            headerLabel.text = Constants.themeSectionTitle
        default:
            headerLabel.text = nil
        }

        let containerView = UIView()
        containerView.addSubview(headerLabel)
        return containerView
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        Constants.numberOfSections
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case Constants.languageSection: return languages.count
        case Constants.themeSection: return themes.count
        case Constants.actionsSection: return actions.count
        default: return Constants.defaultNumberOfRowsInSection
        }
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        Constants.heightForFooter
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == Constants.themeSection {
            let footerView = UIView()
            footerView.backgroundColor = .clear
            return footerView
        }
        return nil
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: Constants.cellReuseId,
            for: indexPath
        ) as? SettingsRowCell else {
            return UITableViewCell()
        }

        switch indexPath.section {
        case Constants.languageSection:
            let language = languages[indexPath.row]
            cell
                .configure(
                    with: language.localizedTitle,
                    isDestructive: false,
                    isSelected: indexPath.row == selectedLanguageIndex
                )

        case Constants.themeSection:
            let theme = themes[indexPath.row]
            cell
                .configure(
                    with: theme.localizedTitle,
                    isDestructive: false,
                    isSelected: indexPath.row == selectedThemeIndex
                )

        case Constants.actionsSection:
            let action = actions[indexPath.row]
            cell.configure(with: action, isDestructive: true, isSelected: false)

        default:
            break
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case Constants.languageSection:
            let language = languages[indexPath.row]
            selectedLanguageIndex = indexPath.row
            tableView.reloadSections([Constants.languageSection], with: .automatic)
            onLanguageSelected?(language)

        case Constants.themeSection:
            let theme = themes[indexPath.row]
            selectedThemeIndex = indexPath.row
            tableView.reloadSections([Constants.themeSection], with: .automatic)
            onThemeSelected?(theme)

        case Constants.actionsSection:
            switch indexPath.row {
            case 0: onLogout?()
            case 1: onDeleteAccount?()
            default: break
            }

        default:
            break
        }
    }
}
