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
    @Published var version = "1.3"


    static let shared = NotificationManager()

    private init() {}


    
    // Schedules 7 days of notifications for up to 3 pinned reminders
    // Smart clearing: Only removes future notifications, keeps today's intact
    func scheduleBulkNotifications(for reminders: [Reminder]) {
        let center = UNUserNotificationCenter.current()
        
        // Step 1: Smart clear - only remove notifications for dates AFTER today
        smartClearFutureNotifications()
        
        // Step 2: Check authorization
        center.getNotificationSettings { [weak self] settings in
            guard let self = self else { return }
            
            if settings.authorizationStatus == .authorized {
                self.scheduleNotifications(for: reminders)
            } else {
                // Request authorization if not granted
                center.requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                    if success {
                        self.scheduleNotifications(for: reminders)
                    } else if let error {
                        print("❌ Notification authorization failed: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    /// Smart clearing: Only removes notifications scheduled for dates AFTER today
    /// This preserves today's notifications so they can still fire
    private func smartClearFutureNotifications() {
        let center = UNUserNotificationCenter.current()
        let today = Calendar.current.startOfDay(for: Date())
        
        center.getPendingNotificationRequests { requests in
            for request in requests {
                if let trigger = request.trigger as? UNCalendarNotificationTrigger,
                   let triggerDate = trigger.nextTriggerDate() {
                    
                    let triggerDay = Calendar.current.startOfDay(for: triggerDate)
                    
                    // Only remove if scheduled for a day AFTER today
                    if triggerDay > today {
                        center.removePendingNotificationRequests(withIdentifiers: [request.identifier])
                    }
                }
            }
            
            // Log remaining notifications
            center.getPendingNotificationRequests { remainingRequests in
                print("🗑️ Smart clear complete. Remaining notifications: \(remainingRequests.count)")
            }
        }
    }
    
    // Internal method that does the actual scheduling
    private func scheduleNotifications(for reminders: [Reminder]) {
        let center = UNUserNotificationCenter.current()
        let notificationsPerDay = min(3, reminders.count) // Up to 3 per day
        
        // Take up to 3 reminders
        let selectedReminders = Array(reminders.prefix(3))
        
        print("📅 Scheduling notifications for \(selectedReminders.count) reminders over 7 days (including today)")
        
        let now = Date()
        let currentHour = Calendar.current.component(.hour, from: now)
        
        // Schedule for each day (0 = today, 1 = tomorrow, ... 6 = 6 days from now)
        for dayOffset in 0...6 {
            guard let targetDate = Calendar.current.date(byAdding: .day, value: dayOffset, to: now) else {
                continue
            }
            
            // Get random times for this day (morning, afternoon, evening spread)
            let allTimes = getRandomTimesForDay(count: notificationsPerDay)
            
            // For today (dayOffset 0), filter out times that have already passed
            let validTimes: [(hour: Int, minute: Int)]
            if dayOffset == 0 {
                validTimes = allTimes.filter { $0.hour > currentHour }
                if validTimes.isEmpty {
                    print("⏭️ Skipping today - all time slots have passed")
                    continue
                }
                print("📍 Today: Scheduling \(validTimes.count) remaining notifications")
            } else {
                validTimes = allTimes
            }
            
            // Schedule notification for each reminder at different times
            for (index, reminder) in selectedReminders.enumerated() {
                guard index < validTimes.count else { break }
                
                let time = validTimes[index]
                var dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: targetDate)
                dateComponents.hour = time.hour
                dateComponents.minute = time.minute
                
                let content = UNMutableNotificationContent()
                content.title = "Quick Reminder"
                content.subtitle = reminder.title + "\n" + reminder.text
                content.sound = .default
                content.userInfo = ["reminderID": reminder.id.uuidString]
                
                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
//                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60, repeats: false)

                // Unique identifier: reminderID_dayOffset_index
                let identifier = "\(reminder.id.uuidString)_day\(dayOffset)_\(index)"
                let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
                
                center.add(request) { error in
                    if let error = error {
                        print("❌ Failed to schedule notification: \(error.localizedDescription)")
                    } else {
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateStyle = .short
                        dateFormatter.timeStyle = .short
                        if let scheduledDate = Calendar.current.date(from: dateComponents) {
                            print("✅ Scheduled: \(reminder.title) at \(dateFormatter.string(from: scheduledDate))")
                        }
                    }
                }
            }
        }
        
        // Log total scheduled
        center.getPendingNotificationRequests { requests in
            print("📊 Total pending notifications: \(requests.count)")
        }
    }
    
    /// Generates random times spread throughout the day (morning, afternoon, evening)
    private func getRandomTimesForDay(count: Int) -> [(hour: Int, minute: Int)] {
        var times: [(hour: Int, minute: Int)] = []
        
        // Define time windows
        let morning = 7...11    // 7am - 11am
        let afternoon = 12...17 // 12pm - 5pm
        let evening = 18...21   // 6pm - 9pm
        
        let windows = [morning, afternoon, evening]
        
        for i in 0..<min(count, 3) {
            let window = windows[i]
            let hour = Int.random(in: window)
            let minute = Int.random(in: 0...59)
            times.append((hour, minute))
        }
        
        return times.sorted { $0.hour < $1.hour } // Sort chronologically
    }
    
    /// Clears all pending notifications (useful for debugging or when user unpins all)
    func clearAllNotifications() {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
    }

    
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
