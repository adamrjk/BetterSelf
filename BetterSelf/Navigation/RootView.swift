//
//  RootView.swift
//  BetterSelf
//
//  Created by Adam Damou on 18/11/2025.
//
import SwiftUI

struct RootView: View {
    @State var flow = AppFlow()

    var body: some View {
        NavigationStack(path: $flow.path) {
            ContentView()
        }
        .navigationDestination(for: FolderDestination.self) { _ in
            FolderView()
        }
        .navigationDestination(for: HomeDestination.self) { dest in
            if dest.folder.name.isEmpty {
                HomeView()
            }
            else {
                HomeView(folder: dest.folder)
            }
        }
        .navigationDestination(for: ReminderDestination.self) { dest in
            ReminderView(reminder: dest.reminder)
        }
        .sheet(item: $flow.activeSheet) { sheet in
            switch sheet {
            case .addReminder(let reminder):
                AddReminderView(reminder: reminder)
                    .onDisappear { flow.dismissSheet() }
            case .settings:
                SettingsView()
                    .onDisappear {
                        flow.dismissSheet()

                    }
            }
        }
        .environment(flow)
    }
}


