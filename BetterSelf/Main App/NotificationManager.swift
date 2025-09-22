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
    

    @Published var reminderID: String?
    @Published var shouldNavigateToReminder = false
    @Published var sharedReminder = false
    @Published var widgetReminder = false
    @Published var widgetReminderId: String?



    static let shared = NotificationManager()



    private init() {}

    

    
    func addNotification(_ reminder: Reminder) {
        let center = UNUserNotificationCenter.current()

        let addRequest = {
            let content = UNMutableNotificationContent()
            content.title = "Quick Reminder"

            content.subtitle = reminder.title + "\n" + reminder.text

            content.sound = UNNotificationSound.default

            let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
            var dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: tomorrow)
            dateComponents.hour = Int.random(in: 7...21)
            dateComponents.minute = Int.random(in: 0...59)

            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)

//            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60, repeats: false)

            let request = UNNotificationRequest(identifier: reminder.id.uuidString, content: content, trigger: trigger)
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
