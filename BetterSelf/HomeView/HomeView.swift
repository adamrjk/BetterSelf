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
    @Environment(\.modelContext) var modelContext
    @Environment(\.editMode) var editMode
    @EnvironmentObject var flow: AppFlow
    @Environment(\.colorScheme) var scheme
    @EnvironmentObject var color: ColorManager

    @Query var reminders: [Reminder]
    let folder: Folder?

    @StateObject private var uploadManager = UploadManager.shared
    @StateObject private var vm = HomeViewModel()

    private var reminderService: ReminderService {
        ReminderService(provider: { modelContext })
    }

    var body: some View {
        ZStack {
            color.background(scheme)
            HomeListContent(folder, vm)

            if !vm.selection.isEmpty { EditModeButtons(deleteAlert: $vm.deleteAlert, move: { vm.moveSelected(from: reminders) }) }
        }
        .onAppear{
            AnalyticsService.logScreenView(screenName: "Home", screenClass: "HomeView")

            if TutorialManager.shared.inTutorial {
                TutorialManager.shared.viewId("Home")
                TutorialManager.shared.startTutorial("Home")
            }

            vm.sorting = folder?.sorting ?? ReminderService.loadData()

            // Configure ViewModel with environment-provided services
            vm.configure(reminderService: reminderService, flow: flow, folder: folder)

        }
        .floatingPlusButton(editMode?.wrappedValue == .inactive, action: {
                flow.addReminderSheet(folder)
        })
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    SortingToolbarButton(sorting: $vm.sorting)
                    Button{
                        AnalyticsService.log(AnalyticsService.EventName.buttonTapped, params: [
                            "button": "select_reminders_toggle",
                            "view": "HomeView"
                        ])
                        if editMode?.wrappedValue == .inactive {
                            editMode?.wrappedValue = .active
                        } else {
                            editMode?.wrappedValue = .inactive
                        }
                    } label: { SelectToolbarButton() }

                } label: { EllipsisToolbarButton() }
                .buttonStyle(.plain)
            }
            ToolbarItem(placement: .topBarLeading){
                Button("Go Back", systemImage: "chevron.left"){
                    AnalyticsService.log(AnalyticsService.EventName.buttonTapped, params: [
                        "button": "back",
                        "view": "HomeView"
                    ])
                    flow.popInsights()

                }
                .foregroundStyle(color.button(scheme))
                .padding(8)
                .font(.headline)
                .buttonStyle(.plain)
            }
            
            ToolbarItem(placement: .topBarLeading){
                VideoRecorderToolBarButton(flow: flow, color: color.button(scheme))
            }
        }
        .onChange(of: vm.sorting){ oldSorting, newSorting in
            if let folder = folder {
                folder.sorting = newSorting
            }
            else {
                ReminderService.saveData(newSorting)
            }
        }
        .onChange(of: vm.selection) { _, newSelection in
            vm.selection = newSelection
        }
        .alert("Are you Sure?", isPresented: $vm.deleteAlert){
            Button("Delete", role: .destructive){
                AnalyticsService.log(AnalyticsService.EventName.buttonTapped, params: [
                    "button": "delete_confirm",
                    "view": "HomeView"
                ])
                vm.confirmDelete(from: reminders)
                editMode?.wrappedValue = .inactive
                vm.selection = []
            }
        } message: {
            Text("You won't be able to restore this Reminder")
        }
        .sheet(isPresented: $vm.refuseLoading){ RefuseLoading() }
        .sheet(isPresented: $vm.moveToFolder, onDismiss: {
            vm.selection = []
            editMode?.wrappedValue = .inactive
        }){
            MoveToFolder(reminders: vm.remindersToMove)
        }
        .navigationTitle(folder?.name ?? "All Reminders")
        .toolbarBackground(color.overlayGradient(scheme), for: .bottomBar, .navigationBar, .tabBar)
        .navigationBarBackButtonHidden()
    }

    init(folder: Folder? = nil, onSelectReminder: ((Reminder) -> Void)? = nil, onToggleSidebar: (() -> Void)? = nil) {
        self.folder = folder
        if let folder = folder {
            // Filter reminders for this folder
            let id = folder.persistentModelID
            _reminders = Query(filter: #Predicate<Reminder> { $0.folder?.persistentModelID == id })
        } else {
            _reminders = Query(filter: #Predicate<Reminder> { $0.isChecked == true })
        }
    }


}

#Preview {
    HomeView(folder: .example)
}
