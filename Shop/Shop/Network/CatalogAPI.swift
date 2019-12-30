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

    enum Configuration {
        static let scheme: String = "https"
        static let host: String = "mobile-code-challenge.s3.eu-central-1.amazonaws.com"
    }

    enum Path: String {
        case catalog = "/catalog"
        case categories = "/categories"
    }

    private static var catalogTask: URLSessionDataTask?

    private static var imageTasks: [URLSessionDataTask] = []

    static func fetchImage(_ url: URL, completion: @escaping (Result<UIImage, Error>) -> ()) {
        UIApplication.shared.performWithExtendedBackgroundExecution {

            Network.get(
                requestURL: url,
                headers: Network.HTTPHeader.acceptImage,
                cachePolicy: URLRequest.CachePolicy.reloadIgnoringCacheData, // ignoring cache in case image was changed
                taskHandlingBlock: nil, // TODO: add option to cancel unnecessary tasks
                completion: { result in

                    switch result {
                    case .success(let data):
                        guard let image = UIImage(data: data) else {
                            completion(.failure(URLError(.badServerResponse)))
                            return
                        }

                        ImageStore.cache.setObject(image, forKey: ImageStore.imageKey(for: url))
                        completion(.success(image))

                    case .failure(let error):
                        completion(.failure(error))
                    }
            })
        }
    }



    /// Fetch items from catalog
    /// - Parameters:
    ///   - taskHandler: Handle created `URLSessionDataTask`
    ///   - completion: handle result with `CatalogueEnvelop` in case of success and `Error` otherwise
    static func fetchCatalogue(
        path: String,
        completion: @escaping (Result<CatalogueEnvelop, Error>) -> ()
    ) {

        guard path.contains(Path.catalog.rawValue),
            let url = try? shopURL(with: path) else {
                completion(.failure(URLError(.badURL)))
                return
        }

        UIApplication.shared.performWithExtendedBackgroundExecution {
            Network.get(
                requestURL: url,
                headers: .acceptJson,
                completion: { result in
                    decode(from: result, completion: completion)
            })
        }
    }

    /// Fetch list of available categories
    /// - Parameters:
    ///   - taskHandler: Handle created `URLSessionDataTask`
    ///   - completion: handle result with `CategoryEnvelop` in case of success and `Error` otherwise
    static func fetchCategories(
        completion: @escaping (Result<[String], Error>) -> ()
    ) {

        // TODO: Not in use, remove or start using

        guard let url = try? shopURL(with: Path.categories.rawValue) else {
            completion(.failure(URLError(.badURL)))
            return
        }

        struct CategoryEnvelop: Decodable {
            let categories: [String]
        }

        Network.get(
            requestURL: url,
            headers: .acceptJson,
            completion: { result in
                decode(from: result) { (result: Result<CategoryEnvelop, Error>) in
                    switch result {
                    case .success(let envelop):
                        completion(.success(envelop.categories))

                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
        })

    }

    // MARK: - Private helper API

    private static func shopURL(with path: String) throws -> URL {
        var urlComponents = URLComponents()
        urlComponents.scheme = Configuration.scheme
        urlComponents.host = Configuration.host
        urlComponents.path = path

        guard let url = urlComponents.url else {
            throw URLError(.badURL)
        }

        return url
    }

    private static func decode<T: Decodable>(from result: Result<Data, Error>, completion: (Result<T, Error>) -> ()) {
        switch result {
        case .failure(let error):
            completion(.failure(error))

        case .success(let data):
            do {
                let decodedObject = try jsonDecoder.decode(T.self, from: data)
                completion(.success(decodedObject))
            } catch {
                completion(.failure(error))
            }
        }
    }

}
