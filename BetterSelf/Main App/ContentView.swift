//
//  ContentView.swift
//  BetterSelf
//
//  Created by Adam Damou on 15/08/2025.
//

import SwiftData
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var notificationManager: NotificationManager
    @State private var notifReminder: Reminder?

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
    }
}

#Preview {
    ContentView()
}
