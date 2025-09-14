//
//  NotificationManager.swift
//  BetterSelf
//
//  Created by Adam Damou on 14/09/2025.
//


import SwiftUI
import SwiftData
import UserNotifications

// Shared Notification Manager
class NotificationManager: ObservableObject {
    @Environment(\.modelContext) var modelContext
    @Query(filter: #Predicate<Reminder> {
        $0.isChecked == true
    }, sort: \Reminder.date) var reminders: [Reminder]

    var unlockedPinnedReminders: [Reminder]{
        reminders.filter{ $0.pinned && ($0.isLocked == false) }
    }

    @Published var reminder: Reminder?
    @Published var shouldNavigateToReminder = false

    static let shared = NotificationManager()

    private init() {}

    func handleNotification(reminder: Reminder) {
        self.reminder = reminder
        shouldNavigateToReminder = true
    }
    func selectReminder() -> String{
        if let reminder = unlockedPinnedReminders.randomElement() {
            DispatchQueue.main.async {
                self.reminder = reminder
            }

        }
        else {
            DispatchQueue.main.async {
                self.reminder = self.reminders.randomElement() ?? .example
            }
        }
        if let reminder = reminder {
            return reminder.title + "\n" + reminder.text
        }
        return ""
    }

    func addNotification() {
        let center = UNUserNotificationCenter.current()

        let addRequest = {
            let content = UNMutableNotificationContent()
            content.title = "Quick Reminder"

            content.subtitle = self.selectReminder()

            content.sound = UNNotificationSound.default

            //            var dateComponents = DateComponents()
            //            dateComponents.hour = 9
            //            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)

            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60, repeats: true)

            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            center.add(request)
        }

        center.getNotificationSettings { settings in
            if settings.authorizationStatus == .authorized {
                addRequest()
            } else {
                center.requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                    if success {
                        addRequest()
                    } else if let error {
                        print(error.localizedDescription)
                    }
                }
            }
        }
    }

}
