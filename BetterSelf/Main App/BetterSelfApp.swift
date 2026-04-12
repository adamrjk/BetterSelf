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
    private func cleanupLocalVideoFiles() {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        guard let files = try? FileManager.default.contentsOfDirectory(at: docs, includingPropertiesForKeys: nil) else { return }
        for file in files where file.pathExtension == "mov" {
            try? FileManager.default.removeItem(at: file)
        }
    }

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        URLCache.shared = URLCache(memoryCapacity: 50 * 1024 * 1024, diskCapacity: 200 * 1024 * 1024)
        cleanupLocalVideoFiles()
        FirebaseApp.configure()
        // Configure Analytics with anonymous defaults; identifiable tracking opt-in later
        AnalyticsService.configure(consentedToIdentifiableTracking: false)
        AnalyticsService.log(AnalyticsService.EventName.appOpened)
        UNUserNotificationCenter.current().delegate = self
        return true
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // When notification is tapped, trigger the navigation

        let request = response.notification.request
        NotificationManager.shared.reminderID =  request.identifier.components(separatedBy: "_").first
        NotificationManager.shared.shouldNavigateToReminder = true
        completionHandler()
    }
}

// Updated BetterSelfApp
@main
struct BetterSelfApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @Environment(\.modelContext) var modelContext
    @StateObject var flow = AppFlow()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .tutorialOverlay()
                .environmentObject(flow)
                .environmentObject(NotificationManager.shared)
                .environmentObject(ColorManager.shared)
                .onOpenURL { url in
                    print("Just received a URL: \(url)")
                    if url.absoluteString.localizedStandardContains("share"){
                        guard let range = url.absoluteString.range(of: "share/") else { return }
                        NotificationManager.shared.reminderID = String(url.absoluteString[range.upperBound...])
                        NotificationManager.shared.sharedReminder = true

                    }
                    else if url.absoluteString.localizedStandardContains("url") {
                        NotificationManager.shared.linkReminder = true
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
