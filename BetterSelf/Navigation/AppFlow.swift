//
//  AppFlow.swift
//  BetterSelf
//
//  Created by Adam Damou on 18/11/2025.
//

import SwiftUI

@Observable
class AppFlow {
    var path = NavigationPath()          // push-style navigation
    var activeSheet: SheetDestination?   // sheet-style navigation

    func goToFolder() {
        path.append(FolderDestination())
    }

    func goToHome(_ folder: Folder) {
        path.append(HomeDestination(folder: folder))
    }

    func goToReminder(_ reminder: Reminder) {
        path.append(ReminderDestination(reminder: reminder))
    }

    func goBack() {
        if !path.isEmpty { path.removeLast() }
    }

    func addReminderSheet(_ reminder: Reminder) {
        activeSheet = .addReminder(reminder)
    }

    func addFolderSheet(_ folder: Folder){
        activeSheet = .addFolder(folder)

    }

    func settingsSheet() {
        activeSheet = .settings
    }

    func cameraSheet(){
        activeSheet = .camera
    }

    func dismissSheet() {
        activeSheet = nil
    }
}
