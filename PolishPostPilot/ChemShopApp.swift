//
//  ChemShopApp.swift
//  ChemShop
//
//  Created by cybercrot on 26.10.2025.
//

import SwiftUI
import SwiftData

@main
struct MyApp: App {
    let modelContainer: ModelContainer
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    init() {
        do {
            modelContainer = try ModelContainer(for: CarBooking.self, InventoryItem.self, Post.self, InventoryUsage.self)
        } catch {
            fatalError("Could not initialize ModelContainer: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            LaunchView()
                .modelContainer(modelContainer)
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    
    static var orientationMask: UIInterfaceOrientationMask = .portrait
    
    func application(_ application: UIApplication,
                     supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        Self.orientationMask
    }
}
