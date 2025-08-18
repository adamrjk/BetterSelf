//
//  ContentView.swift
//  BetterSelf
//
//  Created by Adam Damou on 15/08/2025.
//

import SwiftData
import SwiftUI

struct ContentView: View {

    var body: some View {
        TabView {
            HomeView()
                .tabItem{
                    Label("Reminders", systemImage: "list.bullet")
                }
                .toolbarBackground(Color.purpleOverlayGradient, for: .tabBar, .bottomBar, .navigationBar)


            ProblemSolverView()
                .tabItem{
                    Label("ProblemSolver", systemImage: "lightbulb.min.badge.exclamationmark.fill")
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
        





    }
}

#Preview {
    ContentView()
}
