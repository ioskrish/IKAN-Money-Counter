//
//  AppDelegate.swift
//  iKAN
//
//  Created by Krishna Panchal on 26/11/23.
//

import UIKit

@available(iOS 13.0, *)
@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        let defaultWorkdaysBoolArr = [false, true, true, true, true, true, false]

//        if CommandLine.arguments.contains("--iKAN") {
//            // We are in testing mode, make arrangements if needed
//            UD.set(15, forKey: Const.UDef.hourlyRate)
//            UD.set("09:00", forKey: Const.UDef.startTime)
//            UD.set("17:00", forKey: Const.UDef.endTime)
//            UD.set(false, forKey: Const.UDef.userSawTutorial)
//            UD.set(defaultWorkdaysBoolArr, forKey: Const.UDef.weekdaysIWorkOn)
//        }

        UD.register(defaults: [
            Const.UDef.hrlyRate: 15.0,
            Const.UDef.startTime: "09:00",
            Const.UDef.endTime: "17:00",
            Const.UDef.userSawTutorial: false,
            Const.UDef.weekdaysIWorkOn: defaultWorkdaysBoolArr
        ])
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

