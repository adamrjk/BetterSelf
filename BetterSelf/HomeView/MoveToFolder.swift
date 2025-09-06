//
//  MoveToFolder.swift
//  BetterSelf
//
//  Created by Adam Damou on 05/09/2025.
//

import SwiftData
import SwiftUI

struct MoveToFolder: View {
    @Environment(\.dismiss) var dismiss
    let reminder: Reminder

    @Query(filter: #Predicate<Folder> { $0.isChecked == true},
           sort: \Folder.date) var folders: [Folder]

    var body: some View {
        NavigationStack{
            ZStack {
                Color.purpleMainGradient
                    .ignoresSafeArea()

                Color.purpleOverlayGradient
                    .ignoresSafeArea()


                List{

                    ReminderRowView(reminder: reminder, isPreview: true)
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))


                    ForEach(folders){ folder in
                        Button{
                            #warning("remove reminder from the older folder")
                            folder.reminders.append(reminder)

                            reminder.folder = folder
                            dismiss()
                        } label: {
                            FolderRowView(folder: folder)

                        }
                        .buttonStyle(.plain)
                    }
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))


                }
                .listStyle(PlainListStyle())
            }
            .navigationTitle("Select a folder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar{
                ToolbarItem(placement: .topBarLeading){
                    Button("Cancel"){
                        dismiss()
                    }
                    .buttonStyle(.plain)
                }
            }

        }

    }

}

#Preview {
    MoveToFolder(reminder: .example)
}
