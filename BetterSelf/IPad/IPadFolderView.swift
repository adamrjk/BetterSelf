//
//  FolderView.swift
//  BetterSelf
//
//  Created by Adam Damou on 05/09/2025.
//

import LocalAuthentication
import AVKit
import SwiftData
import SwiftUI


struct IPadFolderView: View {
    @Environment(\.modelContext) var modelContext
    @Query(filter: #Predicate<Folder> { $0.isChecked == true},
           sort: \Folder.date) var folders: [Folder]

    @EnvironmentObject var color: ColorManager

    @Environment(\.scenePhase) var scenePhase

    @StateObject private var uploadManager = UploadManager.shared

    @State private var newFolder: Folder?
    @State private var addFolder = false
    @State private var searchText = ""
    @State private var showAlert = false
    @State private var refuseLoading = false


    @Binding var selectedReminder: Reminder?
    @Binding var selectedFolder: Folder


    @State private var addReminder = false

    @Environment(\.colorScheme) var scheme
    @State private var settings = false

    @State private var newReminder: Reminder?

    @State private var recordedVideoURL: URL?
    @State private var isFront: Bool?
    @State private var videoRecorded = false
    @State private var title = ""
    @State private var videoRecorder = false

    var body: some View {
        NavigationStack {

            GeometryReader { proxy in

                ZStack {
                    ZStack {
                        color.mainGradient(scheme)
                            .ignoresSafeArea()

                        color.overlayGradient(scheme)
                            .ignoresSafeArea()

                        FolderListContent(
                            searchText: $searchText,
                            showAlert: $showAlert,
                            refuseLoading: $refuseLoading,
                            mode: .iPad
                        )
                        .searchable(text: $searchText, placement: .navigationBarDrawer,  prompt: "Search")
                            .onChange(of: scenePhase){ oldPhase, newPhase in
                                if newPhase == .background {
                                    // App is leaving → lock again
                                    folders.forEach { folder in
                                        folder.isLocked = true
                                    }
                                }
                            }
                    }
                }
                .onAppear{
//                    checkIfWelcome()

                    if TutorialManager.shared.inTutorial && TutorialManager.shared.isHomeView2 {
                        TutorialManager.shared.endTutorial()

                    }

                    if TutorialManager.shared.inTutorial {
                        TutorialManager.shared.viewId("Folder")
                        TutorialManager.shared.startTutorial("Folder")
                    }
            AnalyticsService.logScreenView(screenName: "Folders", screenClass: "IPadFolderView")
                }
                .onChange(of: TutorialManager.shared.currentDone){
                    if TutorialManager.shared.inTutorial && TutorialManager.shared.currentDone {
                        TutorialManager.shared.viewId("Folder")
                        TutorialManager.shared.startTutorial("Folder")
                    }

                }
                .navigationTitle("BetterSelf")
                .toolbar{



                    ToolbarItem(placement: .topBarTrailing){
                        Button("Add Folder", systemImage: "folder.fill.badge.plus"){
                            AnalyticsService.log(AnalyticsService.EventName.buttonTapped, params: [
                                "button": "add_folder",
                                "view": "IPadFolderView"
                            ])
                            let folder = Folder(name: "")
                            modelContext.insert(folder)
                            newFolder = folder
                            addFolder.toggle()
                            TutorialManager.shared.handleTargetViewClick(target: "FolderButton")


                        }
                        .foregroundStyle(color.button(scheme))
                        .tutorialIdentifier("FolderButton")
                        .buttonStyle(.plain)

                    }
                    ToolbarItem(placement: .topBarLeading){
                        Button("Settings", systemImage: "gear"){
                            AnalyticsService.log(AnalyticsService.EventName.buttonTapped, params: [
                                "button": "settings_open",
                                "view": "IPadFolderView"
                            ])

                            settings.toggle()
                        }
                        .foregroundStyle(color.button(scheme))
                        .padding(8)
                        .buttonStyle(.plain)

                    }

                }
                .sheet(isPresented: $videoRecorder) {
                    CustomCameraView(
                        isPresented: $videoRecorder,
                        onVideoRecorded: { url, isFront in
                            recordedVideoURL = url
                            self.isFront = isFront
                            videoRecorded.toggle()
                        }
                    )
                    .ignoresSafeArea()

                }
                .sheet(isPresented: $videoRecorded, onDismiss: saveReminder){
                    AddTitleSheet(title: $title)
                        .presentationDetents([.height(300)])
                }
                .sheet(isPresented: $settings){
                    SettingsView()
                        .onDisappear{
//                            checkIfWelcome()

                            if TutorialManager.shared.inTutorial {
                                TutorialManager.shared.viewId("Folder")
                                TutorialManager.shared.startTutorial("Folder")
                            }
                        }
                }
                .sheet(isPresented: $addFolder, onDismiss: deleteEmptyFolder){
                    if let folder = newFolder {
                        AddFolderView(folder: folder)
                            .toolbarBackground(color.overlayGradient(scheme), for: .navigationBar)
                            .presentationDetents([.medium, .large])
                            .onDisappear {
                                if TutorialManager.shared.inTutorial {
                                    TutorialManager.shared.viewId("Folder")
                                    TutorialManager.shared.startTutorial("Folder")
                                }
                            }
                    }

                }
                .sheet(isPresented: $addReminder){
                    if let reminder = newReminder {
                        AddReminderView(reminder: reminder)
                            .onDisappear{
                                if TutorialManager.shared.inTutorial {
                                    TutorialManager.shared.viewId("Folder")
                                    TutorialManager.shared.startTutorial("Folder")
                                }
                            }
                    }
                }

                .sheet(isPresented: $refuseLoading){
                    RefuseView(title: "You cannot access this Reminder yet", description: "The Video is still loading, wait a few seconds. Wait for the camera icon to appear")
                        .presentationDetents([.height(300)])
                }
                .toolbarBackground(color.overlayGradient(scheme), for: .bottomBar, .navigationBar, .tabBar)
//                .navigationDestination(item: $selectedReminder) { reminder in
//                    ReminderView(reminder: reminder)
//                }
//                .navigationDestination(item: $notifReminder){ navReminder in
//                    ReminderView(reminder: navReminder.reminder)
//                }
//                .navigationDestination(item: $selectedFolder) { folder in
//                    if folder.name.isEmpty {
//                        HomeView()
//
//                    }
//                    else {
//                        HomeView(folder: folder)
//                    }
//                }
                .alert("Failed Authentication", isPresented: $showAlert){
                }
            }

        }


    }

    func saveReminder() {
            let reminder = Reminder(
                title: title,
                text: "",
                link: ""
            )
            if let front = self.isFront {
                reminder.isFront = front
            }
            reminder.isChecked = true
            modelContext.insert(reminder)

            uploadManager.loadVideo(reminder, recordedVideoURL: recordedVideoURL)

        }

    func checkIfWelcome(){
        if UserDefaults().bool(forKey: "Tutorial \(NotificationManager.shared.version)") {
        }
        else {
            TutorialManager.shared.getStarted()
            UserDefaults().set(true, forKey: "Tutorial \(NotificationManager.shared.version)")
        }


    }

    func deleteEmptyFolder() {
        if let folder = newFolder {
            guard folder.isChecked == false else { return }
            let nameIsNotValid = folders.contains { $0.name.lowercased() == folder.name.lowercased() }
            if folder.name.isEmpty || nameIsNotValid {
                modelContext.delete(folder)

            }
            else {
                folder.isChecked = true
                AnalyticsService.log(AnalyticsService.EventName.folderCreated, params: [
                    "name": folder.name
                ])
            }
        }

    }






}




