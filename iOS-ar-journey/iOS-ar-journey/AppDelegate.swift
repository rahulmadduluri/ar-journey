//
//  AppDelegate.swift
//  iOS-ar-journey
//
//  Created by Rahul Madduluri on 4/23/17.
//  Copyright © 2017 rahulm. All rights reserved.
//

import UIKit
import KudanAR

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Add kudan license key
        ARAPIKey.sharedInstance().setAPIKey("BupCs3mkki/dYg28xUb83QN9peY7md4++icCTuPhwUfzqbdDNs7quVvGwsNtMn9TChEO4gJ8ByiSy168CWj21vMiXZo3feqeEKYRlRj/x1pgADM8B7jEDm/PaaA1c7veAyEVIb1WReTfkH24wC6aseFgPgtoGQbAlFVfHJNBqGFND8UqZVBiDzUibjW3eyeI5RxMIbfuhmP+fFiskbNxcSKpbk9pR7snWrFFb61nJOlAEcfLXOkrSOsebjCUe/ICqNpwXWVpazyRuNFDMvm0s9hKQK7dcQ0v798L2lAAYsYc+EeBz3VW92dkI8+QWDXUxyeHsc4ytv229/ZQCnHacs1bP1Mj7k5HWjrUrnm8iHCDV4I1RpVYlR6E2ZYoJ4Ll4RGIgTfJKSs5YRtCrvY8LT3T9MhJl97Y1jvSuitUoJPDZmxnUlkDvVd+jozzRqyTl4N+9uXk/mKC2MxxxgzZ3kgX58gIg7DKOmPW3kSqhyLxHXwHRBxvzlY1EMojsZlWoNIptqmypwMWVTv27cXxwYiiTmr3q72ABPU3jo9jO0pooV2F1PbZXz/YiXRHs4SljidKQa5q1w9ky+w4Dh/AMHtuqSoaHYyPUaSHcugtrJcbzDC+F9qsHdxf4o4+FQnKz62iH+JWxvaP6KY4J1shCbXZXiGTEgOKQj/F//hYg64=")
        
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

