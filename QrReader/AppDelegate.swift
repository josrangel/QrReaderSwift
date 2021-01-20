//
//  AppDelegate.swift
//  QrReader
//
//  Created by jrangel on 14/01/21.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    // MARK: - Variables

    var window: UIWindow?

    // MARK: - Lifecycle

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions
                        launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        window = UIWindow(frame: UIScreen.main.bounds)
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        if let controller = storyboard.instantiateInitialViewController() {
            window?.rootViewController = controller
            window?.makeKeyAndVisible()
        }
        return true
    }
}
