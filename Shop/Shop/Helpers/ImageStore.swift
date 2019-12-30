//
//  ImageStore.swift
//  Shop
//
//  Created by Glafira Privalova on 30.12.2019.
//  Copyright © 2019 glaphi. All rights reserved.
//

import Foundation
import UIKit

enum ImageStore {

    static let cache = NSCache<NSString, UIImage>()

    static func imageKey(for url: URL) -> NSString {
        url.absoluteString as NSString
    }
}

enum CustomError: Error {

    case invalidUpdate

}
