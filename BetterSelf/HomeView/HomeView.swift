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

    var unlockedReminders: [Reminder]{
        reminders.filter{
            $0.isLocked == false
        }
    }


    var filteredReminders: [Reminder] {
        if searchText.isEmpty {
            unlockedReminders
        } else {
            unlockedReminders.filter { $0.title.localizedStandardContains(searchText) }
        }
    }

    var sortedReminders: [Reminder]{
        switch sorting {
        case .dateOld:
            filteredReminders.sorted{ $0.date < $1.date}
        case .dateNew:
            filteredReminders.sorted{ $0.date > $1.date}
        case .name:
            filteredReminders.sorted{ $0.title < $1.title}
        }
    }






    var newCardBackground: LinearGradient {
         LinearGradient(
            colors: [
                colorScheme == .light ? Color("CreamyYellow1") : Color(.systemGray6),
                colorScheme == .light ? Color("CreamyYellow2")  : Color(.systemGray6)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
    @State private var sorting: Sorting




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
                        ForEach(sortedReminders){ reminder in
                            Button {
                                if reminder.type == .InstantInsight && reminder.firebaseVideoURL == nil && !checkIfYoutube(reminder.link)  {
                                    refuseLoading.toggle()
                                }
                                else {
                                    selectedReminder = reminder
                                }
                            } label: {
                                ReminderRowView(reminder: reminder, isPreview: false)

                            }
//                            .padding(.vertical, 4)
//                            .padding(.horizontal, 16)

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
                                    reminder.pinned.toggle()
                                    if reminder.pinned {
                                        reminder.datePinned = .now
                                    }

                                }
                                .tint(.orange)
                            }
                            .tag(reminder)

                        }
                        .onDelete(perform: deleteReminder)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)

                    }
                    .searchable(text: $searchText, placement: .navigationBarDrawer, prompt: "Search for a Reminder")
                    .listStyle(.plain)
                    .padding(0)

                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
//                EditButton()
                Menu {
                    Picker("Sort", selection: $sorting) {
                        Text("Newest First")
                            .tag( Sorting.dateNew)

                        Text("Oldest First")
                            .tag(Sorting.dateOld)
                        Text("Title")
                            .tag(Sorting.name)

                    }

                }label: {
                    Image(systemName: "arrow.up.arrow.down")
                        .font(.subheadline)
                        .foregroundStyle(itemColor)
                        .padding(7)
                        .background(
                            Circle()
                                .fill(newCardBackground)
                        )
                }
                .buttonStyle(.plain)
            }
            

            ToolbarItem(placement: .topBarTrailing) {
                Button("Add Reminder", systemImage: "plus"){
                    let reminder = Reminder(title: "", text: "", link: "", folder: folder)
                    modelContext.insert(reminder)
                    newReminder = reminder
                    addReminder.toggle()
                }
                .buttonStyle(.plain)
                .foregroundStyle(itemColor)
                .padding(7)
                .background(newCardBackground)
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
                .background(newCardBackground)
                .clipShape(.capsule)
            }




        }
        .onChange(of: sorting){ oldSorting, newSorting in
            if let folder = folder {
                folder.sorting = newSorting
            }
            else {
                saveData(newSorting)
            }
        }
        .onAppear{
            sorting = folder?.sorting ?? loadData()



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



    func checkIfYoutube(_ link: String) -> Bool {
        if link.localizedStandardContains("youtube.com") || link.localizedStandardContains("youtu.be") {
            return true
        }
        else {
            return false
        }


    }



    func deleteVideo(_ url: String) async {
        FirebaseStorageService.shared.deleteVideo(firebaseURL: url) { _ in }
    }



    init(folder: Folder? = nil) {
        self.folder = folder

        var AllRemindersSorting = Sorting.dateOld
        if self.folder == nil {
            if let data = UserDefaults.standard.data(forKey: "AllRemindersSorting") {
                if let decoded = try? JSONDecoder().decode(Sorting.self, from: data) {
                    AllRemindersSorting = decoded
                }
            }
        }

        _sorting = State(initialValue: folder?.sorting ?? AllRemindersSorting)

        if let folder = folder {
            // Filter reminders for this folder
            let id = folder.persistentModelID

            _reminders = Query(filter: #Predicate<Reminder> {
                $0.folder?.persistentModelID == id
            })
        } else {
            // All reminders (no folder)
            _reminders =  Query(filter: #Predicate<Reminder> { $0.isChecked == true
            })
        }
    }

    func loadData() -> Sorting {
        if let data = UserDefaults.standard.data(forKey: "AllRemindersSorting") {
            if let decoded = try? JSONDecoder().decode(Sorting.self, from: data) {
                return decoded
            }
        }
        return .dateOld
    }
    func saveData(_ newSorting: Sorting) {
        if let data = try? JSONEncoder().encode(newSorting) {
            UserDefaults.standard.set(data, forKey: "AllRemindersSorting")
        }
    }


}

#Preview {
    HomeView(folder: .example)
}
