//
//  iOS_challengeApp.swift
//  iOS-challenge
//
//  Created by 🐉 on 11/07/24.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        URLCache.shared.memoryCapacity = 10_000_000 // ~10 MB memory space
        URLCache.shared.diskCapacity = 1_000_000_000 // ~1GB disk cache space
        FirebaseApp.configure()
        return true
    }
}

@main
struct iOS_challengeApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var body: some Scene {
        WindowGroup {
            BreedsView(viewModel: BreedsViewModel())
        }
    }
}
