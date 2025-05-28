//
//  BookCell.swift
//  VerbiFrontend
//
//  Created by Анастасия Манушкина on 24.01.2025.
//

import UIKit

class BookCell: UICollectionViewCell {
    // MARK: - Constants
    private enum Constants {
        static let fontName: String = "RubikOne-Regular"
        static let fontSize: CGFloat = 10
        static let numberOfLines: Int = 2
        static let imageHeightMultiplier: CGFloat = 0.8
        static let titlePadding: CGFloat = 4
        static let reuseIdentifier: String = "BookCell"
        static let fatalErrorMessage: String = "init(coder:) has not been implemented"
    }

    // MARK: - UI Elements
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: Constants.fontName, size: Constants.fontSize)
        label.textColor = .accent
        label.numberOfLines = Constants.numberOfLines
        label.textAlignment = .left
        return label
    }()

    // MARK: - Properties
    static let reuseIdentifier: String = Constants.reuseIdentifier

    // MARK: - LifeCycle
    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)

        imageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate(
            [
                imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
                imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                imageView.heightAnchor
                    .constraint(
                        equalTo: contentView.heightAnchor,
                        multiplier: Constants.imageHeightMultiplier
                    ),

                titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: Constants.titlePadding),
                titleLabel.leadingAnchor
                    .constraint(
                        equalTo: contentView.leadingAnchor
                    ),
                titleLabel.trailingAnchor
                    .constraint(
                        equalTo: contentView.trailingAnchor
                    ),
                titleLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor)
            ]
        )
    }

    required init?(coder: NSCoder) {
        fatalError(Constants.fatalErrorMessage)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        titleLabel.text = nil
    }

    // MARK: - Configuration
    func configure(with preview: DocumentPreview) {
        imageView.image = preview.image
        titleLabel.text = preview.title
    }
}
