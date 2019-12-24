//
//  CatalogAPI.swift
//  Shop
//
//  Created by Glafira Privalova on 24.12.2019.
//  Copyright © 2019 glaphi. All rights reserved.
//

import Foundation

struct CatalogAPI {

    enum Path: String {
        case catalog = "/catalog"
        case categories = "/categories"
    }

    /// Fetch items from catalog
    /// - Parameters:
    ///   - taskHandler: Handle created `URLSessionDataTask`
    ///   - completion: handle result with `CatalogueEnvelop` in case of success and `Error` otherwise
    static func fetchCatalogue(
        path: String,
        taskHandler: TaskHandler? = nil,
        completion: @escaping (Result<CatalogueEnvelop, Error>) -> ()
    ) {

        guard path.contains(Path.catalog.rawValue) else {
            completion(.failure(URLError(.badURL)))
            return
        }

        Network
            .get(
                path: path,
                headers: .acceptJson,
                taskHandlingBlock: taskHandler,
                completion: completion
        )
    }

    /// Fetch list of available categories
    /// - Parameters:
    ///   - taskHandler: Handle created `URLSessionDataTask`
    ///   - completion: handle result with `CategoryEnvelop` in case of success and `Error` otherwise
    static func fetchCategories(
        taskHandler: TaskHandler? = nil,
        completion: @escaping (Result<CategoryEnvelop, Error>) -> ()
    ) {

        Network
            .get(
                path: Path.categories.rawValue,
                headers: .acceptJson,
                taskHandlingBlock: taskHandler,
                completion: completion
        )
    }

}
