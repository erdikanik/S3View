//
//  AppDelegate.swift
//  S3MediaTest
//
//  Created by Erdi on 28.06.2020.
//  Copyright © 2020 *. All rights reserved.
//

import UIKit
import AWSS3

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        AWSDDLog.add(AWSDDTTYLogger.sharedInstance)
        AWSDDLog.sharedInstance.logLevel = .debug
        
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType:.USEast1,
           identityPoolId:"us-east-1:a745f0cf-984e-4d19-83ee-fb1e9e09cfd7")

        let configuration = AWSServiceConfiguration(region:.USEast1, credentialsProvider:credentialsProvider)


        //Setup the transfer utility configuration
        let tuConf = AWSS3TransferUtilityConfiguration()
        tuConf.timeoutIntervalForResource = 100000
        
        //Register a transfer utility object
        AWSS3TransferUtility.register(
            with: configuration!,
            transferUtilityConfiguration: tuConf,
            forKey: "transfer-utility-with-advanced-options"
        )
        
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

