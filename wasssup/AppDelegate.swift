//
//  AppDelegate.swift
//  wasssup
//
//  Created by Lawrence Gimenez on 01/05/2017.
//  Copyright © 2017 Law Gimenez. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import IQKeyboardManagerSwift
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        // Initialize Firebase
        FIRApp.configure()
        // Check if user is logged in
        if FIRAuth.auth()?.currentUser != nil {
            UserDefaults.standard.set(true, forKey: Keys.isLoggedIn)
        } else {
            UserDefaults.standard.set(false, forKey: Keys.isLoggedIn)
        }
        // Initialize keyboard manager
        IQKeyboardManager.sharedManager().enable = true
        IQKeyboardManager.sharedManager().enableAutoToolbar = false
        // Initialize Realm schema and configuration
        Realm.Configuration.defaultConfiguration = Realm.Configuration(
            schemaVersion: 4,
            migrationBlock: {
                migration, oldSchemaVersion in
                if oldSchemaVersion < 1 {
                }
        })
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

