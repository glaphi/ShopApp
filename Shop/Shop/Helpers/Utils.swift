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


// MARK: - Shared

let jsonDecoder: JSONDecoder = JSONDecoder()

var backgroundTasksStore: [Int: UIBackgroundTaskIdentifier] = [:]

var padding: CGFloat = 20

// MARK: - UI Utils

import UIKit

extension CGRect {

    var mid: CGPoint {
        CGPoint(x: minX, y: minY)
    }

}

extension UIViewController {

    /// Present alert with specified title and message. Alert will have one acknowledgement button to dismiss
    /// - Parameters:
    ///   - title: alert's title
    ///   - message: alert's message
    ///   - completion: completion once the "OK" button is tapped
    func presentConfirmAlert(_ title: String, message: String? = nil, completion: EmptyBlock? = nil) {

        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        // Add centering for iPad

        if let popOverController = alert.popoverPresentationController {
            popOverController.sourceView = view
            popOverController.sourceRect = CGRect(origin: view.bounds.mid, size: .zero)
            popOverController.permittedArrowDirections = []
        }

        let confirmAction = UIAlertAction(title: CustomString.alertOkButtonTitle, style: .default) { _ in
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

    /// Initialize stack with axis, alignment, distribution and spacing
    /// - Parameters:
    ///   - axis: stack's axis
    ///   - alignment: alignment defauls to fill
    ///   - distribution: distribution defaults to fill
    ///   - spacing: spacing defaults to least normal magnitude
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

