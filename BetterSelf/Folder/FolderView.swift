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

    @Environment(\.scenePhase) var scenePhase

    @State private var newFolder: Folder?
    @State private var searchText = ""
    @State private var showAlert = false

    @State private var selectedReminder: Reminder?
    @State private var selectedFolder: Folder?
    @Binding var notifReminder: Reminder?

    var body: some View {
        NavigationStack {

            ZStack {
                Color.purpleMainGradient
                    .ignoresSafeArea()

                Color.purpleOverlayGradient
                    .ignoresSafeArea()

                FoldersList(searchText: $searchText, selectedReminder: $selectedReminder, selectedFolder: $selectedFolder,  showAlert: $showAlert)
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
            .navigationTitle("BetterSelf")
            .toolbar{
                ToolbarItem(placement: .topBarTrailing){
                    Button("Add Folder", systemImage: "folder.fill.badge.plus"){
                        let folder = Folder(name: "")
                        modelContext.insert(folder)
                        newFolder = folder
                    }
                    .buttonStyle(.plain)

                }
                ToolbarItem(placement: .topBarLeading){
                    EditButton()
                        .buttonStyle(.plain)
                }

            }
            .sheet(item: $newFolder, onDismiss: deleteEmptyFolder){ folder in
                AddFolderView(folder: folder)
                    .presentationDetents([.medium, .large])
            }
            .toolbarBackground(Color.purpleOverlayGradient, for: .bottomBar, .navigationBar, .tabBar)
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



