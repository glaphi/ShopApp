//
//  Datasource.swift
//  Shop
//
//  Created by Glafira Privalova on 24.12.2019.
//  Copyright © 2019 glaphi. All rights reserved.
//

import Foundation

enum Page {
    case initial
    case previous
    case next
}

protocol CatalogDatasource: AnyObject {

    var items: [Item] { get set }

    var totalItemsCount: Int { get set }

    var isAllLoaded: Bool { get }

    var currentDataTask: URLSessionDataTask? { get set }

    var previousURL: URL? { get set }

    var nextURL: URL? { get set }

    func fetchItems(_ page: Page, completion: OptionalErrorBlock?)
}

extension CatalogDatasource {

    func reset() {
        currentDataTask?.cancel()
        currentDataTask = nil
        nextURL = nil
        previousURL = nil
        totalItemsCount = 0
    }

    func fetchItems(_ page: Page = .initial, completion: OptionalErrorBlock? = nil) {
        if currentDataTask != nil { currentDataTask?.cancel() }

        if page == .initial { reset() }

        guard let path = path(for: page) else {
            completion?(URLError(.badURL))
            return
        }

        CatalogAPI.fetchCatalogue(
            path: path,
            taskHandler: { [weak self] task in
                self?.currentDataTask = task
            }

        ) { [weak self] result in
            guard let self = self else { return }

            self.currentDataTask = nil

            switch result {
            case .failure(let error):
                completion?(error)

            case .success(let envelop):

                self.items = envelop.result
                self.totalItemsCount = envelop.total
                self.previousURL = envelop.prev
                self.nextURL = envelop.next

                completion?(nil)
            }
        }
    }

    func path(for page: Page) -> String? {
        switch page {
        case .initial:
            return CatalogAPI.Path.catalog.rawValue

        case .previous:
            return previousURL?.pathComponents.last

        case .next:
            return nextURL?.pathComponents.last
        }
    }

}

class CatalogFetcher: CatalogDatasource {

    var items: [Item] = []

    var totalItemsCount: Int = 0

    var previousURL: URL?

    var nextURL: URL?

    var currentDataTask: URLSessionDataTask?

    var isAllLoaded: Bool {
        nextURL == nil && items.count == totalItemsCount
    }

}
