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
    @EnvironmentObject var flow: AppFlow
    @EnvironmentObject var notificationManager: NotificationManager
    @StateObject var firestore = FirestoreService.shared

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
    

    @Environment(\.colorScheme) var scheme
    @EnvironmentObject var color: ColorManager


    @StateObject var tutorialManager = TutorialManager.shared

    @State private var welcome = false

    @State private var preferredScheme: ColorScheme?

    var body: some View {
            TabView(selection: $flow.selectedTab) {
                NavigationStack(path: $flow.feedPath){
                    FeedView()

                }
                .tag(AppFlow.Tab.feed)
                .tabItem{
                    Label("The Lab", systemImage: "flask.fill")
                }
                .toolbarBackground(color.overlayGradient(scheme), for: .tabBar, .bottomBar, .navigationBar)


                NavigationStack(path: $flow.insightsPath) {
                        FolderView()
                            .navigationDestination(InsightsDestination.self)
                    }
                    .tag(AppFlow.Tab.reminders)
                    .tabItem{
                        Label("Insights", systemImage: "lightbulb.fill")
                    }
                    .toolbarBackground(color.overlayGradient(scheme), for: .bottomBar, .navigationBar)



//                NavigationStack(path: $flow.solverPath) {
//                    ProblemSolverView()
//                }
//                    .tag(AppFlow.Tab.solver)
//                    .tabItem{
//                        Label("ProblemSolver", systemImage: "lightbulb.fill")
//                            .imageScale(.small)
//                        
//                    }
//                    .toolbarBackground(color.overlayGradient(scheme), for: .tabBar, .bottomBar, .navigationBar)
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
            .sheet(item: $flow.activeSheet, onDismiss: flow.onDismiss){ sheet in
                sheet
            }
            .tint(color.button(scheme))
            .sheet(isPresented: $welcome){
                if #available(iOS 18.0, *) {
                    WelcomeView()
                        .presentationDetents([.height(800)])
                        .presentationSizing(.page)
                        .presentationDragIndicator(.visible)
                } else {
                    // iOS 17 fallback
                    WelcomeView()
                        .presentationDetents([.large])
                        .presentationDragIndicator(.visible)
                }
            }
            .onChange(of: notificationManager.shouldNavigateToReminder) { _, shouldNavigate in
                if shouldNavigate {
                    handleNotificationNavigation()
                }
            }
            .onChange(of: notificationManager.linkReminder) {
                if notificationManager.linkReminder {
                    handleSharedLinkNavigation()
                }
            }
            .onChange(of: notificationManager.sharedReminder){
                if notificationManager.sharedReminder{
                    Task { @MainActor in
                      await handleSharedReminderCreation()
                    }
                }
            }
            .onChange(of: notificationManager.widgetReminder) {
                if notificationManager.widgetReminder {
                    handleWidgetNavigation()
                }
            }
            .onAppear {
                flow.openAllReminders()
                flow.configure(with: { modelContext })
                checkIfWelcome()
                getSchemeAndTheme()
                signInAnonymously()
                scheduleBulkNotifications()
            }
            .onChange(of: flow.selectedTab) { _, newValue in
                let tabName = (newValue == .reminders) ? "reminders" : "problem_solver"
                AnalyticsService.log("tab_selected", params: [
                    "tab": tabName
                ])
            }
        }

    func getSchemeAndTheme(){
        if let modeStr = UserDefaults.standard.value(forKey: "ThemeMode") as? String,
            let mode = ThemeMode(rawValue: modeStr) {
                AppearanceController.shared.apply(mode)
        }
        else {
            UserDefaults.standard.set("Sync Theme", forKey: "ThemeMode")
            AppearanceController.shared.apply(.auto)
        }

        if let themeStr = UserDefaults.standard.value(forKey: "Theme") as? String,
           let theme = Theme(rawValue: themeStr) {
            color.changeTheme(theme)
        }
        else {
            color.changeTheme(.yellowPurple)
            UserDefaults.standard.set(Theme.yellowPurple.rawValue, forKey: "Theme")

        }



    }
    func checkIfWelcome(){
        if UserDefaults.standard.bool(forKey: "Welcome \(notificationManager.version)") {
        }
        else {
            welcome = true
            UserDefaults.standard.set(true, forKey: "Welcome \(notificationManager.version)")
            UserDefaults.standard.set("AlternateIconSet1", forKey: "CurrentAppIcon")
        }
    }
    
    // MARK: - Navigation Handlers
    
    private func handleNotificationNavigation() {
        guard let reminderID = notificationManager.reminderID else { return }
        
        guard let reminder = reminders.first(where: { reminder in
            reminder.id.uuidString == reminderID
        }) else { return }
        
        flow.openReminder(reminder)
        notificationManager.shouldNavigateToReminder = false
    }


    private func handleSharedReminderCreation() async {
        if let docId = notificationManager.reminderID,
           let reminder = try? await firestore.receiveReminder(docId) {

            modelContext.insert(reminder)
            reminder.isChecked = true
            flow.openReminder(reminder)
            notificationManager.sharedReminder = false

        }


    }


    private func handleSharedLinkNavigation() {
        guard let url = UserDefaults(suiteName: "group.adam.betterself")?.value(forKey: "incomingURL") as? String else {
            notificationManager.sharedReminder = false
            return
        }
        
        UserDefaults(suiteName: "group.adam.betterself")?.removeObject(forKey: "incomingURL")
        guard let range = url.range(of: "url=") else { return }
        let link = String(url[range.upperBound...])
        
        let reminder = Reminder(title: "", text: "", link: link)
        modelContext.insert(reminder)
        reminder.isChecked = true
        reminder.type = .TimeLessLetter
        reminder.isShared = true
        
        flow.openReminder(reminder)
        notificationManager.sharedReminder = false
    }

    private func handleWidgetNavigation() {
        guard let id = notificationManager.widgetReminderId else {
            notificationManager.widgetReminder = false
            return
        }
        
        guard let reminder = reminders.first(where: { reminder in
            reminder.id.uuidString == id
        }) else { return }
        
        flow.openReminder(reminder)
        notificationManager.widgetReminder = false
    }
    
    // Schedules 7 days of notifications every time the app launches (starting from tomorrow)
    // Keeps today's notifications intact to avoid duplicates
    // Always reschedules tomorrow onwards to keep content fresh with current pinned reminders
    private func scheduleBulkNotifications() {
        let remindersToSchedule: [Reminder]
        
        if unlockedPinnedReminders.isEmpty {
            remindersToSchedule = Array(unlockedReminders.shuffled().prefix(3))
        } else {
            remindersToSchedule = Array(unlockedPinnedReminders.prefix(3))
        }
        
        if !remindersToSchedule.isEmpty {
            NotificationManager.shared.scheduleBulkNotifications(for: remindersToSchedule)
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
extension ContentView {
    func fetchFolder(_ id: PersistentIdentifier) -> Folder? {
        let descriptor = FetchDescriptor<Folder>(predicate: #Predicate<Folder> { $0.persistentModelID == id })
        print("Trying to Fetch")
        return try? modelContext.fetch(descriptor).first
    }

    func fetchReminder(_ id: PersistentIdentifier) -> Reminder? {
        let descriptor = FetchDescriptor<Reminder>(predicate: #Predicate<Reminder> { $0.persistentModelID == id })
        let reminder = try? modelContext.fetch(descriptor).first
        print("REMINDER: \(reminder?.title ?? "")")
        return reminder
    }
}

extension View {
    @ViewBuilder
    func preferredColorSchemeIfSet(_ scheme: ColorScheme?) -> some View {
        if let scheme { self.preferredColorScheme(scheme) } else { self }
    }
}


#Preview {
    ContentView()
}
