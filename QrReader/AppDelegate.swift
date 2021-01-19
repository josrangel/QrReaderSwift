//
//  AppDelegate.swift
//  QrReader
//
//  Created by jrangel on 14/01/21.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        window = UIWindow(frame: UIScreen.main.bounds)
        
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
                if let controller = storyboard.instantiateInitialViewController() {
               
                    window?.rootViewController = controller
                    window?.makeKeyAndVisible()
                }
        return true
    }

    // MARK: UISceneSession Lifecycle



}

