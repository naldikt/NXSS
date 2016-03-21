//
//  AppDelegate.swift
//  NXSSDemo
//
//  Created by Nalditya Kusuma on 10/3/15.
//  Copyright © 2015 Nalditya Kusuma. All rights reserved.
//

import UIKit
import NXSS

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
//        NXSS.sharedInstance.useFile("Main")
        
        
        // DEBUG TIME ME
        NSLog("NXSS Parsing times")
        let total : Int = 20
        var sum : NSTimeInterval = 0.0
        for i in (0..<total) {
            let startTime = NSDate()
            NXSS.sharedInstance.useFile("Main")
            let diff = NSDate().timeIntervalSince1970 - startTime.timeIntervalSince1970
            NSLog("\(diff)")
            sum += diff
        }
        let average : NSTimeInterval = sum / NSTimeInterval(total)
        NSLog("Average = \(average)")
        
        
//        NSLog("Start")
//        NXSS.sharedInstance.useFile("DefaultX_nui")
//        NXSS.sharedInstance.useFile("Main")        
//        NSLog("End")
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

