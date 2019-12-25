//
//  CatalogAPI.swift
//  Shop
//
//  Created by Glafira Privalova on 24.12.2019.
//  Copyright © 2019 glaphi. All rights reserved.
//

import Foundation
import UIKit

struct CatalogAPI {

    enum Path: String {
        case catalog = "/catalog"
        case categories = "/categories"
    }

    static func fetchImage(_ url: URL, completion: @escaping (Result<UIImage, Error>) -> ()) {
        // "https://picsum.photos/300/400/?image=751"

        Network.get(
            requestURL: url,
            headers: Network.HTTPHeader.acceptImage,
            cachePolicy: URLRequest.CachePolicy.reloadIgnoringCacheData,
            taskHandlingBlock: nil,
            completion: { result in
                switch result {
                case .success(let data):
                    guard let image = UIImage(data: data) else {
                        completion(.failure(URLError(.badServerResponse)))
                        return
                    }
                    completion(.success(image))

                case .failure(let error):
                    completion(.failure(error))
                }
        })
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
