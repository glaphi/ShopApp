//
//  List.swift
//  Shop
//
//  Created by Glafira Privalova on 24.12.2019.
//  Copyright © 2019 glaphi. All rights reserved.
//

import Foundation
import UIKit

class CatalogueViewController: UITableViewController {

    init(datasource: CatalogueDatasource = CatalogFetcher()) {
        self.datasource = datasource

        super.init(style: .plain)
    }

    required init?(coder: NSCoder) { nil }

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidBecomeActiveNotification),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillResignActiveNotification),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )

        navigationItem.title = CustomString.catalogTitle

        tableView.register(ImagedItemCell.self, forCellReuseIdentifier: ImagedItemCell.reuseID)
        tableView.register(SpinnerCell.self, forCellReuseIdentifier: SpinnerCell.reuseID)

        tableView.tableFooterView = UIView() // Removes extra separator lines in table view

        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)

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
            return datasource.items.count
        default:
            return datasource.isNextPageAvailable ? 1 : 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

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
        switch indexPath.section {
        case 0:
            guard let id = datasource.items[indexPath.row]?.item_id,
                let cell = cell as? ImagedItemCell else { return }

            datasource.fetchImage(id) { result in
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    switch result {
                    case .failure(_):
                        self.presentConfirmAlert(CustomString.errorAlertTitle, message: CustomString.faileToLoadImage)

                    case .success(let image):
                        try? cell.update(id: id, image: image)
                    }
                }
            }

        default:
            guard let cell = cell as? SpinnerCell else { return }

            cell.startSpinning()

            loadContent(page: datasource.currentPage + 1) { [weak self] in
                self?.insertRows()
            }
        }
    }

    private var isRefreshing: Bool {
        tableView.refreshControl?.isRefreshing ?? false
    }

    private func spinnerCell(for indexPath: IndexPath) -> UITableViewCell {
        tableView.dequeueReusableCell(withIdentifier: SpinnerCell.reuseID, for: indexPath)
    }

    // MARK: - Datasource

    private var datasource: CatalogueDatasource

    // MARK: - Content loading

    private func loadContent(page: Int, completion: EmptyBlock? = nil) {

        datasource.fetchItems(page) { error in
            DispatchQueue.main.async { [weak self] in
                guard error == nil else {
                    if (error! as NSError).code != URLError.cancelled.rawValue {
                        self?.presentConfirmAlert(CustomString.errorAlertTitle, message: CustomString.faileToLoadCatalogue)
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
                self?.reload()
            }
        }
    }

    // MARK: - UI Updates

    private let initialPage: Int = 0

    func insertRows() {
        guard datasource.items.count > tableView.numberOfRows(inSection: 0) else { return }
        
        var indexPaths: [IndexPath] = []

        for i in tableView.numberOfRows(inSection: 0) ..< datasource.items.count {
            indexPaths.append(IndexPath(row: i, section: 0))
        }

        guard !indexPaths.isEmpty, !isRefreshing else { return }

        tableView.performBatchUpdates({
            tableView.insertRows(at: indexPaths, with: .automatic)

            if !datasource.isNextPageAvailable {
                self.tableView.deleteRows(at: [IndexPath(row: 0, section: 1)], with: .automatic)
            }
        })
    }

    func deleteSpinnerRow() {
        guard !isRefreshing else { return }

        if tableView.numberOfRows(inSection: 1) > 0 {
            tableView.performBatchUpdates({
                tableView.deleteRows(at: [IndexPath(row: 0, section: 1)], with: .automatic)
            })
        }
    }

    func reload() {
        guard !isRefreshing else { return }
        tableView.reloadData()
    }

    // MARK: - Application Notifications

    @objc private func appDidBecomeActiveNotification() {
        tableView.reloadData() // TODO: handle updates smoother
    }

    @objc private func appWillResignActiveNotification() {
        tableView.refreshControl?.endRefreshing()
    }

}
