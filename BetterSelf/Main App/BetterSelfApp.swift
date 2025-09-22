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

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // When notification is tapped, trigger the navigation

        let request = response.notification.request
        NotificationManager.shared.reminderID = request.identifier
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
                .onOpenURL { url in
                    if url.absoluteString.localizedStandardContains("url") {
                        NotificationManager.shared.sharedReminder = true
                    }
                    else {

                        guard let range = url.absoluteString.range(of: "reminder=") else { return }
                        NotificationManager.shared.widgetReminderId = String(url.absoluteString[range.upperBound...])
                        NotificationManager.shared.widgetReminder = true
                    }




                }
        }
        .modelContainer(for: [Reminder.self, Folder.self])
    }
}
