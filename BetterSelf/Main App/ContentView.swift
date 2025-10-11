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

    @StateObject var tutorialManager = TutorialManager.shared

    @Environment(\.colorScheme) var scheme
    @StateObject var color = ColorManager.shared

    @State private var welcome = false

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
            .sheet(isPresented: $welcome){
                WelcomeView()
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
                checkIfWelcome()
                signInAnonymously()
                scheduleBulkNotifications()
            }
        }


    func checkIfWelcome(){
//        if UserDefaults.standard.bool(forKey: "Welcome \(notificationManager.version)") {
//        }
//        else {
//            welcome = true
//            UserDefaults.standard.set(true, forKey: "Welcome \(notificationManager.version)")
//        }
        welcome = true
    }


    
    // Schedules 7 days of notifications every time the app launches
    // Always reschedules to keep content fresh with current pinned reminders
    private func scheduleBulkNotifications() {
        // Determine which reminders to use
        let remindersToSchedule: [Reminder]
        
        if unlockedPinnedReminders.isEmpty {
            // No pinned reminders - pick up to 3 random ones
            remindersToSchedule = Array(unlockedReminders.shuffled().prefix(3))
        } else {
            // Use pinned reminders (up to 3)
            remindersToSchedule = Array(unlockedPinnedReminders.prefix(3))
        }
        if !remindersToSchedule.isEmpty {
            NotificationManager.shared.scheduleBulkNotifications(for: remindersToSchedule)
        } else {
            print("⚠️ No reminders available to schedule notifications")
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
