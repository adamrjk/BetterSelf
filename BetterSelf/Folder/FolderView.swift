//
//  FolderView.swift
//  BetterSelf
//
//  Created by Adam Damou on 05/09/2025.
//

import LocalAuthentication
import SwiftData
import SwiftUI


struct FolderView: View {
    @Environment(\.modelContext) var modelContext
    @Query(filter: #Predicate<Folder> { $0.isChecked == true},
           sort: \Folder.date) var folders: [Folder]

    @StateObject var color = ColorManager.shared

    @Environment(\.scenePhase) var scenePhase

    @State private var newFolder: Folder?
    @State private var searchText = ""
    @State private var showAlert = false
    @State private var refuseLoading = false
    @State private var selectedReminder: Reminder?
    @State private var selectedFolder: Folder?
    @Binding var notifReminder: Reminder?

    @Environment(\.colorScheme) var scheme
    @State private var settings = false


    var body: some View {
        NavigationStack {

            GeometryReader { proxy in

                ZStack {
                    ZStack {
                        color.mainGradient(scheme)
                            .ignoresSafeArea()

                        color.overlayGradient(scheme)
                            .ignoresSafeArea()

                        FoldersList(searchText: $searchText, selectedReminder: $selectedReminder, selectedFolder: $selectedFolder,  showAlert: $showAlert, refuseLoading: $refuseLoading)
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
                    checkIfWelcome()

                    if TutorialManager.shared.inTutorial {
                        TutorialManager.shared.viewId("Folder")
                        TutorialManager.shared.startTutorial("Folder")
                    }
                }
                .onChange(of: TutorialManager.shared.currentDone){
                    if TutorialManager.shared.inTutorial && TutorialManager.shared.currentDone {
                        TutorialManager.shared.startTutorial("Folder")
                    }

                }
                .navigationTitle("BetterSelf")
                .toolbar{
                    ToolbarItem(placement: .topBarTrailing){
                        Button("Add Folder", systemImage: "folder.fill.badge.plus"){
                            let folder = Folder(name: "")
                            modelContext.insert(folder)
                            newFolder = folder

                            TutorialManager.shared.handleTargetViewClick(target: "FolderButton")

                        }
                        .tutorialIdentifier("FolderButton")
                        .buttonStyle(.plain)

                    }

                    ToolbarItem(placement: .topBarLeading){
                        Button("Settings", systemImage: "gear"){

                            settings.toggle()
                        }

                    }


                }
                .sheet(isPresented: $settings){
                    SettingsView()
                        .onDisappear{
                            checkIfWelcome()

                            if TutorialManager.shared.inTutorial {
                                TutorialManager.shared.viewId("Folder")
                                TutorialManager.shared.startTutorial("Folder")
                            }
                        }
                }
                .sheet(item: $newFolder, onDismiss: deleteEmptyFolder){ folder in
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
                .sheet(isPresented: $refuseLoading){
                    RefuseView(title: "You cannot access this Reminder yet", description: "The Video is still loading, wait a few seconds. Wait for the camera icon to appear")
                        .presentationDetents([.height(300)])
                }
                .toolbarBackground(color.overlayGradient(scheme), for: .bottomBar, .navigationBar, .tabBar)
                .navigationDestination(item: $selectedReminder) { reminder in
                    ReminderView(reminder: reminder)
                }
                .navigationDestination(item: $notifReminder){ reminder in
                    ReminderView(reminder: reminder)

                }
                .navigationDestination(item: $selectedFolder) { folder in
                    if folder.name.isEmpty {
                        HomeView()
                            .onDisappear{
                                if TutorialManager.shared.inTutorial && TutorialManager.shared.isHomeView2 {
                                    TutorialManager.shared.endTutorial()
                                    TutorialManager.shared.viewId("Folder")
                                    TutorialManager.shared.startTutorial("Folder")
                                }
                            }
                    }
                    else {
                        HomeView(folder: folder)
                            .onDisappear{
                                if TutorialManager.shared.inTutorial && TutorialManager.shared.isHomeView2 {
                                    TutorialManager.shared.endTutorial()
                                    TutorialManager.shared.viewId("Folder")
                                    TutorialManager.shared.startTutorial("Folder")
                                }
                            }
                    }
                }
                .alert("Failed Authentication", isPresented: $showAlert){
                }
            }

        }


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
            }
        }

    }
    init(notifReminder: Binding<Reminder?>){
        _notifReminder = notifReminder
    }

    



}

#Preview {
    FolderView(notifReminder: .constant(nil))
}



