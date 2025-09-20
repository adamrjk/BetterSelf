//
//  BetterSelfApp.swift
//  BetterSelf
//
//  Created by Adam Damou on 15/08/2025.
//

import SwiftData
import SwiftUI
import FirebaseCore
import FirebaseStorage
import UserNotifications
import UIKit

// Updated AppDelegate
class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()

        //        if url.scheme == "betterself" {
        //
        //            //Your logic to what to do when app launch
        //               return true
        //
        //        }

        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
            }
        }

        return true
    }

//    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
//        if let scheme = url.scheme,
//           scheme.caseInsensitiveCompare("betterself") == .orderedSame {
//
//            var parameters: [String: String] = [:]
//            URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems?.forEach {
//                parameters[$0.name] = $0.value
//            }
//            for parameter in parameters where parameter.key.caseInsensitiveCompare("url") == .orderedSame {
//                UserDefaults().set(parameter.value, forKey: "incomingURL")
//            }
//
//        }
//        else {
//            print("Failed to enter the If")
//        }
//
//        return true
//    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // When notification is tapped, trigger the navigation
        NotificationManager.shared.shouldNavigateToReminder = true
        completionHandler()
    }
}

// Updated BetterSelfApp
@main
struct BetterSelfApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @Environment(\.modelContext) var modelContext
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(NotificationManager.shared)
                .onOpenURL { _ in
                    NotificationManager.shared.sharedReminder = true


                }
        }
        .modelContainer(for: [Reminder.self, Folder.self])
    }
}
//class SceneDelegate: UIResponder, UIWindowSceneDelegate {
//
//    var window: UIWindow?
//
//    // Called when opening a new scene
//    func scene(
//        _ scene: UIScene,
//        willConnectTo session: UISceneSession,
//        options connectionOptions: UIScene.ConnectionOptions
//    ) {
//        guard let _ = (scene as? UIWindowScene) else { return }
//        if let url = connectionOptions.urlContexts.first?.url {
//            handleIncomingURL(url)
//        }
//    }
//
//    // Called on existing scenes
//    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
//        if let url = URLContexts.first?.url {
//            handleIncomingURL(url)
//        }
//    }
//
//
//    func handleIncomingURL(_ url: URL) {
//        if let scheme = url.scheme,
//           scheme.caseInsensitiveCompare("betterself") == .orderedSame,
//           let page = url.host {
//
//            var parameters: [String: String] = [:]
//            URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems?.forEach {
//                parameters[$0.name] = $0.value
//            }
//            for parameter in parameters where parameter.key.caseInsensitiveCompare("url") == .orderedSame {
//                UserDefaults().set(parameter.value, forKey: "incomingURL")
//            }
//
//        }
//    }
//}
