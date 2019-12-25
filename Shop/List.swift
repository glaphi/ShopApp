//
//  List.swift
//  Shop
//
//  Created by Glafira Privalova on 24.12.2019.
//  Copyright © 2019 glaphi. All rights reserved.
//

import Foundation
import UIKit

class ListController: UITableViewController, UpdatesDelegate {
    
    private var datasource: CatalogDatasource?

    init(datasource: CatalogDatasource? = nil) {
        super.init(style: .plain)

        self.datasource = datasource
        self.datasource?.delegate = self
    }

    required init?(coder: NSCoder) { nil }

    private var computedDatasource

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Catalogue"

        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)

        tableView.tableFooterView = UIView()

        tableView.register(ImagedItemCell.self, forCellReuseIdentifier: ImagedItemCell.reuseID)
        tableView.register(SpinnerCell.self, forCellReuseIdentifier: SpinnerCell.reuseID)

        tableView.refreshControl?.beginRefreshing()
        refresh()
    }

    override func numberOfSections(in tableView: UITableView) -> Int { 2 }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return datasource?.items.count ?? 0
        default:
            return (datasource?.isNextPageUnavailable ?? true) ? 0 : 1
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let datasource = datasource else { return UITableViewCell() }

        switch indexPath.section {
        case 0:
            guard let item = datasource.items[indexPath.row],
                let cell = tableView.dequeueReusableCell(withIdentifier: ImagedItemCell.reuseID, for: indexPath) as? ImagedItemCell else {

                    return spinnerCell(for: indexPath)
            }

            cell.update(
                id: item.item_id,
                title: item.title,
                description: item.description,
                price: "\(item.price.value)".appending(" ").appending(item.price.currency.rawValue),
                category: item.category
            )

            return cell
        default:
            return spinnerCell(for: indexPath)
        }
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let datasource = datasource else { return }

        switch indexPath.section {
        case 0:
            guard let id = datasource.items[indexPath.row]?.item_id,
                let cell = cell as? ImagedItemCell else { return }

            datasource.fetchImage(id) { result in
                DispatchQueue.main.async { [weak self] in
                    guard self != nil else { return }
                    switch result {
                    case .failure(let error):
                        print("Failed to fetch image ", error)

                    case .success(let image):
                        cell.update(id: id, image: image)
                    }
                }
            }

        default:
            guard let cell = cell as? SpinnerCell else { return }

            cell.startSpinning()

            loadContent(page: pageNumber(for: indexPath))
        }
    }

    private func spinnerCell(for indexPath: IndexPath) -> UITableViewCell {
        tableView.dequeueReusableCell(withIdentifier: SpinnerCell.reuseID, for: indexPath)
    }

    private func pageNumber(for indexPath: IndexPath) -> Int {
        guard let datasource = datasource else { return initialPage }

        return datasource.currentPage + 1
    }

    // MARK: - Content loading

    private func loadContent(page: Int, completion: EmptyBlock? = nil) {
        guard let datasource = datasource else {
            completion?()
            return
        }

        datasource.fetchItems(page) { error in
            DispatchQueue.main.async { [weak self] in
                guard error == nil else {
                    if (error! as NSError).code != URLError.cancelled.rawValue {
                        self?.presentConfirmAlert("Failed to fetch catalogue!")
                    }
                    return
                }
            }
            completion?()
        }
    }

    @objc private func refresh() {
        loadContent(page: initialPage) {
            DispatchQueue.main.async { [weak self] in
                self?.tableView.refreshControl?.endRefreshing()
            }
        }
    }

    // MARK: Updates Delegate

    private let initialPage: Int = 0

    func updaterDidInsert(at range: Range<Int>) {
        var indexPaths: [IndexPath] = []

        for i in range {
            indexPaths.append(IndexPath(row: i, section: 0))
        }

        guard !indexPaths.isEmpty else { return }

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            guard !(self.tableView.refreshControl?.isRefreshing ?? false) else { return }

            self.tableView.performBatchUpdates({
                self.tableView.insertRows(at: indexPaths, with: .automatic)

                if (self.datasource?.isNextPageUnavailable ?? true) {
                    self.tableView.deleteRows(at: [IndexPath(row: 0, section: 1)], with: .automatic)
                }
            })
        }
    }

    func updaterDidLoadEverything() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            guard !(self.tableView.refreshControl?.isRefreshing ?? false) else { return }

            if self.tableView.numberOfRows(inSection: 1) > 0 {
                self.tableView.performBatchUpdates({
                    self.tableView.deleteRows(at: [IndexPath(row: 0, section: 1)], with: .automatic)
                })
            }
        }
    }

    func updaterDidReload() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            guard !(self.tableView.refreshControl?.isRefreshing ?? false) else { return }

            self.tableView.reloadData()
        }
    }

}
