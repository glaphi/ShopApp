//
//  Item.swift
//  Shop
//
//  Created by Glafira Privalova on 24.12.2019.
//  Copyright © 2019 glaphi. All rights reserved.
//

import Foundation

struct CategoryEnvelop: Codable {

    let categories: [String]

}

enum Currency: String, Codable {

    case usd = "$"
    case eur = "€"
    case gbp = "£"

}

struct Price: Codable {

    let value: Double
    let currency: Currency

}

struct Item: Codable {

    let item_id: String
    let title: String
    let description: String

    let price: Price
    let category: String

    let image: URL
    
}

struct CatalogueEnvelop: Codable {

    let result: [Item]
    let next: URL?
    let prev: URL?
    let total: Int

}
