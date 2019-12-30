//
//  CustomStrings.swift
//  Shop
//
//  Created by Glafira Privalova on 30.12.2019.
//  Copyright © 2019 glaphi. All rights reserved.
//

import Foundation

enum CustomString {

    static let catalogTitle: String = "Catalogue"

    static let priceDescriptionText: String = "Price: "
    static let categoryDescriptionText: String = "Category: "

    static let errorAlertTitle: String = "Error!"
    static let faileToLoadImage: String = "Failed to load image"
    static let faileToLoadCatalogue: String = "Failed to load catalogue"

    static let alertOkButtonTitle: String = "OK"

}

import UIKit

extension UIFont {

    static var customTitleFont: UIFont {
        UIFont.systemFont(ofSize: UIFont.systemFontSize + 2, weight: .bold)
    }

}
