//
//  AppDelegate.swift
//  PeopleNearBy
//
//  Created by Tianxiao Yang on 11/12/16.
//  Copyright © 2016 Tianxiao Yang. All rights reserved.
//

import UIKit
import UserNotifications
import FirebaseCore
import SwiftKeychainWrapper
import FirebaseAuth

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        let center = UNUserNotificationCenter.current()
        
        // set up request authorization from user to push reomte notifications
        center.requestAuthorization(options: [.badge, .alert, .sound], completionHandler: {granted, error in
            if error != nil {
                print("error with authtification")
            } else {
                print("successfully authtificated")
            }
        })
        
        // send request
        application.registerForRemoteNotifications()
        
        // configure firebase
        FIRApp.configure()

        // attemp to sign in user automaticly
        self.attemptToGetUserInfo()
    
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
        application.applicationIconBadgeNumber = 0
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        
        // save context before terminate
        CoredataService.saveContext()
    }
    
    // MARK: - Coredata part has been moved to CoredataService.swift
}

extension AppDelegate {
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        // get device token and parse it into NSString
        let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        print("$debug device token: \(deviceTokenString)")
        currentDeviceToken = deviceTokenString
        
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        
        print("$debug unable to register for remote notification \(error)")
        
    }
    
    
    // MARK: - Auto sign in function
    func attemptToGetUserInfo() {
        
        // try to get user email and password from keychain
        if let useremail = KeychainWrapper.standard.string(forKey: KEY_USER_EMAIL), let password = KeychainWrapper.standard.string(forKey: KEY_PASSWORD) {
            
            // sign in with user infomation from keychain
            FirebaseAuthService.sharedFIRAuthInstance.signInWith(email: useremail, password: password)
            
            let navigationVC = self.window?.rootViewController as! UINavigationController
            let mainSB = UIStoryboard(name: "Main", bundle: nil)
            let contactsVC = mainSB.instantiateViewController(withIdentifier: "ContactsVC") as! ContactsVC
            
            // if successfully got use info, push contactsVC to navigationVC's view controller stack
            navigationVC.pushViewController(contactsVC, animated: false)
        }
    }
}


