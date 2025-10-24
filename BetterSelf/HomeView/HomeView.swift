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
    @Environment(\.editMode) var editMode


    @Environment(\.colorScheme) var scheme
    @EnvironmentObject var color: ColorManager

    let folder: Folder?
    let onSelectReminder: ((Reminder) -> Void)?
    let onToggleSidebar: (() -> Void)?

    @Query var reminders: [Reminder]

    @StateObject private var uploadManager = UploadManager.shared

    @State private var searchText = ""
    @State private var addReminder = false
    @State private var selectedReminder: Reminder?
    @State private var remindersToMove: [Reminder]?
    @State private var newReminder: Reminder?
    @State private var videoRecorder = false
    @State private var refuseLoading = false
    @State private var moveToFolder = false

    @State private var deleteAlert = false
    @State private var reminderToDelete: Reminder?

    
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
    @State private var sorting: Sorting


    @State private var selection = Set<Reminder.ID>()
    @State private var recordedVideoURL: URL?
    @State private var isFront: Bool?
    @State private var videoRecorded = false
    @State private var title = ""
    @State private var isPresentingShare = false
    @State private var pendingShareURL: URL?


    var body: some View {

        ZStack {
            color.mainGradient(scheme)
                .ignoresSafeArea()

            color.overlayGradient(scheme)
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
                    HomeListContent(
                        folder: folder,
                        mode: .phone,
                        searchText: $searchText,
                        refuseLoading: $refuseLoading,
                        selection: $selection,
                        sorting: sorting,
                        onSelectReminder: { reminder in
                            if TutorialManager.shared.inTutorial {
                                TutorialManager.shared.handleTargetViewClick(target: isFirstId(reminder))
                            }
                            if let handler = onSelectReminder, UIDevice.current.userInterfaceIdiom == .pad {
                                handler(reminder)
                            } else {
                                selectedReminder = reminder
                            }
                        },
                        onRequestDelete: { reminder in
                            reminderToDelete = reminder
                            deleteAlert.toggle()
                        },
                        onRequestMove: { reminder in
                            remindersToMove = [reminder]
                            moveToFolder.toggle()
                        },
                        onShare: { reminder in
                            Task {
                                do {
                                    pendingShareURL = getLink(reminder)
                                    isPresentingShare = true
                                    _ = try await FirestoreService.shared.storeReminder(reminder)
                                } catch {
                                    print("Share prepare failed: \(error)")
                                }
                            }
                        }
                    )

                }
            }

            if !selection.isEmpty {
                VStack {
                    Spacer()
                    HStack {
                        Button("Delete"){
                            deleteAlert.toggle()
                        }
                        .adaptiveGlass(scheme)
                        .buttonStyle(.plain)

                        Spacer()


                        Button("Move", action: move)
                            .adaptiveGlass(scheme)
                            .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 5)
                }


            }
        }
        .onAppear{

            if TutorialManager.shared.inTutorial {
                TutorialManager.shared.viewId("Home")
                TutorialManager.shared.startTutorial("Home")
            }

        }
        .onChange(of: TutorialManager.shared.currentDone){
            if TutorialManager.shared.inTutorial && TutorialManager.shared.currentDone {
                TutorialManager.shared.viewId("Home")
                TutorialManager.shared.startTutorial("Home")
            }
        }
        .onChange(of: TutorialManager.shared.currentStepIndex){
            if TutorialManager.shared.inTutorial && TutorialManager.shared.currentViewId == "Home" && TutorialManager.shared.currentStepIndex == 2 {
                sorting = .dateNew
            }
        }
        .overlay(
            VStack {
                Spacer()
                HStack {
                    Spacer()

                    if editMode?.wrappedValue == .inactive {
                        Button{
                            let reminder = Reminder(title: "", text: "", link: "", folder: folder)
                            modelContext.insert(reminder)
                            newReminder = reminder
                            addReminder.toggle()
                            if TutorialManager.shared.inTutorial {
                                TutorialManager.shared.handleTargetViewClick(target: "PlusButton")
                            }
                        }label: {

                            Image(systemName: "plus")
                                .font(.title2)
                                .foregroundStyle(scheme == .light
                                                 ? .white
                                                 : .black)
                                .padding(20)
                        }
                        .tutorialIdentifier("PlusButton")
                        .adaptiveTranslucent(color.plusButton(scheme))
                        .clipShape(.circle)
                    }







                }
                .padding(.trailing, 10)
            }
        )
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
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
                        HStack {
                            Image(systemName: "arrow.up.arrow.down")
                                .font(.subheadline)
                                .foregroundStyle(color.button(scheme))
                                .padding(7)

                            Text("Sort By")

                        }
                    }

                    Button{
                        if editMode?.wrappedValue == .inactive {
                            editMode?.wrappedValue = .active
                        } else {
                            editMode?.wrappedValue = .inactive
                        }
                    } label: {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.subheadline)
                                .buttonStyle(.plain)
                                .foregroundStyle(color.button(scheme))
                                .padding(8)

                            Text("Select Reminders")
                        }


                    }




                } label: {
                    Image(systemName: "ellipsis")
                        .font(.subheadline)
                        .foregroundStyle(color.button(scheme))
                        .padding(8)
                }
                .buttonStyle(.plain)
            }

                ToolbarItem(placement: .topBarLeading){
                    Button("Go Back", systemImage: "chevron.left"){
                        dismiss()

                    }
                    .foregroundStyle(color.button(scheme))
                    .padding(8)
                    .font(.headline)
                    .buttonStyle(.plain)

                }
            
            ToolbarItem(placement: .topBarLeading){
                Button("Quick Add", systemImage: "video.fill.badge.plus"){
                    videoRecorder.toggle()
                }
                .buttonStyle(.plain)
                .foregroundStyle(color.button(scheme))
                .padding(8)
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
        .alert("Are you Sure?", isPresented: $deleteAlert){
            Button("Delete", role: .destructive){
                delete()
            }
        } message: {
            Text("You won't be able to restore this Reminder")
        }
        .sheet(isPresented: $addReminder, onDismiss: deleteEmptyReminder){
            if let reminder = newReminder {
                AddReminderView(reminder: reminder)
                    .onDisappear{
                        if TutorialManager.shared.inTutorial {
                            sorting = .dateNew
                            TutorialManager.shared.viewId("Home")
                            TutorialManager.shared.startTutorial("Home")
                        }
                    }
            }
        }
        .sheet(isPresented: $isPresentingShare){
            if let url = pendingShareURL {
                ShareSheet(activityItems: [url])
            }
        }
        .sheet(isPresented: $refuseLoading){
            RefuseView(title: "You cannot access this Reminder yet", description: "The Video is still loading, wait a few seconds. Wait for the camera icon to appear")
                .presentationDetents([.height(300)])
        }

        .sheet(isPresented: $videoRecorder) {
            CustomCameraView(
                isPresented: $videoRecorder,
                onVideoRecorded: { url, _ in
                    recordedVideoURL = url
                    self.isFront = false
                    videoRecorded.toggle()
                }
            )
            .ignoresSafeArea()

        }
        .sheet(isPresented: $videoRecorded, onDismiss: saveReminder){
            AddTitleSheet(title: $title)
                .presentationDetents([.height(300)])
        }
        .sheet(isPresented: $moveToFolder, onDismiss: {
            selection = []
            editMode?.wrappedValue = .inactive
        }){
            if let reminders = remindersToMove {
                MoveToFolder(reminders: reminders)

            }
        }
        .navigationTitle(folder?.name ?? "All Reminders")

        .toolbarBackground(color.overlayGradient(scheme), for: .bottomBar, .navigationBar, .tabBar)
        .navigationDestination(item: $selectedReminder) { reminder in
            ReminderView(reminder: reminder)
                .onDisappear{
                    TutorialManager.shared.viewId("Home")
                    TutorialManager.shared.startTutorial("Home")

                }
        }

        .navigationBarBackButtonHidden()
    }

    func getLink(_ reminder: Reminder) -> URL {
        if reminder.shareID != nil {
            return reminder.shareLink
        }
        else {
            reminder.shareID = generateShortID()
            return reminder.shareLink
        }


    }
    func generateShortID(length: Int = 6) -> String {
        let chars = Array("abcdefghijklmnopqrstuvwxyz0123456789")
        var result = ""
        for _ in 0..<length {
            result.append(chars.randomElement()!)
        }
        return result
    }


    func saveReminder() {
        let reminder = Reminder(
            title: title,
            text: "",
            link: ""
        )
        if let front = self.isFront {
            reminder.isFront = front
        }
        reminder.isChecked = true
        modelContext.insert(reminder)

        uploadManager.loadVideo(reminder, recordedVideoURL: recordedVideoURL)

    }

    func move() {
        remindersToMove = reminders.filter { selection.contains($0.id) }
        moveToFolder.toggle()

    }

    func delete() {
        if selection.isEmpty {
            if let reminder = reminderToDelete {
                deleteReminder(reminder)
            }

        } else {
            // Extract URLs before deletion
            let selectedReminders = reminders.filter { selection.contains($0.id) }
            let videoURLs = selectedReminders.compactMap { $0.firebaseVideoURL }

            selectedReminders.forEach { reminder in
                modelContext.delete(reminder)
            }

            editMode?.wrappedValue = .inactive

            Task {
                for url in videoURLs {
                    await deleteVideo(url)
                }
            }
        }


    }

    func deleteEmptyReminder() {
        if let reminder = newReminder{
            guard reminder.isChecked == false else { return }
            if reminder.isEmpty {
                modelContext.delete(reminder)
            }
            if (reminder.type != .TimeLessLetter && reminder.photo == nil && !reminder.isLoading) {
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



    init(folder: Folder? = nil, onSelectReminder: ((Reminder) -> Void)? = nil, onToggleSidebar: (() -> Void)? = nil) {
        self.folder = folder
        self.onSelectReminder = onSelectReminder
        self.onToggleSidebar = onToggleSidebar

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

    

    

    func isFirstId(_ reminder: Reminder) -> String {
        if let first = sortedReminders.first {
            reminder.id == first.id  ? "FirstReminderButton" : "RemindersButton"
        }
        else {
            "RemindersButton"
        }






    }

}

#Preview {
    HomeView(folder: .example)
}
