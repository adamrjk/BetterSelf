//
//  AppFlow.swift
//  BetterSelf
//
//  Created by Adam Damou on 18/11/2025.
//

import SwiftUI
import SwiftData

@MainActor
final class AppFlow: ObservableObject {
    enum Tab: Hashable {
        case reminders
        case solver
    }

    @Published var selectedTab: Tab = .reminders

    // Per-tab navigation paths
    @Published var insightsPath = NavigationPath()
    @Published var solverPath = NavigationPath()
    @Published var activeSheet: SheetDestination?


    // MARK: - Reminders tab navigation
    func push(_ route: InsightsDestination) {
        insightsPath.append(route)
    }

    func popInsights() {
        if !insightsPath.isEmpty {
            insightsPath.removeLast()
        }
    }

//    func openReminder(id: PersistentIdentifier) {
//        push(.reminder(id: id))
//    }

    func shareSheet(_ url: URL){
        activeSheet = .share(url)
    }

    func openReminder(_ reminder: Reminder){
//        push(.reminder(id: reminder.persistentModelID))
        push(.reminder(reminder))
    }

    func openFolder(_ folder: Folder){
//        push(.folder(id: folder?.persistentModelID))
        push(.folder(folder))
    }

//    func openFolder(_ id: PersistentIdentifier?) {
//        push(.folder(id: id))
//    }

    func openAllReminders(){
        push(.allReminders)
    }

    func cameraSheet(){
        activeSheet = .camera
    }

    func addReminderSheet(_ reminder: Reminder){
        activeSheet = .addReminder(reminder)
    }
    func addFolderSheet(_ folder: Folder){
        activeSheet = .addFolder(folder)
    }

    func settingSheet(){
        activeSheet = .settings
    }


    // MARK: - Deep links / notifications
    func handleDeepLink(_ url: URL) {
        // Map URL to a route. Keep simple here; ContentView currently handles mapping.
        // This method exists for future centralization.
    }
}
