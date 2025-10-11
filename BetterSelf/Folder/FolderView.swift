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

    @State private var welcome = true


    private var folderSteps: [TutorialStep] {
        switch TutorialManager.shared.folderViewStep {
        case 0:
            StepStorage.folderViewSteps0
        case 1:
            StepStorage.folderViewSteps1
        case 2:
            StepStorage.folderViewSteps2
        default:
            []
        }
    }

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


                        //                                            Color.gray.opacity(grayOut ? 0.3 : 0.0)
                        //                                                .ignoresSafeArea()
                    }
                }
                .onAppear{

                    if TutorialManager.shared.inTutorial && TutorialManager.shared.folderView0Done {
                        TutorialManager.shared.endTutorial()
                        TutorialManager.shared.folderViewStep = 1
                    }

                    checkIfWelcome()


                }
                .onChange(of: TutorialManager.shared.folderViewStep){
                    TutorialManager.shared.startTutorial(folderSteps)
                }
                .navigationTitle("BetterSelf")
                .toolbar{
                    ToolbarItem(placement: .topBarTrailing){
                        Button("Add Folder", systemImage: "folder.fill.badge.plus"){
                            let folder = Folder(name: "")
                            modelContext.insert(folder)
                            newFolder = folder
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
                        }
                }
                .sheet(item: $newFolder, onDismiss: deleteEmptyFolder){ folder in
                    AddFolderView(folder: folder)
                        .toolbarBackground(color.overlayGradient(scheme), for: .navigationBar)
                        .presentationDetents([.medium, .large])
                        .onDisappear{
                            if TutorialManager.shared.inTutorial {
                                TutorialManager.shared.folderViewStep = 2
                            }
                        }

                }
                .sheet(isPresented: $refuseLoading){
                    RefuseLoadingView()
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
                    }
                    else {
                        HomeView(folder: folder)
                    }
                }
                .alert("Failed Authentication", isPresented: $showAlert){
                }
            }

        }

    }

    func checkIfWelcome(){
        if UserDefaults().bool(forKey: "Tutorial 1.3") {
        }
        else {
            TutorialManager.shared.folderViewStep = 0
            TutorialManager.shared.inTutorial = true
            UserDefaults().set(true, forKey: "Tutorial 1.3")

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



