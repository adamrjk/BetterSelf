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
        case feed
    }

    @Published var selectedTab: Tab = .feed

    // Per-tab navigation paths
    @Published var insightsPath = NavigationPath()
    @Published var feedPath = NavigationPath()
    @Published var activeSheet: SheetDestination?
    private var sheet: SheetDestination = .settings

    

    private var camStuff: (URL, Bool)?


    private var isConfigured = false
    private var contextProvider: (() -> ModelContext)?
    func configure(with provider: @escaping () -> ModelContext) {
        guard !isConfigured else { return }
        contextProvider = provider
        isConfigured = true
        reminderService = ReminderService(provider: provider)
        folderService = FolderService(provider: provider)
    }


    var reminderService: ReminderService?
    var folderService: FolderService?



    // MARK: - Reminders tab navigation
    func push(_ route: InsightsDestination) {
        insightsPath.append(route)
    }

    func popInsights() {
        if !insightsPath.isEmpty {
            insightsPath.removeLast()
        }
    }

    func shareSheet(_ url: URL){
        sheet(.share(url))

    }
    func sheet(_ dest: SheetDestination){
        activeSheet = dest
        sheet = dest
    }

    func openReminder(_ reminder: Reminder){
        push(.reminder(reminder))
    }

    func openFolder(_ folder: Folder){
        push(.folder(folder))
    }


    func openAllReminders(){
        push(.allReminders)
    }


    func cameraSheet(){
        activeSheet = .camera(RecordingHandler(onVideoRecorded: { url, front in
            self.camStuff = (url, front)
            self.activeSheet = nil
            self.activeSheet = .titleSheet
        }))

    }

    func addReminderSheet(){ addReminderSheet(nil) }

    func addReminderSheet(_ folder: Folder?){

        AnalyticsService.log(AnalyticsService.EventName.buttonTapped, params: [
            "button": "plus_overlay",
            "view": "HomeView"
        ])
        let reminder = Reminder(title: "", text: "", link: "", folder: folder)
        if let provider = contextProvider {
            let ctx: ModelContext = provider()
             ctx.insert(reminder)
            sheet(.addReminder(reminder))
        }

        if TutorialManager.shared.inTutorial {
            TutorialManager.shared.handleTargetViewClick(target: "PlusButton")
        }

    }

    func addReminderSheet(_ reminder: Reminder){
        sheet(.addReminder(reminder))
    }
    func addFolderSheet(_ folder: Folder){
        sheet(.addFolder(folder))
    }

    func settingSheet(){
        sheet(.settings)
    }

    func onDismiss() {
        switch sheet {
        case .addReminder(let reminder):
            reminderService?.deleteEmptyReminder(reminder)
        case .addFolder(let folder):
            folderService?.deleteEmptyFolder(folder)
        case .settings, .camera, .share, .titleSheet:
            break
        }
    }

    func saveReminder(_ title: String) {
        if let camStuff = camStuff {
            reminderService?.saveReminder(title, camStuff.0, camStuff.1)
        }
    }





    // MARK: - Deep links / notifications
    func handleDeepLink(_ url: URL) {
        // Map URL to a route. Keep simple here; ContentView currently handles mapping.
        // This method exists for future centralization.
    }
}
