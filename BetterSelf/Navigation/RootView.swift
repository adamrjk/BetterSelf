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
            FolderView()
        }
        .navigationDestination(for: FolderDestination.self) { _ in
            HomeView()
        }
        .navigationDestination(for: HomeDestination.self) { _ in
            ReminderView() // or a list of reminders
        }
        .navigationDestination(for: ReminderDestination.self) { dest in
            ReminderView(reminderID: dest.reminderID)
        }
        .sheet(item: $flow.activeSheet) { sheet in
            switch sheet {
            case .addReminder(let id):
                AddReminderView(reminderID: id)
                    .onDisappear { flow.dismissSheet() }
            case .settings:
                SettingsView()
                    .onDisappear { flow.dismissSheet() }
            }
        }
        .environment(flow)
    }
}

#Preview {
    RootView()
}
