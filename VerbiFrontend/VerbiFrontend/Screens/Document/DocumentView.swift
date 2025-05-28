//
//  DocumentView.swift
//  VerbiFrontend
//
//  Created by Анастасия Манушкина on 27.04.2025.
//

import UIKit
import PDFKit

final class DocumentView: UIViewController {
    // MARK: - Constants
    private enum Constants {
        static let fontName: String = "RubikOne-Regular"
        static let fontSize: CGFloat = 26
        static let backButtonImageName: String = "arrowshape.left.circle"
        static let backgroundColor: String = "backgroundColor"
        static let textFieldHeight: CGFloat = 48
        static let questionTextFieldPadding: CGFloat = 10
        static let spacing: CGFloat = 16
        static let padding: CGFloat = 20
        static let titlePadding: CGFloat = 25
        static let buttonSize: CGFloat = 36
        static let textFieldFontSize: CGFloat = 18
        static let question: String = String(localized: "Question")
        static let rephrase: String = String(localized: "Rephrase")
        static let summarize: String = String(localized: "Summarize")
        static let fatalErrorMessage: String = "init(coder:) has not been implemented"
        static let emptyQuestionError: String = String(
            localized: "This field cannot be empty if you want to ask a question about the fragment"
        )
        static let errorFontSize: CGFloat = 10
        static let menuWidth: CGFloat = 200
        static let menuOptionHeight: CGFloat = 44
    }

    // MARK: - Properties
    private let presenter: DocumentViewOutput
    private let preview: DocumentPreview
    private var activityIndicator: UIActivityIndicatorView?
    private var selectionMenu: UIView?
    private var currentSelectionRect: CGRect = .zero

    // MARK: - CustomPDFView
    private class CustomPDFView: PDFView {
        // MARK: Properties
        var selectionDelegate: ((String, CGRect) -> Void)?

        // MARK: LifeCycle
        override init(frame: CGRect) {
            super.init(frame: frame)
            setup()
        }

        required init?(coder: NSCoder) {
            super.init(coder: coder)
            setup()
        }

        // MARK: Methods
        private func setup() {
            isUserInteractionEnabled = true

            gestureRecognizers?.forEach { recognizer in
                if let longPress = recognizer as? UILongPressGestureRecognizer {
                    longPress.isEnabled = false
                }
            }

            let longPressGestureRecognizer = UILongPressGestureRecognizer(
                target: self,
                action: #selector(handleLongPress(_:))
            )
            addGestureRecognizer(longPressGestureRecognizer)
        }

        // MARK: Actions
        @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
            guard gesture.state == .began else {
                return
            }
            let point = gesture.location(in: self)
            if let page = self.page(for: point, nearest: true) {
                let convertedPoint = self.convert(point, to: page)
                if let selection = page.selectionForWord(at: convertedPoint) {
                    self.currentSelection = selection
                    let pageBounds = selection.bounds(for: page)
                    let viewBounds = convert(pageBounds, from: page)
                    selectionDelegate?(selection.string ?? "", viewBounds)
                }
            }
        }
    }

    // MARK: - UI Elements
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = preview.title
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

    private lazy var questionTextField: VerbiSearchBar = {
        let textField = VerbiSearchBar(placeholder: Constants.question)
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    private let emptyQuestionErrorLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.emptyQuestionError
        label.font = UIFont(name: Constants.fontName, size: Constants.errorFontSize)
        label.textColor = .red
        label.isHidden = true
        return label
    }()

    private lazy var pdfView: CustomPDFView = {
        let view = CustomPDFView()
        view.autoScales = true
        view.displayMode = .singlePage
        view.displayDirection = .horizontal
        view.translatesAutoresizingMaskIntoConstraints = false
        view.selectionDelegate = { [weak self] text, rect in
            self?.showSelectionMenu(with: text, at: rect)
        }
        view.backgroundColor = .clear
        return view
    }()

    private lazy var pageNumberLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: Constants.fontName, size: Constants.textFieldFontSize)
        label.textColor = .accent
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.spacing = Constants.spacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    // MARK: - LifeCycle
    init(presenter: DocumentViewOutput, preview: DocumentPreview) {
        self.presenter = presenter
        self.preview = preview
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError(Constants.fatalErrorMessage)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        presenter.viewDidLoad(preview: preview)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapOutsideMenu))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }

    @objc private func handleTapOutsideMenu(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: view)
        if let menu = selectionMenu,
           !menu.frame.contains(location),
           !currentSelectionRect.contains(location) {
            menu.removeFromSuperview()
            selectionMenu = nil
            pdfView.currentSelection = nil
        }
    }

    @objc private func questionAction() {
        guard let text = pdfView.currentSelection?.string else { return }
        selectionMenu?.removeFromSuperview()
        selectionMenu = nil
        presenter.didSelectText(text, action: .question, question: questionTextField.text)
    }

    @objc private func rephraseAction() {
        guard let text = pdfView.currentSelection?.string else { return }
        selectionMenu?.removeFromSuperview()
        selectionMenu = nil
        presenter.didSelectText(text, action: .rephrase, question: nil)
    }

    @objc private func summarizeAction() {
        guard let text = pdfView.currentSelection?.string else { return }
        selectionMenu?.removeFromSuperview()
        selectionMenu = nil
        presenter.didSelectText(text, action: .summarize, question: nil)
    }

    // MARK: - Configuration
    private func configureUI() {
        navigationItem.hidesBackButton = true
        view.backgroundColor = UIColor(named: Constants.backgroundColor)
        configureBackButton()
        configureTitleLabel()
        configureStack()
        configureActivityIndicator()

        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeLeft.direction = .left
        pdfView.addGestureRecognizer(swipeLeft)
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeRight.direction = .right
        pdfView.addGestureRecognizer(swipeRight)
    }

    private func configureStack() {
        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(
            [
                stackView.topAnchor
                    .constraint(
                        equalTo: titleLabel.bottomAnchor,
                        constant: Constants.spacing
                    ),
                stackView.leadingAnchor
                    .constraint(
                        equalTo: view.leadingAnchor,
                        constant: Constants.padding
                    ),
                stackView.trailingAnchor
                    .constraint(
                        equalTo: view.trailingAnchor,
                        constant: -Constants.padding
                    ),
                stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
            ]
        )

        stackView.addArrangedSubview(questionTextField)
        stackView.addArrangedSubview(emptyQuestionErrorLabel)
        stackView.addArrangedSubview(pdfView)
        stackView.addArrangedSubview(pageNumberLabel)

        emptyQuestionErrorLabel.isHidden = true
    }

    private func configureTitleLabel() {
        view.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor
                .constraint(
                    equalTo: view.safeAreaLayoutGuide.topAnchor,
                    constant: Constants.titlePadding
                ),
            titleLabel.leadingAnchor
                .constraint(
                    equalTo: backButton.trailingAnchor,
                    constant: Constants.spacing
                ),
            titleLabel.trailingAnchor
                .constraint(
                    equalTo: view.trailingAnchor,
                    constant: -Constants.spacing
                )
        ])
    }

    private func configureBackButton() {
        view.addSubview(backButton)

        NSLayoutConstraint.activate([
            backButton.topAnchor
                .constraint(
                    equalTo: view.safeAreaLayoutGuide.topAnchor,
                    constant: Constants.padding
                ),
            backButton.leadingAnchor
                .constraint(
                    equalTo: view.leadingAnchor,
                    constant: Constants.spacing
                ),
            backButton.widthAnchor
                .constraint(
                    equalToConstant: Constants.buttonSize
                ),
            backButton.heightAnchor
                .constraint(
                    equalToConstant: Constants.buttonSize
                )
        ])
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
    @objc private func backButtonTapped() {
        presenter.didTapBackButton()
    }

    @objc private func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        switch gesture.direction {
        case .left:
            pdfView.goToNextPage(nil)
        case .right:
            pdfView.goToPreviousPage(nil)
        default:
            break
        }
        updatePageNumber()
    }

    private func updatePageNumber() {
        guard let doc = pdfView.document, let page = pdfView.currentPage else { return }
        let index = doc.index(for: page) + 1
        pageNumberLabel.text = "\(index)/\(doc.pageCount)"
    }

    func showLoading(_ isLoading: Bool) {
        guard let activityIndicator else { return }
        if isLoading {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
    }
}

// MARK: - DocumentViewInput
extension DocumentView: DocumentViewInput {
    func showError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    func showDocument(_ document: PDFDocument) {
        pdfView.document = document
        updatePageNumber()
    }

    func showLlmResponse(_ response: String) {
        let alert = UIAlertController(
            title: nil,
            message: response,
            preferredStyle: .alert
        )
        alert.addAction(.init(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension DocumentView {
    private func showSelectionMenu(with text: String, at rect: CGRect) {
        selectionMenu?.removeFromSuperview()
        currentSelectionRect = rect

        let menuView = UIView()
        menuView.backgroundColor = .systemBackground
        menuView.layer.cornerRadius = 10
        menuView.layer.shadowColor = UIColor.black.cgColor
        menuView.layer.shadowOpacity = 0.2
        menuView.layer.shadowOffset = CGSize(width: 0, height: 2)
        menuView.layer.shadowRadius = 4

        let options = [
            (Constants.question, #selector(questionAction)),
            (Constants.rephrase, #selector(rephraseAction)),
            (Constants.summarize, #selector(summarizeAction))
        ]

        var previousButton: UIButton?
        for (index, (title, selector)) in options.enumerated() {
            let button = UIButton(type: .system)
            button.setTitle(title, for: .normal)
            button.titleLabel?.font = UIFont(name: Constants.fontName, size: 16)
            button.setTitleColor(.accent, for: .normal)
            button.addTarget(self, action: selector, for: .touchUpInside)
            button.tag = index
            menuView.addSubview(button)

            button.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                button.leadingAnchor.constraint(equalTo: menuView.leadingAnchor, constant: 16),
                button.trailingAnchor.constraint(equalTo: menuView.trailingAnchor, constant: -16),
                button.heightAnchor.constraint(equalToConstant: Constants.menuOptionHeight)
            ])

            if let previous = previousButton {
                button.topAnchor.constraint(equalTo: previous.bottomAnchor).isActive = true
            } else {
                button.topAnchor.constraint(equalTo: menuView.topAnchor).isActive = true
            }

            previousButton = button

            if index < options.count - 1 {
                let separator = UIView()
                separator.backgroundColor = .systemGray4
                menuView.addSubview(separator)

                separator.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    separator.leadingAnchor.constraint(equalTo: menuView.leadingAnchor, constant: 8),
                    separator.trailingAnchor.constraint(equalTo: menuView.trailingAnchor, constant: -8),
                    separator.topAnchor.constraint(equalTo: button.bottomAnchor),
                    separator.heightAnchor.constraint(equalToConstant: 0.5)
                ])
            }
        }

        if let lastButton = previousButton {
            lastButton.bottomAnchor.constraint(equalTo: menuView.bottomAnchor, constant: -8).isActive = true
        }

        view.addSubview(menuView)
        menuView.translatesAutoresizingMaskIntoConstraints = false

        let menuHeight = CGFloat(options.count) * Constants.menuOptionHeight + 16
        let menuYPosition: CGFloat

        if rect.minY - menuHeight - 10 > view.safeAreaInsets.top {
            menuYPosition = rect.minY - menuHeight - 10
        } else {
            menuYPosition = rect.maxY + 10
        }

        NSLayoutConstraint.activate([
            menuView.widthAnchor.constraint(equalToConstant: Constants.menuWidth),
            menuView.heightAnchor.constraint(equalToConstant: menuHeight),
            menuView.centerXAnchor.constraint(equalTo: view.leadingAnchor, constant: rect.midX),
            menuView.topAnchor.constraint(equalTo: view.topAnchor, constant: menuYPosition)
        ])

        selectionMenu = menuView
    }
}
