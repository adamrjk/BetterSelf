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
    @Environment(\.modelContext) var modelContext
    @Environment(\.colorScheme) var scheme
    @EnvironmentObject var color: ColorManager
    @Environment(\.scenePhase) var scenePhase

    @Query(filter: #Predicate<Folder> { $0.isChecked == true},
           sort: \Folder.date) var folders: [Folder]
    @StateObject private var vm = FolderViewModel()


    private var reminderService: ReminderService {
        ReminderService(provider: { modelContext })
    }

    private var folderService: FolderService {
        FolderService(provider: { modelContext })
    }

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                ZStack {
                    color.background(scheme)
                    ScrollView {
                        VStack(spacing: 0) {
                            FolderListContent(vm: vm)
                            .searchable(text: $vm.searchText, placement: .navigationBarDrawer,  prompt: "Search")
                        }
                    }
                    .defaultScrollAnchor(.center)
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
            .alert("Are you Sure?", isPresented: $vm.deleteAlert) {
                Button("Delete", role: .destructive) {
                    AnalyticsService.log(AnalyticsService.EventName.buttonTapped, params: [
                        "button": "delete_folder_confirm",
                        "view": "FolderListContent",
                        "folder": vm.folderToDelete?.name ?? ""
                    ])
                    if let folder = vm.folderToDelete {
                        folderService.deleteFolder(folder)
                    }
                }
            } message: {
                Text("This will delete all the Reminders in this Folder")
            }


            .onAppear{
                vm.configure(folderService: folderService, reminderService: reminderService, flow: flow)
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
                        flow.cameraSheet()
                    }
                    .foregroundStyle(color.button(scheme))
                    .padding(8)
                    .buttonStyle(.plain)
                }
            }
            .sheet(isPresented: $vm.refuseLoading){ RefuseLoading() }
            .toolbarBackground(color.overlayGradient(scheme), for: .bottomBar, .navigationBar, .tabBar)
            .alert("Failed Authentication", isPresented: $vm.showAlert){}
        }
        .navigationTitle("BetterSelf")
        .floatingPlusButton(true, action: { flow.addReminderSheet() })
    }
}

#Preview {
    FolderView()
}



