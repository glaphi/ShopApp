//
//  Datasource.swift
//  Shop
//
//  Created by Glafira Privalova on 24.12.2019.
//  Copyright © 2019 glaphi. All rights reserved.
//

import Foundation
import UIKit

protocol UpdatesDelegate: AnyObject {
    func updaterDidInsert(at range: Range<Int>)
    func updaterDidReload()
    func updaterDidLoadEverything()
}

protocol CatalogDatasource: AnyObject {

    var delegate: UpdatesDelegate? { get set }

    var items: [Int: Item] { get set }

    var batchSize: Int { get set }

    var currentPage: Int { get set }

    var currentItemFetchDataTask: URLSessionDataTask? { get set }

    var previousURL: URL? { get set }

    var nextURL: URL? { get set }

    var isNextPageUnavailable: Bool { get }

    func fetchItems(_ page: Int, completion: OptionalErrorBlock?)

    func fetchImage(_ id: String, completion: @escaping (Result<UIImage, Error>) -> ())

}

extension CatalogDatasource {

    private func reset() {
        currentItemFetchDataTask?.cancel()
        currentItemFetchDataTask = nil
        nextURL = nil
        previousURL = nil
        currentPage = 0
        items = [:]
    }

    private func path(for page: Int) -> String? {

        if page == currentPage + 1 {
            guard let path = nextURL?.pathComponents.last else { return nil }
            return "/".appending(path)
        }

        // Previous page not in use

        return nil
    }

    func fetchImage(_ id: String, completion: @escaping (Result<UIImage, Error>) -> ()) {
        guard let url = items.first(where: { $0.value.item_id == id })?.value.image else {
            return
        }
        CatalogAPI.fetchImage(url, completion: completion)
    }

    func fetchItems(_ page: Int, completion: OptionalErrorBlock? = nil) {
        if page == 0 { reset() }

        guard let path = page == 0 ? CatalogAPI.Path.catalog.rawValue : path(for: page) else {
            completion?(nil)
            return
        }

        if currentItemFetchDataTask != nil {
            currentItemFetchDataTask?.cancel()
            currentItemFetchDataTask = nil
        }

        CatalogAPI.fetchCatalogue(
            path: path,
            taskHandler: { [weak self] task in
                self?.currentItemFetchDataTask = task
            }

        ) { [weak self] result in
            guard let self = self else { return }

            self.currentItemFetchDataTask = nil

            switch result {
            case .failure(let error):
                completion?(error)

            case .success(let envelop):

                if self.items.isEmpty {
                    // Save batch size of the first fetch
                    self.batchSize = envelop.result.count
                }

                self.currentPage = page

                if self.currentPage == 0 {
                    self.delegate?.updaterDidReload()
                }

                self.currentItemFetchDataTask = nil

                // Update recieved item in the dict

                let minIndex: Int = self.currentPage * self.batchSize

                for i in 0..<envelop.result.count {
                    self.items.updateValue(envelop.result[i], forKey: minIndex + i)
                }

                 self.delegate?.updaterDidInsert(at: minIndex ..< minIndex + envelop.result.count)

                // Update next page url

                self.nextURL = envelop.next

                if envelop.next == nil {
                    self.delegate?.updaterDidLoadEverything()
                }

                completion?(nil)
            }
        }
    }

}

class CatalogFetcher: CatalogDatasource {

    weak var delegate: UpdatesDelegate?

    var items: [Int: Item] = [:]

    var previousURL: URL?
    var nextURL: URL?

    var currentItemFetchDataTask: URLSessionDataTask?

    var currentPage: Int = 0
    var batchSize: Int = 0

    var isNextPageUnavailable: Bool { nextURL == nil }

}
