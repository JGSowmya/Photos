//
//  AppDelegate.swift
//  Photos
//
//  Created by Sowmya J G on 08/12/19.
//  Copyright © 2019 Sowmya J G. All rights reserved.
//

import UIKit
import UserNotifications

@available(iOS 10.0, *)
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let token = deviceToken.map {String(format: "%02.2hhx", $0)}.joined()
        print("The device token is \(deviceToken) and hext string is \(token)")
        
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to get device token: \(error.localizedDescription)")
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.sound, .badge, .alert])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("Received notification and clicked on it")
        completionHandler()
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        UNUserNotificationCenter.current().delegate = self
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { (granted, error) in
                guard granted else {
                    print("Failed to support notification \(error?.localizedDescription ?? "ERROR")")
                    return
                }
                print("granted \(granted)")
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
            }
        } else {
            // Fallback on earlier versions
        }
        
        return true
    }

    // MARK: UISceneSession Lifecycle


}

