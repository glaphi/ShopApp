//
//  ItemCell.swift
//  Shop
//
//  Created by Glafira Privalova on 24.12.2019.
//  Copyright © 2019 glaphi. All rights reserved.
//

import Foundation
import UIKit

class ImagedItemCell: UITableViewCell, SpinnerShowable {

    required init?(coder: NSCoder) { nil }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: ImagedItemCell.reuseID)

        let mainStack = UIStackView.init(axis: .vertical, alignment: .center, distribution: .fill, spacing: 20)
        let priceStack = UIStackView.init(axis: .horizontal, alignment: .center, distribution: .fillEqually)

        descriptionLabel.numberOfLines = 0

        [priceLabel, categoryLabel].forEach { priceStack.addArrangedSubview($0) }

        [titleLabel, pictureView, priceStack, descriptionLabel].forEach { mainStack.addArrangedSubview($0) }

        contentView.addSubview(mainStack)

        pictureView.translatesAutoresizingMaskIntoConstraints = false
        mainStack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            mainStack.rightAnchor.constraint(equalTo: contentView.layoutMarginsGuide.rightAnchor),
            mainStack.leftAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leftAnchor),
            mainStack.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),

            pictureView.widthAnchor.constraint(equalTo: contentView.layoutMarginsGuide.widthAnchor),
            pictureView.heightAnchor.constraint(equalTo: pictureView.widthAnchor),
        ])

        startSpinning()
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        pictureView.image = nil
        removeSpinner()
        startSpinning()
        update(id: nil, title: "---", description: "", price: "", category: "")
    }

    func update(id: String?, title: String, description: String, price: String, category: String) {
        self.id = id

        titleLabel.text = title
        descriptionLabel.text = description

        priceLabel.attributedText = attributedText(description: "Price: ", text: price)

        categoryLabel.attributedText = attributedText(description: "Category: ", text: category)
    }

    func update(id: String, image: UIImage?) {
        guard id == self.id else { return }

        pictureView.image = image
        removeSpinner()
    }

    // MARK: - Private

    private var id: String?

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: UIFont.systemFontSize + 2, weight: .bold)
        return label
    }()

    private lazy var descriptionLabel = UILabel()
    private lazy var priceLabel = UILabel()
    private lazy var categoryLabel = UILabel()
    private lazy var pictureView = UIImageView()

    private func attributedText(description: String, text: String) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(
            string: description,
            attributes: [NSAttributedString.Key.foregroundColor : UIColor.placeholderText]
        )
        attributedString.append(NSAttributedString(string: text))

        return attributedString
    }

    // MARK: - SpinnerShowable

    var spinnersSuperView: UIView {
        pictureView
    }

    var spinner: UIActivityIndicatorView?
}

