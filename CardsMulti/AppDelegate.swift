//
//  AppDelegate.swift
//  CardsMulti
//
//  Created by Victor on 2017-02-10.
//  Copyright © 2017 Victorius Software Inc. All rights reserved.
//

import UIKit
import AVFAudio

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        application.isIdleTimerDisabled = true
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.ambient)
        } catch {
            print("Failed to set audio category")
        }
        
        return true
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        
        // Get URL components from the incoming user activity
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
            let incomingURL = userActivity.webpageURL,
            let components = NSURLComponents(url: incomingURL, resolvingAgainstBaseURL: true) else {
            print("link fail")
            return false
        }
        
        print("link: \(incomingURL.absoluteString)")
        
        // Check for specific URL components
        guard let path = components.path else {
            print("path fail")
            return false
        }
        
        print("path = \(path)")
        
        if path != "/join" {
            return false
        }
        
        guard let params = components.queryItems else {
            print("no params")
            return false
        }
        
        for param in params {
            print("param: \(param.name) = \(param.value ?? "NULL")")
        }
        
        if let gameId = params.first(where: { $0.name == "gameid" } )?.value {
            print("gameId: \(gameId)")
            
        } else if let gameCode = params.first(where: { $0.name == "gamecode" } )?.value {
            print("gameCode: \(gameCode)")

            if let viewController = self.window?.rootViewController as! GameViewController? {
                viewController.connectionService.startService()
                viewController.findGames(withGameCode: gameCode)
            }
        } else {
            print("params fail")
            return false
        }
            
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        if let viewController = self.window?.rootViewController as! GameViewController? {
            viewController.connectionService.stopAdvertising()
            viewController.connectionService.stopBrowsing()
        }
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        if let viewController = self.window?.rootViewController as! GameViewController? {
            viewController.connectionService.stopAdvertising()
            viewController.connectionService.stopBrowsing()
            viewController.saveGame()
        }
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        if let viewController = self.window?.rootViewController as! GameViewController? {
            viewController.connectionService.startService()
        }
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        if let viewController = self.window?.rootViewController as! GameViewController? {
            viewController.connectionService.startService()
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        if let viewController = self.window?.rootViewController as! GameViewController? {
            viewController.connectionService.stopService()
            viewController.saveGame()
        }
    }


}

