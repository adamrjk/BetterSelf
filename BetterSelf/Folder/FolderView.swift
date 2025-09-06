//
//  FolderView.swift
//  BetterSelf
//
//  Created by Adam Damou on 05/09/2025.
//

import SwiftData
import SwiftUI

struct FolderView: View {
    @Environment(\.modelContext) var modelContext
    @Query(filter: #Predicate<Folder> { $0.isChecked == true},
           sort: \Folder.date) var folders: [Folder]

    @State private var newFolder: Folder?
    @State private var addFolder = false
    @State private var searchText = ""

    @State private var selectedReminder: Reminder?

    var body: some View {
        NavigationStack {

            ZStack {
                Color.purpleMainGradient
                    .ignoresSafeArea()

                Color.purpleOverlayGradient
                    .ignoresSafeArea()

                FoldersList(searchText: $searchText, selectedReminder: $selectedReminder)
                    .searchable(text: $searchText, placement: .navigationBarDrawer,  prompt: "Search")



            }
            .navigationTitle("BetterSelf")
            .toolbar{
                ToolbarItem(placement: .topBarTrailing){
                    Button("Add Folder", systemImage: "folder.fill.badge.plus"){
                        let folder = Folder(name: "")
                        modelContext.insert(folder)
                        newFolder = folder
                        addFolder.toggle()
                    }
                    .buttonStyle(.plain)

                }
                ToolbarItem(placement: .topBarLeading){
                    EditButton()
                        .buttonStyle(.plain)
                }

            }

            .sheet(isPresented: $addFolder, onDismiss: deleteEmptyFolder){
                if let folder = newFolder {
                    AddFolderView(folder: folder)
                        .presentationDetents([.medium, .large])
                }
            }
            .toolbarBackground(Color.purpleOverlayGradient, for: .bottomBar, .navigationBar, .tabBar)
            .navigationDestination(item: $selectedReminder) { reminder in
                ReminderView(reminder: reminder)
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



}

#Preview {
    FolderView()
}


struct FoldersList: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.isSearching) var isSearching
    @Query(filter: #Predicate<Folder> { $0.isChecked == true},
           sort: \Folder.date) var folders: [Folder]
    @Binding var searchText: String


    @Query(filter: #Predicate<Reminder> { $0.isChecked == true
    }, sort: \Reminder.date) var reminders: [Reminder]

    @Binding var selectedReminder: Reminder?

    var filteredReminders: [Reminder] {
        if searchText.isEmpty {
            reminders
        } else {
            reminders.filter { $0.title.localizedStandardContains(searchText) }
        }
    }



    var body: some View {

        Group{

            if isSearching || !searchText.isEmpty {
                List{
                    ForEach(filteredReminders){ reminder in
                        Button {
                            //                                if reminder.type == .InstantInsight && reminder.firebaseVideoURL == nil {
                            //                                    refuseLoading.toggle()
                            //                                }
                            //                                else {
                            selectedReminder = reminder
                            //                                }
                        } label: {
                            ReminderRowView(reminder: reminder, isPreview: true)

                        }
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                        .listRowSeparator(.hidden)
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .listStyle(PlainListStyle())
            }
            else {


#warning("add a Pinned Area where you can choose Max 3 reminders to be pinned and access them immediately")

                VStack(alignment: .leading, spacing: 10){
                        Text("Folders")
                            .font(.title3)
                            .bold()
                            .multilineTextAlignment(.leading)


                }

                Divider()
                List{


                    NavigationLink{
                        HomeView()
                    } label: {
                        HStack {
                            FolderRowView(folder: nil)

                        }
                    }
                    .buttonStyle(.plain)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))

                    ForEach(folders){ folder in
                        NavigationLink{
                            HomeView(folder: folder)
                        } label: {
                            FolderRowView(folder: folder)

                        }
                    }
                    .onDelete(perform: deleteFolder)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))




                }
                .listStyle(PlainListStyle())
            }

        }





    }

    func deleteFolder(at offsets: IndexSet) {
        for offset in offsets {
            let folder = folders[offset]
            modelContext.delete(folder)
        }
    }

}

