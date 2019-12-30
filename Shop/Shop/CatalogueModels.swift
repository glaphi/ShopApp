//
//  Item.swift
//  Shop
//
//  Created by Glafira Privalova on 24.12.2019.
//  Copyright © 2019 glaphi. All rights reserved.
//

import Foundation

enum Currency: String, Decodable {

    case usd = "$"
    case eur = "€"
    case gbp = "£"

}

struct Price: Decodable {

    let value: Double
    let currency: Currency

}

struct Item: Decodable {

    let item_id: String
    let title: String
    let description: String

    let price: Price
    let category: String

    let image: URL
    
}

struct CatalogueEnvelop: Decodable {

    let result: [Item]
    let next: URL?
    let prev: URL?
    let total: Int

}
