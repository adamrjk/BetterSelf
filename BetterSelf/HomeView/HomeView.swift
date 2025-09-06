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
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext


    let folder: Folder?

    @Query var reminders: [Reminder]

    @StateObject private var uploadManager = UploadManager.shared

    @State private var searchText = ""
    @State private var addReminder = false
    @State private var selectedReminder: Reminder?
    @State private var reminderToMove: Reminder?
    @State private var newReminder: Reminder?
    @State private var videoRecorder = false
    @State private var refuseLoading = false
    @State private var moveToFolder = false
    @Environment(\.colorScheme) var colorScheme

    var itemColor: LinearGradient {
        colorScheme == .light
        ? LinearGradient(colors: [.black], startPoint: .top, endPoint: .bottom)
        : Color.creamyYellowGradient
    }

    var filteredReminders: [Reminder] {
        if searchText.isEmpty {
            reminders
        } else {
            reminders.filter { $0.title.localizedStandardContains(searchText) }
        }
    }

    //Add Sorting if you want to




    var body: some View {

        ZStack {
            Color.purpleMainGradient
                .ignoresSafeArea()

            Color.purpleOverlayGradient
                .ignoresSafeArea()
            Group {
                if reminders.isEmpty {
                    VStack {
                        Text("Looks like you have no Reminders")
                            .font(.headline)
                            .multilineTextAlignment(.center)
                            .padding()
                        CleanText("Click the plus on the top right corner to add a new Reminder")
                            .multilineTextAlignment(.center)
                    }
                }
                else {
                    List {
                        ForEach(filteredReminders){ reminder in
                            Button {
                                if reminder.type == .InstantInsight && reminder.firebaseVideoURL == nil {
                                    refuseLoading.toggle()
                                }
                                else {
                                    selectedReminder = reminder
                                }
                            } label: {
                                ReminderRowView(reminder: reminder, isPreview: false)

                            }
                            .buttonStyle(PlainButtonStyle())
                            .swipeActions{

                                Button("", systemImage: "trash", role: .destructive){
                                    deleteReminder(reminder)
                                }

                                Button("", systemImage: "folder.fill"){
                                    reminderToMove = reminder
                                    moveToFolder.toggle()
                                }

                                .tint(.black)

                            }
                            .tag(reminder)
                            .swipeActions(edge: .leading){
                                Button("", systemImage: "pin.fill"){

                                }
                                .tint(.orange)
                            }
                            .tag(reminder)

                        }
                        .onDelete(perform: deleteReminder)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    }

                    .listStyle(PlainListStyle())
                    .searchable(text: $searchText, placement: .navigationBarDrawer, prompt: "Search for a Reminder")
                    .padding(0)

                }
                //
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Add Reminder", systemImage: "plus"){
                    let reminder = Reminder(title: "", text: "", link: "")
                    modelContext.insert(reminder)
                    newReminder = reminder
                    addReminder.toggle()
                }
                .buttonStyle(.plain)
                .foregroundStyle(itemColor)
                .padding(7)
                .background(Color.cardBackground)
                .clipShape(.capsule)
            }

            ToolbarItem(placement: .topBarLeading){
                Button("Go Back", systemImage: "chevron.left"){
                    dismiss()

                }
                .padding(.trailing)
                .font(.headline)
                .buttonStyle(.plain)
                .foregroundStyle(.primary)




            }

            ToolbarItem(placement: .topBarLeading){
                Button("Quick Add", systemImage: "video.fill.badge.plus"){
                    videoRecorder.toggle()
                }
                .font(.caption)
                .buttonStyle(.plain)
                .foregroundStyle(itemColor)
                .padding(8)
                .background(Color.cardBackground)
                .clipShape(.capsule)
            }




        }
        .sheet(isPresented: $addReminder, onDismiss: deleteEmptyReminder){
            if let reminder = newReminder {
                AddReminderView(reminder: reminder)
            }
        }
        .sheet(isPresented: $refuseLoading){
            RefuseLoadingView()
                .presentationDetents([.height(300)])
        }

        .sheet(isPresented: $videoRecorder) {
            VideoRecorderView()
        }
        .sheet(isPresented: $moveToFolder){
            if let reminder = reminderToMove {
                MoveToFolder(reminder: reminder)

            }


        }
        .navigationTitle(folder?.name ?? "All Reminders")

        .toolbarBackground(Color.purpleOverlayGradient, for: .bottomBar, .navigationBar, .tabBar)
        .navigationDestination(item: $selectedReminder) { reminder in
            ReminderView(reminder: reminder)
        }
        .navigationBarBackButtonHidden()



    }
    func deleteEmptyReminder() {
        if let reminder = newReminder{
            guard reminder.isChecked == false else { return }
            if reminder.isEmpty {
                modelContext.delete(reminder)
            }
            if (reminder.type != .TimeLessLetter && reminder.photo == nil) {
                reminder.type = .TimeLessLetter
            }
            reminder.isChecked = true
        }

    }




    func deleteReminder(at offsets: IndexSet) {
        for offset in offsets {
            let reminder = reminders[offset]

            if let url = reminder.firebaseVideoURL {
                Task {
                    await deleteVideo(url)
                }
            }

            modelContext.delete(reminder)
        }
    }

    func deleteReminder(_ reminder: Reminder) {
        if let url = reminder.firebaseVideoURL {
            Task {
                await deleteVideo(url)
            }
        }
        modelContext.delete(reminder)
    }







    func deleteVideo(_ url: String) async {
        FirebaseStorageService.shared.deleteVideo(firebaseURL: url) { _ in }
    }



    init(folder: Folder? = nil) {
        self.folder = folder
        if let folder = folder {
            // Filter reminders for this folder
            let id = folder.persistentModelID

            _reminders = Query(filter: #Predicate<Reminder> {
                $0.folder?.persistentModelID == id
            }, sort: \Reminder.date)
        } else {
            // All reminders (no folder)
            _reminders =  Query(filter: #Predicate<Reminder> { $0.isChecked == true
            }, sort: \Reminder.date)
        }
    }


}

#Preview {
    HomeView(folder: .example)
}
