//
//  AppDelegate.swift
//  Shop
//
//  Created by Glafira Privalova on 24.12.2019.
//  Copyright © 2019 glaphi. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        let listController = ListController(datasource: CatalogFetcher())

        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = UINavigationController(rootViewController: listController)
        window!.makeKeyAndVisible()

        return true
    }

}

