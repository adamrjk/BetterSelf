//
//  ContentView.swift
//  BetterSelf
//
//  Created by Adam Damou on 15/08/2025.
//

import FirebaseCore
import FirebaseAuth
import SwiftData
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var notificationManager: NotificationManager
    @State private var notifReminder: Reminder?

    @Environment(\.modelContext) var modelContext
    @Query(filter: #Predicate<Reminder> {
        $0.isChecked == true
    }, sort: \Reminder.date) var reminders: [Reminder]

    var unlockedReminders: [Reminder] {
        reminders.filter{ $0.isLocked == false}
    }

    var unlockedPinnedReminders: [Reminder]{
        unlockedReminders.filter{ $0.pinned }
    }
    
    @State private var tabPage: Int = 0

    @Environment(\.colorScheme) var scheme
    @StateObject var color = ColorManager.shared

    var body: some View {
        TabView(selection: $tabPage) {



            FolderView(notifReminder: $notifReminder)
                .tag(0)
                .tabItem{
                    Label("Reminders", systemImage: "list.bullet")

                }
                .toolbarBackground(color.overlayGradient(scheme), for: .bottomBar, .navigationBar)


            ProblemSolverView()
                .tag(1)
                .tabItem{
                    Label("ProblemSolver", systemImage: "lightbulb.fill")
                        .imageScale(.small)

                }
                .toolbarBackground(color.overlayGradient(scheme), for: .tabBar, .bottomBar, .navigationBar)
            
//            ExploreView()
//                .tabItem{
//                    Label("Explore", systemImage: "magnifyingglass")
//                }
//                .toolbarBackground(color.overlayGradient(scheme), for: .tabBar, .bottomBar, .navigationBar)
//
//            SettingsView()
//                .tabItem{
//                    Label("Settings", systemImage: "gear")
//                }
//                .toolbarBackground(color.overlayGradient(scheme), for: .tabBar, .bottomBar, .navigationBar)
        }
        .onChange(of: notificationManager.shouldNavigateToReminder) { _, shouldNavigate in
            if shouldNavigate, let reminderID = notificationManager.reminderID {
                let reminder = reminders.first(where: {reminder in
                    reminder.id.uuidString == reminderID
                })
                tabPage = 0
                notifReminder = reminder
                notificationManager.shouldNavigateToReminder = false
            }
        }
        .onChange(of: notificationManager.sharedReminder){
            if notificationManager.sharedReminder {
                if let url = UserDefaults(suiteName: "group.adam.betterself")?.value(forKey: "incomingURL") as? String {
                    UserDefaults(suiteName: "group.adam.betterself")?.removeObject(forKey: "incomingURL")
                    guard let range = url.range(of: "url=") else { return }
                    let link = String(url[range.upperBound...])  // everything after "url="
                    let reminder = Reminder(title: "", text: "", link: link)
                    modelContext.insert(reminder)
                    reminder.isChecked = true
                    reminder.type = .TimeLessLetter
                    reminder.isShared = true
                    tabPage = 0
                    notifReminder = reminder
                    notificationManager.sharedReminder = false



                }

                else {
                    notificationManager.sharedReminder = false
                }
            }
        }
        .onChange(of: notificationManager.widgetReminder){
            if notificationManager.widgetReminder {
                let id = notificationManager.widgetReminderId
                let reminder = reminders.first(where: { reminder in
                    reminder.id.uuidString == id
                })
                tabPage = 0
                notifReminder = reminder
                notificationManager.widgetReminder = false
            }
        }

        .onAppear {
            signInAnonymously()
            checkAndScheduleDailyNotification()
        }
    }
    private func checkAndScheduleDailyNotification() {
        //Let's schedule notifications on each of the pinned reminders.

        let today = Calendar.current.startOfDay(for: Date())

        let lastScheduled = Calendar.current.startOfDay(for: getLastScheduledDate())

        // If we haven't scheduled today, schedule tomorrow's notification
        if !Calendar.current.isDate(lastScheduled, inSameDayAs: today) {
            if unlockedPinnedReminders.isEmpty {
                if let randomReminder = unlockedReminders.randomElement() {
                    NotificationManager.shared.addNotification(randomReminder)
                }
            }
            else {
                unlockedPinnedReminders.forEach{ reminder in
                    NotificationManager.shared.addNotification(reminder)
                }
            }
            UserDefaults().set(today , forKey: "lastScheduledDate")

        }
    }
    func getLastScheduledDate() -> Date {
        if let date = UserDefaults().value(forKey: "lastScheduledDate") as? Date{
            return date
        }
        else {
            UserDefaults().set(Date.distantPast, forKey: "lastScheduledDate")
            return .distantPast
        }

    }




    private func signInAnonymously() {

        Auth.auth().signInAnonymously { _ , error in
            if let error = error {
                print("Authentication failed: \(error.localizedDescription)")
            }
        }
    }
}

#Preview {
    ContentView()
}
