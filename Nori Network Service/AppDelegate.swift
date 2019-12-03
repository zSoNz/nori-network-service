//
//  AppDelegate.swift
//  Nori Network Service
//
//  Created by IDAP Developer on 8/5/19.
//  Copyright © 2019 Bendis. All rights reserved.
//

import UIKit

import NetworkService

class NoriHeader: Headers {
    
    var authorization = "Bearer r13rrqewfq344qf4q34f"
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        UrlSessionService.headers = NoriHeader()
        
        let controller = MainViewController()
        
        let window = UIWindow(frame: UIScreen.main.bounds)
        self.window = window
        window.rootViewController = controller
        window.makeKeyAndVisible()
        
        return true
    }
}
