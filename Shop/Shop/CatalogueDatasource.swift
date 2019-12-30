//
//  Datasource.swift
//  Shop
//
//  Created by Glafira Privalova on 24.12.2019.
//  Copyright © 2019 glaphi. All rights reserved.
//

import Foundation
import UIKit

protocol CatalogueDatasource: AnyObject {

    var items: [Int: Item] { get set }

    var batchSize: Int { get set }

    var currentPage: Int { get set }

    var nextURL: URL? { get set }

    var isNextPageAvailable: Bool { get }

    func fetchItems(_ page: Int, completion: OptionalErrorBlock?)

    func fetchImage(_ id: String, completion: @escaping (Result<UIImage, Error>) -> ())

}

extension CatalogueDatasource {

    var isNextPageAvailable: Bool {
        nextURL != nil
    }

    private func reset() {
        nextURL = nil
        currentPage = 0
        items = [:]
    }

    func fetchImage(_ id: String, completion: @escaping (Result<UIImage, Error>) -> ()) {
        guard let url = items.first(where: { $0.value.item_id == id })?.value.image else {
            return
        }

        if let image = ImageStore.cache.object(forKey: ImageStore.imageKey(for: url)) {
            completion(.success(image))
        } else {
            CatalogAPI.fetchImage(url, completion: completion)
        }
    }

    func fetchItems(_ page: Int, completion: OptionalErrorBlock? = nil) {

        let path: String

        if page == 0 {
            reset()
            path = CatalogAPI.Path.catalog.rawValue
        } else {
            guard let lastURLComponent = nextURL?.pathComponents.last else {
                // Fail silently since that should not happen
                completion?(nil)
                return
            }

            path = "/".appending(lastURLComponent)
        }

        CatalogAPI.fetchCatalogue(path: path) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .failure(let error):
                DispatchQueue.main.async {
                    completion?(error)
                }

            case .success(let envelop):

                // Save batch size of the first fetch

                if self.items.isEmpty {
                    self.batchSize = envelop.result.count
                }

                // Update current page

                self.currentPage = page

                // Update recieved item in the dictionary

                let minIndex: Int = self.currentPage * self.batchSize

                for i in 0..<envelop.result.count {
                    self.items.updateValue(envelop.result[i], forKey: minIndex + i)
                }

                // Update next page url, previous page is not in use

                self.nextURL = envelop.next

                DispatchQueue.main.async {
                    completion?(nil)
                }
            }
        }
    }

}

class CatalogFetcher: CatalogueDatasource {

    var items: [Int: Item] = [:]

    var nextURL: URL?

    var currentPage: Int = 0

    var batchSize: Int = 0

}
