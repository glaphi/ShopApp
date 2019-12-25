//
//  Utils.swift
//  Shop
//
//  Created by Glafira Privalova on 24.12.2019.
//  Copyright © 2019 glaphi. All rights reserved.
//

import Foundation

// MARK: - Type aliases

typealias EmptyBlock = () -> ()
typealias OptionalErrorBlock = (Error?) -> ()

typealias TaskHandler = (URLSessionDataTask) -> ()


// MARK: - Shared JSON decoder

let jsonDecoder = JSONDecoder()


// MARK: - UI Utils

import UIKit

extension CGRect {

    var mid: CGPoint {
        CGPoint(x: minX, y: minY)
    }

}

extension UIViewController {

    func presentConfirmAlert(_ title: String, message: String? = nil, completion: EmptyBlock? = nil) {

        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        if let popOverController = alert.popoverPresentationController {
            popOverController.sourceView = view
            popOverController.sourceRect = CGRect(origin: view.bounds.mid, size: .zero)
            popOverController.permittedArrowDirections = []
        }

        let confirmAction = UIAlertAction(title: "OK", style: .default) { _ in
            completion?()
        }

        alert.addAction(confirmAction)

        present(alert, animated: true, completion: nil)
    }

}

extension UITableViewCell {

    static var reuseID: String { String(describing: self) }

}

extension UIStackView {

    convenience init(
        axis: NSLayoutConstraint.Axis,
        alignment: UIStackView.Alignment = .fill,
        distribution: UIStackView.Distribution = .fill,
        spacing: CGFloat = .leastNormalMagnitude
    ) {
        self.init()

        self.axis = axis
        self.alignment = alignment
        self.distribution = distribution
        self.spacing = spacing
    }

}

