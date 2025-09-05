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
    @Query(sort: \Folder.date) var folders: [Folder]

    @State private var newFolder: Folder?
    @State private var addFolder = false
    @State private var searchText = ""

    var filteredFolders: [Folder] {
        if searchText.isEmpty {
           folders
        } else {
            folders.filter { $0.name.localizedStandardContains(searchText) }
        }
    }

    var body: some View {
        NavigationStack {

            ZStack {
                Color.purpleMainGradient
                    .ignoresSafeArea()

                Color.purpleOverlayGradient
                    .ignoresSafeArea()
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

                    ForEach(filteredFolders){ folder in
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
                .searchable(text: $searchText, placement: .navigationBarDrawer, prompt: "Search")
                .listStyle(PlainListStyle())

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
        }
    }
    func deleteFolder(at offsets: IndexSet) {
        for offset in offsets {
            let folder = folders[offset]
            modelContext.delete(folder)
        }
    }
    func deleteEmptyFolder() {
        if let folder = newFolder {
            let nameIsNotValid = folders.contains { $0.name.lowercased() == folder.name.lowercased() }
            if folder.name.isEmpty || nameIsNotValid {
                modelContext.delete(folder)
            }
        }

    }



}

#Preview {
    FolderView()
}


