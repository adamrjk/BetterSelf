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
    let reminders: [Reminder]
    @EnvironmentObject var color: ColorManager
    @Environment(\.colorScheme) var scheme

    @Query(filter: #Predicate<Folder> { $0.isChecked == true},
           sort: \Folder.date) var folders: [Folder]

    @Query(filter: #Predicate<Reminder> {
            $0.isChecked == true
        }, sort: \Reminder.date) var allReminders: [Reminder]

    var unlockedReminders: [Reminder]{
        allReminders.filter{
            $0.isLocked == false
        }
    }

    var body: some View {
        NavigationStack{
            ZStack {
                color.mainGradient(scheme)
                    .ignoresSafeArea()

                color.overlayGradient(scheme)
                    .ignoresSafeArea()


                List{
                    Group {
                        if reminders.count == 1, let reminder = reminders.first  {
                            ReminderRowView(reminder: reminder, isPreview: true)
                                .listRowBackground(Color.clear)
                                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                        }
                        else {
                            VStack {

                                HStack {
                                    Image(systemName: "document.on.document.fill")
                                        .frame(width: 40, height: 40)
                                        .bold()
                                        .foregroundStyle(color.itemColor(scheme))
                                    ForEach(reminders){ reminder in
                                        Text(ListFormatter.localizedString(byJoining: reminders.map{ reminder in
                                            reminder.title
                                        }))
                                            .lineLimit(1)
                                    }
                                }

                                Text("\(reminders.count) Reminders")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            .listRowBackground(Color.clear)
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                        }
                    }


                    ForEach(folders){ folder in
                        Button{
                            reminders.forEach{ reminder in
                                reminder.folder = folder
                            }
                            dismiss()
                        } label: {
                            FolderRowView(folder: folder, count: getCount(folder))

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
                }
            }

        }

    }

    func getCount(_ folder: Folder?) -> Int {
        if let folder = folder {
            let id = folder.persistentModelID
            return unlockedReminders.filter({
                $0.folder?.persistentModelID == id
            }).count
        }
        else {
            return unlockedReminders.count
        }
    }

}

#Preview {
    MoveToFolder(reminders: [.example])
}
