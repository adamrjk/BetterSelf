//
//  FoldersList.swift
//  BetterSelf
//
//  Created by Adam Damou on 13/09/2025.
//

import LocalAuthentication
import SwiftData
import SwiftUI

struct FoldersList: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.isSearching) var isSearching
    @Query(filter: #Predicate<Folder> { $0.isChecked == true},
           sort: \Folder.date) var folders: [Folder]
    @Binding var searchText: String


    @Query(filter: #Predicate<Reminder> {
        $0.isChecked == true
    }, sort: \Reminder.date) var reminders: [Reminder]

    @Binding var selectedReminder: Reminder?

    @Binding var showAlert: Bool

    var unlockedReminders: [Reminder]{
        reminders.filter{ reminder in
            reminder.isLocked == false
        }
    }
    var filteredReminders: [Reminder] {
        if searchText.isEmpty {
            unlockedReminders
        } else {
            unlockedReminders.filter { $0.title.localizedStandardContains(searchText) }
        }
    }

    var body: some View {

            Group{

                if isSearching || !searchText.isEmpty {
                    List{
                        ForEach(filteredReminders){ reminder in
                            Button {
                                // if reminder.type == .InstantInsight && reminder.firebaseVideoURL == nil {
                                //refuseLoading.toggle()
                                //}
                                //else {
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
                    VStack(alignment: .leading, spacing: 0){
                        Text("Pinned")
                            .font(.title3)
                            .bold()
                        Text("Choose up to 3 Reminders for Quick Access")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                    }
                    .padding([.top, .bottom], 10)



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
                            if folder.faceID && folder.isLocked {
                                Button{
                                    authenticate(folder)
                                }label: {
                                    FolderRowView(folder: folder)
                                }
                            }
                            else {
                                NavigationLink{
                                    HomeView(folder: folder)
                                } label: {
                                    FolderRowView(folder: folder)

                                }
                            }

                        }
                        .onDelete(perform: deleteFolder)
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16))




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

    func authenticate(_ folder: Folder) {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Please authenticate yourself to unlock your reminders."

            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in

                if success {
                    folder.isLocked = false
                } else {
                    // Fallback to device passcode
                    context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: "Enter your device passcode to unlock your reminders.") { success, error in
                        if success {
                            folder.isLocked = false
                        }
                    }
                }
            }
        } else {
            showAlert = true
        }
    }

}
#Preview {
    FoldersList(searchText: .constant(""), selectedReminder: .constant(.example), showAlert: .constant(false))
}
