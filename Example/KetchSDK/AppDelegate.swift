//
//  AppDelegate.swift
//  KetchSDK
//
//  Created by Anton Lyfar on 10/05/2022.
//

import UIKit
import SwiftUI
import KetchSDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = UIHostingController(
            rootView: ContentView()
        )

        window?.makeKeyAndVisible()

        return true
    }
}
