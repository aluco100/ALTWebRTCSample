//
//  AppDelegate.swift
//  ALTWebRTC
//
//  Created by Alfredo Luco on 06-06-20.
//  Copyright © 2020 Alfredo Luco. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        window?.makeKeyAndVisible()
        
        let homeVC = HomeViewController(nibName: String(describing: HomeViewController.self), bundle: Bundle(for: HomeViewController.self))
        let nav = UINavigationController(rootViewController: homeVC)
        window?.rootViewController = nav
        
        return true
    }

}

