//
//  AppDelegate.swift
//  COVID-19 Track
//
//  Created by George Tsifrikas on 8/3/20.
//  Copyright © 2020 George Tsifrikas. All rights reserved.
//

import UIKit
import RxBluetoothKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var beacon = BluetoothBeacon()
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        setUpDependencies(container: Resolver.root)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.beacon.startBroadcasting()
        }
        
        RxBluetoothKitLog.setLogLevel(.debug)
        
        return true
    }
    
    private func setUpDependencies(container: Resolver) {
        container.register(Tracker.self) { BluetoothTracker() }
    }

    // MARK: UISceneSession Lifecycle

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

