//
//  List.swift
//  Shop
//
//  Created by Glafira Privalova on 24.12.2019.
//  Copyright © 2019 glaphi. All rights reserved.
//

import Foundation
import UIKit

class ListController: UITableViewController {

    private var datasource: CatalogDatasource?

    override func viewDidLoad() {
        super.viewDidLoad()

        datasource = CatalogFetcher()

        navigationItem.title = "Catalogue"

        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(refresh(_:)), for: .touchUpInside)

        tableView.tableFooterView = UIView()

        tableView.register(ListCell.self, forCellReuseIdentifier: ListCell.reuseID)
        tableView.register(SpinnerCell.self, forCellReuseIdentifier: SpinnerCell.reuseID)

        refresh(tableView.refreshControl!)
        tableView.refreshControl?.beginRefreshing()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        datasource?.totalItemsCount ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let datasource = datasource else { return UITableViewCell() }

        switch indexPath.row {

        case 0 ..< datasource.items.count:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ListCell.reuseID, for: indexPath) as? ListCell else {
                return UITableViewCell()
            }

            cell.textLabel?.text = datasource.items[indexPath.row].title
            return cell

        default:
            return tableView.dequeueReusableCell(withIdentifier: SpinnerCell.reuseID, for: indexPath)
        }

    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let datasource = datasource else { return }

        switch indexPath.row {

        case 0 ..< datasource.items.count:
            // load img
            break

        default:
            loadContent(page: .next)
        }
    }

    private func loadContent(page: Page, completion: EmptyBlock? = nil) {
        self.datasource?.fetchItems { error in
            DispatchQueue.main.async { [weak self] in
                completion?()

                guard error == nil else {
                    let nserror = error! as NSError
                    print("nserror ", nserror)
                    if (error! as NSError).code != URLError.cancelled.rawValue {
                        self?.presentConfirmAlert("Failed to fetch catalogue!")
                    }
                    return
                }

                self?.tableView?.reloadData()
            }
        }
    }

    @objc func refresh(_ sender: UIRefreshControl) {
        loadContent(page: .initial, completion: { sender.endRefreshing() })
    }

}

class ListCell: UITableViewCell {

}

class SpinnerCell: UITableViewCell {

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: SpinnerCell.reuseID)

        let spinner = UIActivityIndicatorView(style: .medium)

        contentView.addSubview(spinner)

        spinner.center = contentView.center

        spinner.startAnimating()
    }

    required init?(coder: NSCoder) { nil }

}
