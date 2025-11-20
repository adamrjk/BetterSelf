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


struct FolderView: View {

    @EnvironmentObject var flow: AppFlow
    @State private var model = FolderViewModel()

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
    @State private var selectedReminder: Reminder?
    @State private var selectedFolder: Folder?
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
                            mode: .phone
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
            AnalyticsService.logScreenView(screenName: "Folders", screenClass: "FolderView")
                }
                .onChange(of: TutorialManager.shared.currentDone){
                    if TutorialManager.shared.inTutorial && TutorialManager.shared.currentDone {
                        TutorialManager.shared.viewId("Folder")
                        TutorialManager.shared.startTutorial("Folder")
                    }

                }
                .toolbar{
                    ToolbarItem(placement: .topBarTrailing){
                        Button("Add Folder", systemImage: "folder.fill.badge.plus"){
                            AnalyticsService.log(AnalyticsService.EventName.buttonTapped, params: [
                                "button": "add_folder",
                                "view": "FolderView"
                            ])
                            let folder = Folder(name: "")
                            modelContext.insert(folder)
                            newFolder = folder
                            addFolder.toggle()
                            flow.addFolderSheet(folder)

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
                                "view": "FolderView"
                            ])
                            flow.settingSheet()
                            settings.toggle()
                        }
                        .foregroundStyle(color.button(scheme))
                        .padding(8)
                        .buttonStyle(.plain)

                    }

                    ToolbarItem(placement: .topBarLeading){
                        Button("Quick Add", systemImage: "video.fill.badge.plus"){
                            AnalyticsService.log(AnalyticsService.EventName.buttonTapped, params: [
                                "button": "quick_add",
                                "view": "FolderView"
                            ])
//                            videoRecorder.toggle()
                            flow.cameraSheet()
                        }
                        .foregroundStyle(color.button(scheme))
                        .padding(8)
                        .buttonStyle(.plain)
                    }


                }
//                .sheet(isPresented: $videoRecorder) {
//                    CustomCameraView(
//                        isPresented: $videoRecorder,
//                        onVideoRecorded: { url, _ in
//                            recordedVideoURL = url
//                            self.isFront = false
//                            videoRecorded.toggle()
//                        }
//                    )
//                    .ignoresSafeArea()
//
//                }
//                .sheet(isPresented: $videoRecorded, onDismiss: saveReminder){
//                    AddTitleSheet(title: $title)
//                        .presentationDetents([.height(300)])
//                }
//                .sheet(isPresented: $settings){
//                    SettingsView()
//                        .onDisappear{
//                            checkIfWelcome()
//
//                            if TutorialManager.shared.inTutorial {
//                                TutorialManager.shared.viewId("Folder")
//                                TutorialManager.shared.startTutorial("Folder")
//                            }
//                        }
//                }
//                .sheet(item: $newFolder, onDismiss: deleteEmptyFolder){ folder in
//                    AddFolderView(folder: folder)
//                        .toolbarBackground(color.overlayGradient(scheme), for: .navigationBar)
//                        .presentationDetents([.medium, .large])
//                        .onDisappear {
//                            if TutorialManager.shared.inTutorial {
//                                TutorialManager.shared.viewId("Folder")
//                                TutorialManager.shared.startTutorial("Folder")
//                            }
//                        }
//
//                }
//                .sheet(item: $newReminder, onDismiss: deleteEmptyReminder){ reminder in
//                    AddReminderView(reminder: reminder)
//                        .onDisappear{
//                                if TutorialManager.shared.inTutorial {
//                                    TutorialManager.shared.viewId("Folder")
//                                    TutorialManager.shared.startTutorial("Folder")
//                                }
//                            }
//
//                }

                .sheet(isPresented: $refuseLoading){
                    RefuseView(title: "You cannot access this Reminder yet", description: "The Video is still loading, wait a few seconds. Wait for the camera icon to appear")
                        .presentationDetents([.height(300)])
                }
                .toolbarBackground(color.overlayGradient(scheme), for: .bottomBar, .navigationBar, .tabBar)
//                .navigationDestination(item: $selectedReminder) { reminder in
//                    ReminderView(reminder: reminder)
//                }
//                .navigationDestination(item: $selectedFolder) { folder in
//                    if folder.name.isEmpty {
//                        HomeView()
//                    }
//                    else {
//                        HomeView(folder: folder)
//                    }
//                }
                .alert("Failed Authentication", isPresented: $showAlert){
                }
            }
            .navigationTitle("BetterSelf")
            .floatingPlusButton {
                flow.addReminderSheet()
            }


        


    }



}

#Preview {
    FolderView()
}



