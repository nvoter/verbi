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
        static let russian: String = "Русский"
        static let english: String = "English"
        static let light: String = String(localized: "Light")
        static let dark: String = String(localized: "Dark")
        static let system: String = String(localized: "System")
        static let cellReuseId: String = "SettingsRowCell"
        static let logout: String = String(localized: "Logout")
        static let deleteAccount: String = String(localized: "Delete account")
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
        static let russianLanguage: Int = 0
        static let lightTheme: Int = 0
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
    private let languages: [String] = [Constants.russian, Constants.english]
    private let themes: [String] = [Constants.light, Constants.dark, Constants.system]
    private let actions: [String] = [Constants.logout, Constants.deleteAccount]
    private var selectedLanguageIndex: Int = Constants.russianLanguage
    private var selectedThemeIndex: Int = Constants.lightTheme

    // MARK: - LifeCycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureTableView()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    // MARK: - Configuration
    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(SettingsRowCell.self, forCellReuseIdentifier: Constants.cellReuseId)
        tableView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(tableView)

        tableView.backgroundColor = .clear

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: topAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
}

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
        return Constants.numberOfSections
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case Constants.languageSection: return languages.count
        case Constants.themeSection: return themes.count
        case Constants.actionsSection: return actions.count
        default: return Constants.defaultNumberOfRowsInSection
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case Constants.languageSection: return Constants.languageSectionTitle
        case Constants.themeSection: return Constants.themeSectionTitle
        default: return nil
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
            cell.configure(with: language, isDestructive: false, isSelected: indexPath.row == selectedLanguageIndex)

        case Constants.themeSection:
            let theme = themes[indexPath.row]
            cell.configure(with: theme, isDestructive: false, isSelected: indexPath.row == selectedThemeIndex)

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
            selectedLanguageIndex = indexPath.row
            tableView.reloadSections([Constants.languageSection], with: .automatic)

        case Constants.themeSection:
            selectedThemeIndex = indexPath.row
            tableView.reloadSections([Constants.themeSection], with: .automatic)

        default:
            break
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }
}
