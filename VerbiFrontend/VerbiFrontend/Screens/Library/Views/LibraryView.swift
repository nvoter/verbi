//
//  LibraryView.swift
//  VerbiFrontend
//
//  Created by Анастасия Манушкина on 22.01.2025.
//

import UIKit

final class LibraryView: UIViewController {
    // MARK: - Constants
    private enum Constants {
        static let backgroundColor: String = "backgroundColor"
        static let fontName: String = "RubikOne-Regular"
        static let fontSize: CGFloat = 26
        static let title: String = String(localized: "Library")
        static let padding: CGFloat = 20
        static let searchBarHeight: CGFloat = 48
        static let searchBarPadding: CGFloat = 10
        static let collectionViewPadding: CGFloat = 16
        static let spacing: CGFloat = 16
        static let uploadButtonImageName: String = "plus.circle"
        static let profileButtonImageName: String = "person.circle"
        static let navButtonsSize: CGFloat = 36
        static let itemsInRow: CGFloat = 3
        static let numberOfIndents: CGFloat = 2
        static let heightToWidthRatio: CGFloat = 1.5
        static let fatalErrorMessage: String = "init(coder:) has not been implemented"
    }

    // MARK: - UI Elements
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.title
        label.font = UIFont(name: Constants.fontName, size: Constants.fontSize)
        label.textColor = .accent
        label.textAlignment = .left
        return label
    }()

    private lazy var uploadButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: Constants.uploadButtonImageName), for: .normal)
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        button.tintColor = .accent
        button.addTarget(self, action: #selector(handleUpload), for: .touchUpInside)
        return button
    }()

    private lazy var profileButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: Constants.profileButtonImageName), for: .normal)
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        button.tintColor = .accent
        button.addTarget(self, action: #selector(handleProfile), for: .touchUpInside)
        return button
    }()

    private lazy var searchBar: VerbiSearchBar = VerbiSearchBar()

    private lazy var emptyStateView: EmptyStateView = {
        let view = EmptyStateView()
        view.button.addTarget(self, action: #selector(handleUpload), for: .touchUpInside)
        return view
    }()

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical

        let itemWidth = calculateItemWidth(for: UIScreen.main.bounds.width)

        layout.itemSize = CGSize(width: itemWidth, height: itemWidth * Constants.heightToWidthRatio)
        layout.sectionInset = UIEdgeInsets(
            top: Constants.spacing,
            left: Constants.spacing,
            bottom: Constants.spacing,
            right: Constants.spacing
        )
        layout.minimumLineSpacing = Constants.spacing
        layout.minimumInteritemSpacing = Constants.spacing
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()

    // MARK: - Properties
    private let presenter: LibraryViewOutput
    private var previews: [DocumentPreview] = []
    var activityIndicator: UIActivityIndicatorView?
    private var isEmpty = true {
        didSet {
            configureView()
        }
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        presenter.viewDidLoad()
    }

    init(presenter: LibraryViewOutput) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError(Constants.fatalErrorMessage)
    }

    // MARK: - Configuration
    private func configureUI() {
        view.backgroundColor = UIColor(named: Constants.backgroundColor)
        configureTitleLabel()
        configureNavigationButtons()
        configureSearchBar()
        configureEmptyStateView()
        configureCollectionView()
        configureView()
        configureActivityIndicator()
    }

    private func configureTitleLabel() {
        view.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.padding),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.spacing),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.spacing)
        ])
    }

    private func configureNavigationButtons() {
        view.addSubview(uploadButton)
        view.addSubview(profileButton)

        uploadButton.translatesAutoresizingMaskIntoConstraints = false
        profileButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint
            .activate(
                [
                    profileButton.topAnchor.constraint(
                        equalTo: view.safeAreaLayoutGuide.topAnchor,
                        constant: Constants.padding
                    ),
                    profileButton.widthAnchor.constraint(
                        equalToConstant: Constants.navButtonsSize
                    ),
                    profileButton.heightAnchor.constraint(
                        equalToConstant: Constants.navButtonsSize
                    ),
                    profileButton.trailingAnchor.constraint(
                        equalTo: view.trailingAnchor,
                        constant: -Constants.spacing
                    ),
                    uploadButton.topAnchor.constraint(
                        equalTo: view.safeAreaLayoutGuide.topAnchor,
                        constant: Constants.padding
                    ),
                    uploadButton.widthAnchor.constraint(
                        equalToConstant: Constants.navButtonsSize
                    ),
                    uploadButton.heightAnchor.constraint(
                        equalToConstant: Constants.navButtonsSize
                    ),
                    uploadButton.trailingAnchor.constraint(
                        equalTo: profileButton.leadingAnchor
                    )
                ]
            )
    }

    private func configureSearchBar() {
        view.addSubview(searchBar)
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Constants.searchBarPadding),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.searchBarPadding),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.searchBarPadding),
            searchBar.heightAnchor.constraint(equalToConstant: Constants.searchBarHeight)
        ])
    }

    private func configureEmptyStateView() {
        view.addSubview(emptyStateView)
        emptyStateView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            emptyStateView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emptyStateView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    private func configureCollectionView() {
        view.addSubview(collectionView)
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(BookCell.self, forCellWithReuseIdentifier: BookCell.reuseIdentifier)
    }

    private func configureView() {
        emptyStateView.isHidden = !isEmpty
        collectionView.isHidden = isEmpty
    }

    private func configureActivityIndicator() {
        activityIndicator = UIActivityIndicatorView(style: .large)
        guard let activityIndicator else { return }
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = .accent
        view.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    // MARK: - Actions
    @objc private func handleUpload() {
        presenter.didTapAddButton()
    }

    @objc private func handleProfile() {
        presenter.didTapAccountButton()
    }

    private func calculateItemWidth(for screenWidth: CGFloat) -> CGFloat {
        let totalSpacing = Constants.spacing * (
            Constants.itemsInRow - 1
        ) + Constants.spacing * Constants.numberOfIndents
        return floor((screenWidth - totalSpacing) / Constants.itemsInRow)
    }

    func presentDocumentPicker() {
        let picker = UIDocumentPickerViewController(
            forOpeningContentTypes: [.pdf, .epub],
            asCopy: true
        )
        picker.delegate = self
        picker.allowsMultipleSelection = false
        present(picker, animated: true)
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension LibraryView: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return previews.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: BookCell.reuseIdentifier,
            for: indexPath
        ) as? BookCell else {
            return UICollectionViewCell()
        }
        let book = previews[indexPath.row]
        cell.configure(with: book)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        presenter.didSelectItem(at: indexPath)
    }
}

// MARK: - LibraryViewInput
extension LibraryView: LibraryViewInput {
    func reloadData() {
        collectionView.reloadData()
    }

    func showError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(.init(title: "OK", style: .default))
        present(alert, animated: true)
    }

    func showEmptyState() {
        isEmpty = true
    }

    func showDocuments(_ previews: [DocumentPreview]) {
        self.previews = previews
        isEmpty = false
    }

    func showLoading(_ isLoading: Bool) {
        guard let activityIndicator else { return }
        if isLoading {
            isEmpty = false
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
    }
}

extension LibraryView: UIDocumentPickerDelegate {
    func documentPicker(_ picker: UIDocumentPickerViewController,
                        didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else { return }
        presenter.didPickDocument(url: url)
    }
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        return
    }
}
