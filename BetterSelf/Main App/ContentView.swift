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
    @AppStorage("lastScheduled") private var lastScheduledDate: Date = Date.distantPast

    @Environment(\.modelContext) var modelContext
    @Query(filter: #Predicate<Reminder> {
        $0.isChecked == true
    }, sort: \Reminder.date) var reminders: [Reminder]

    var unlockedPinnedReminders: [Reminder]{
        reminders.filter{ $0.pinned && ($0.isLocked == false) }
    }

    var body: some View {
        TabView {
            FolderView(notifReminder: $notifReminder)
                .tabItem{
                    Label("Reminders", systemImage: "list.bullet")

                }
                .toolbarBackground(Color.purpleOverlayGradient, for: .bottomBar, .navigationBar)


            ProblemSolverView()
                .tabItem{
                    Label("ProblemSolver", systemImage: "lightbulb.fill")
                        .imageScale(.small)

                }
                .toolbarBackground(Color.purpleOverlayGradient, for: .tabBar, .bottomBar, .navigationBar)

            ExploreView()
                .tabItem{
                    Label("Explore", systemImage: "magnifyingglass")
                }
                .toolbarBackground(Color.purpleOverlayGradient, for: .tabBar, .bottomBar, .navigationBar)

            SettingsView()
                .tabItem{
                    Label("Settings", systemImage: "gear")
                }
                .toolbarBackground(Color.purpleOverlayGradient, for: .tabBar, .bottomBar, .navigationBar)
        }
        .onChange(of: notificationManager.shouldNavigateToReminder) { _, shouldNavigate in
            if shouldNavigate, let reminder = notificationManager.reminder {
                notifReminder = reminder
                notificationManager.shouldNavigateToReminder = false
            }
        }
        .onAppear {
            signInAnonymously()
            checkAndScheduleDailyNotification()
        }
    }
    private func checkAndScheduleDailyNotification() {
        let today = Calendar.current.startOfDay(for: Date())
        let lastScheduled = Calendar.current.startOfDay(for: lastScheduledDate)

        // If we haven't scheduled today, schedule tomorrow's notification
        if !Calendar.current.isDate(lastScheduled, inSameDayAs: today) {
            NotificationManager.shared.addNotification(selectReminder())
            lastScheduledDate = today
        }
    }
    
    func selectReminder() -> Reminder{
        if let reminder = unlockedPinnedReminders.randomElement() {
            return reminder
        }
        else {
            return reminders.randomElement() ?? .example
        }
    }
    private func signInAnonymously() {

        Auth.auth().signInAnonymously { result, error in
            if let error = error {
                print("Authentication failed: \(error.localizedDescription)")
            } else if let user = result?.user {
                print("Signed in successfully, uid: \(user.uid)")
            }
        }
    }
}

#Preview {
    ContentView()
}
