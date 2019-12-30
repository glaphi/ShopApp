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

        let listController = CatalogueViewController(datasource: CatalogFetcher())

        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = UINavigationController(rootViewController: listController)
        window!.makeKeyAndVisible()

        return true
    }

    func applicationDidReceiveMemoryWarning(_ application: UIApplication) {
        ImageStore.cache.removeAllObjects()
    }

}

var backgroundTasksCounter: Int = 0

extension UIApplication {

    /// Run a block in background after app resigns activity
    func performWithExtendedBackgroundExecution(expirationHandler: (() -> Void)? = nil, closure: @escaping () -> Void) {

        DispatchQueue.global().async {

            backgroundTasksCounter += 1
            let taskKey = backgroundTasksCounter

            let newTaskId = self.beginBackgroundTask(expirationHandler: {
                expirationHandler?()

                self.endExtendedBackgroundExecutionTask(taskKey)
            })

            backgroundTasksStore.updateValue(newTaskId, forKey: taskKey)

            closure()

            self.endExtendedBackgroundExecutionTask(taskKey)
        }
    }

    /// End extended background execution task and remove task id from background tasks dictionary
    private func endExtendedBackgroundExecutionTask(_ taskKey: Int) {

        guard let taskId = backgroundTasksStore[taskKey],
            taskId != UIBackgroundTaskIdentifier.invalid else {
                return
        }

        backgroundTasksStore.removeValue(forKey: taskKey)

        endBackgroundTask(taskId)
    }

}
