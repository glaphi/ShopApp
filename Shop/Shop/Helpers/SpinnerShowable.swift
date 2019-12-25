//
//  SpinnerShowable.swift
//  Shop
//
//  Created by Glafira Privalova on 25.12.2019.
//  Copyright © 2019 glaphi. All rights reserved.
//

import Foundation
import UIKit

protocol SpinnerShowable: AnyObject {

    var spinner: UIActivityIndicatorView? { get set }

    var spinnersSuperView: UIView { get }

    func startSpinning()

    func removeSpinner()
}

extension SpinnerShowable {

    func startSpinning() {
        let spinner = UIActivityIndicatorView(style: .medium)

        spinnersSuperView.addSubview(spinner)

        spinner.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            spinner.centerYAnchor.constraint(equalTo: spinnersSuperView.centerYAnchor),
            spinner.centerXAnchor.constraint(equalTo: spinnersSuperView.centerXAnchor),
        ])

        spinner.startAnimating()

        self.spinner = spinner
    }

    func removeSpinner() {
        spinner?.removeFromSuperview()
        spinner = nil
    }

}
