//
//  SpinnerCell.swift
//  Shop
//
//  Created by Glafira Privalova on 24.12.2019.
//  Copyright © 2019 glaphi. All rights reserved.
//

import Foundation
import UIKit

class SpinnerCell: UITableViewCell, SpinnerShowable {

    override func prepareForReuse() {
        super.prepareForReuse()

        removeSpinner()
    }

    var spinner: UIActivityIndicatorView?

    var spinnersSuperView: UIView { contentView }

}
