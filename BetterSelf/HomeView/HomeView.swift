//
//  HomeView.swift
//  BetterSelf
//
//  Created by Adam Damou on 15/08/2025.
//

import AVFoundation
import SwiftUI
import SwiftData



struct HomeView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    @Environment(\.editMode) var editMode

    @EnvironmentObject var flow: AppFlow


    @Environment(\.colorScheme) var scheme
    @EnvironmentObject var color: ColorManager

    let folder: Folder?
    let onSelectReminder: ((Reminder) -> Void)?
    let onToggleSidebar: (() -> Void)?

    @Query var reminders: [Reminder]

    @StateObject private var uploadManager = UploadManager.shared

    @State private var searchText = ""
    @State private var addReminder = false
    @State private var selectedReminder: Reminder?
    @State private var remindersToMove: [Reminder]?
    @State private var newReminder: Reminder?
    @State private var videoRecorder = false
    @State private var refuseLoading = false
    @State private var moveToFolder = false

    @State private var deleteAlert = false
    @State private var reminderToDelete: Reminder?

    private var reminderService: ReminderService {
        ReminderService(provider: { modelContext })
    }

    
    var unlockedReminders: [Reminder]{
        reminders.filter{
            $0.isLocked == false
        }
    }


    var filteredReminders: [Reminder] {
        if searchText.isEmpty {
            unlockedReminders
        } else {
            unlockedReminders.filter { $0.title.localizedStandardContains(searchText) }
        }
    }

    var sortedReminders: [Reminder]{
        switch sorting {
        case .dateOld:
            filteredReminders.sorted{ $0.date < $1.date}
        case .dateNew:
            filteredReminders.sorted{ $0.date > $1.date}
        case .name:
            filteredReminders.sorted{ $0.title < $1.title}
        }
    }
    @State private var sorting: Sorting


    @State private var selection = Set<Reminder.ID>()
    @State private var recordedVideoURL: URL?
    @State private var isFront: Bool?
    @State private var videoRecorded = false
    @State private var title = ""

    var body: some View {

        ZStack {
            color.mainGradient(scheme)
                .ignoresSafeArea()

            color.overlayGradient(scheme)
                .ignoresSafeArea()
            Group {
                if reminders.isEmpty {
                    VStack {
                        Text("Looks like you have no Reminders")
                            .font(.headline)
                            .multilineTextAlignment(.center)
                            .padding()
                        CleanText("Click the plus on the top right corner to add a new Reminder")
                            .multilineTextAlignment(.center)
                    }
                }
                else {
                    HomeListContent(
                        folder: folder,
                        mode: .phone,
                        searchText: $searchText,
                        refuseLoading: $refuseLoading,
                        selection: $selection,
                        sorting: sorting,
                        onSelectReminder: { reminder in
                            if TutorialManager.shared.inTutorial {
                                TutorialManager.shared.handleTargetViewClick(target: ReminderService.isFirstId(reminder))
                            }
                            if let handler = onSelectReminder, UIDevice.current.userInterfaceIdiom == .pad {
                                handler(reminder)
                            } else {
                                flow.openReminder(reminder)
                            }
                        },
                        onRequestDelete: { reminder in
                            reminderToDelete = reminder
                            deleteAlert.toggle()
                        },
                        onRequestMove: { reminder in
                            remindersToMove = [reminder]
                            moveToFolder.toggle()
                        },
                        onShare: { reminder in
                            AnalyticsService.log(AnalyticsService.EventName.shareTapped, params: [
                                "id": reminder.id.uuidString,
                                "type": reminder.type.rawValue
                            ])
                            Task {
                                do {
                                    flow.shareSheet(ReminderService.getLink(reminder))
                                    _ = try await FirestoreService.shared.storeReminder(reminder)
                                } catch {
                                    print("Share prepare failed: \(error)")
                                }
                            }
                        }
                    )

                }
            }

//            if !selection.isEmpty {
//                VStack {
//                    Spacer()
//                    HStack {
//                        Button("Delete"){
//                            AnalyticsService.log(AnalyticsService.EventName.buttonTapped, params: [
//                                "button": "delete_overlay",
//                                "view": "HomeView"
//                            ])
//                            deleteAlert.toggle()
//                        }
//                        .adaptiveGlass(scheme)
//                        .buttonStyle(.plain)
//                        Spacer()
//                        Button("Move"){
//                            AnalyticsService.log(AnalyticsService.EventName.buttonTapped, params: [
//                                "button": "move_overlay",
//                                "view": "HomeView"
//                            ])
//                            move()
//                        }
//                            .adaptiveGlass(scheme)
//                            .buttonStyle(.plain)
//                    }
//                    .padding(.horizontal, 5)
//                }
//
//
//            }
        }
        .onAppear{
            AnalyticsService.logScreenView(screenName: "Home", screenClass: "HomeView")

            if TutorialManager.shared.inTutorial {
                TutorialManager.shared.viewId("Home")
                TutorialManager.shared.startTutorial("Home")
            }

            sorting = folder?.sorting ?? ReminderService.loadData()

        }
        .onChange(of: TutorialManager.shared.currentDone){
            if TutorialManager.shared.inTutorial && TutorialManager.shared.currentDone {
                TutorialManager.shared.viewId("Home")
                TutorialManager.shared.startTutorial("Home")
            }
        }
        .onChange(of: TutorialManager.shared.currentStepIndex){
            if TutorialManager.shared.inTutorial && TutorialManager.shared.currentViewId == "Home" && TutorialManager.shared.currentStepIndex == 2 {
                sorting = .dateNew
            }
        }
//        .floatingPlusButton {
//            if editMode?.wrappedValue == .inactive {
//                flow.addReminderSheet(folder)
//            }
//        }
//        .toolbar {
//            ToolbarItem(placement: .topBarTrailing) {
//                Menu {
//                    Menu {
//
//                        Picker("Sort", selection: $sorting) {
//                            Text("Newest First")
//                                .tag( Sorting.dateNew)
//
//                            Text("Oldest First")
//                                .tag(Sorting.dateOld)
//                            Text("Title")
//                                .tag(Sorting.name)
//
//                        }
//                    }label: {
//                        HStack {
//                            Image(systemName: "arrow.up.arrow.down")
//                                .font(.subheadline)
//                                .foregroundStyle(color.button(scheme))
//                                .padding(7)
//
//                            Text("Sort By")
//
//                        }
//                    }
//
//                    Button{
//                        AnalyticsService.log(AnalyticsService.EventName.buttonTapped, params: [
//                            "button": "select_reminders_toggle",
//                            "view": "HomeView"
//                        ])
//                        if editMode?.wrappedValue == .inactive {
//                            editMode?.wrappedValue = .active
//                        } else {
//                            editMode?.wrappedValue = .inactive
//                        }
//                    } label: {
//                        HStack {
//                            Image(systemName: "checkmark.circle.fill")
//                                .font(.subheadline)
//                                .buttonStyle(.plain)
//                                .foregroundStyle(color.button(scheme))
//                                .padding(8)
//
//                            Text("Select Reminders")
//                        }
//
//
//                    }
//
//                } label: {
//                    Image(systemName: "ellipsis")
//                        .font(.subheadline)
//                        .foregroundStyle(color.button(scheme))
//                        .padding(8)
//                }
//                .buttonStyle(.plain)
//            }
//
//                ToolbarItem(placement: .topBarLeading){
//                    Button("Go Back", systemImage: "chevron.left"){
//                        AnalyticsService.log(AnalyticsService.EventName.buttonTapped, params: [
//                            "button": "back",
//                            "view": "HomeView"
//                        ])
//                        flow.popInsights()
//
//                    }
//                    .foregroundStyle(color.button(scheme))
//                    .padding(8)
//                    .font(.headline)
//                    .buttonStyle(.plain)
//
//                }
//            
////            ToolbarItem(placement: .topBarLeading){
////                VideoRecorderToolBarButton(flow: flow, color: color.button(scheme))
////            }
//
//
//        }
        .onChange(of: sorting){ oldSorting, newSorting in
            if let folder = folder {
                folder.sorting = newSorting
            }
            else {
                ReminderService.saveData(newSorting)
            }
        }

        .alert("Are you Sure?", isPresented: $deleteAlert){
            Button("Delete", role: .destructive){
                AnalyticsService.log(AnalyticsService.EventName.buttonTapped, params: [
                    "button": "delete_confirm",
                    "view": "HomeView"
                ])
                delete()
            }
        } message: {
            Text("You won't be able to restore this Reminder")
        }
        .sheet(isPresented: $refuseLoading){
            RefuseView(title: "You cannot access this Reminder yet", description: "The Video is still loading, wait a few seconds. Wait for the camera icon to appear")
                .presentationDetents([.height(300)])
        }
        .sheet(isPresented: $moveToFolder, onDismiss: {
            selection = []
            editMode?.wrappedValue = .inactive
        }){
            if let reminders = remindersToMove {
                MoveToFolder(reminders: reminders)
            }
        }
        .navigationTitle(folder?.name ?? "All Reminders")
        .toolbarBackground(color.overlayGradient(scheme), for: .bottomBar, .navigationBar, .tabBar)
        .navigationBarBackButtonHidden()
    }


    func move() {
        remindersToMove = reminders.filter { selection.contains($0.id) }
        moveToFolder.toggle()

    }

    func delete() {
        if selection.isEmpty {
            if let reminder = reminderToDelete {
                reminderService.deleteReminder(reminder)
            }

        } else {
            // Extract URLs before deletion
            let selectedReminders = reminders.filter { selection.contains($0.id) }
            let videoURLs = selectedReminders.compactMap { $0.firebaseVideoURL }

            selectedReminders.forEach { reminder in
                AnalyticsService.log(AnalyticsService.EventName.reminderDeleted, params: [
                    "id": reminder.id.uuidString,
                    "type": reminder.type.rawValue
                ])
                modelContext.delete(reminder)
            }

            editMode?.wrappedValue = .inactive
            Task {
                for url in videoURLs {
                    await reminderService.deleteVideo(url)
                }
            }
        }


    }

    init(folder: Folder? = nil, onSelectReminder: ((Reminder) -> Void)? = nil, onToggleSidebar: (() -> Void)? = nil) {
        self.folder = folder
        self.onSelectReminder = onSelectReminder
        self.onToggleSidebar = onToggleSidebar

        var AllRemindersSorting = Sorting.dateOld
        if self.folder == nil {
            if let data = UserDefaults.standard.data(forKey: "AllRemindersSorting") {
                if let decoded = try? JSONDecoder().decode(Sorting.self, from: data) {
                    AllRemindersSorting = decoded
                }
            }
        }

        _sorting = State(initialValue: folder?.sorting ?? AllRemindersSorting)

        if let folder = folder {
            // Filter reminders for this folder
            let id = folder.persistentModelID

            _reminders = Query(filter: #Predicate<Reminder> {
                $0.folder?.persistentModelID == id
            })
        } else {
            // All reminders (no folder)
            _reminders = Query(filter: #Predicate<Reminder> {
                $0.isChecked == true
            })
        }

    }


}

#Preview {
    HomeView(folder: .example)
}
