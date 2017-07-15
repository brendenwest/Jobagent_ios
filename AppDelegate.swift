//
//  AppDelegate.swift
//  
//
//  Created by Brenden West on 7/14/17.
//
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    lazy var dataController = DataController() {}
    
    lazy var configuration: [String:Any] = {
        return Settings.loadConfiguration()
    }()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        
        Settings.onLaunch() // set app configuration

        return true
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        dataController.saveContext()
    }
}
