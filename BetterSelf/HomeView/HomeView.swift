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
    @StateObject var color = ColorManager.shared

    let folder: Folder?

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


    @State private var selection = Set<Reminder>()
    @State private var recordedVideoURL: URL?
    @State private var isFront: Bool?
    @State private var videoRecorded = false
    @State private var title = ""



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
                    List(selection: $selection) {
                        ForEach(sortedReminders){ reminder in
                            Button {


                                if reminder.isLoading && reminder.firebaseVideoURL == nil {
                                    refuseLoading.toggle()
                                }
                                else {
                                    if TutorialManager.shared.inTutorial {
                                        TutorialManager.shared.handleTargetViewClick(target: "ReminderButton")
                                    }
                                    selectedReminder = reminder
                                }
                            } label: {
                                ReminderRowView(reminder: reminder, isPreview: false)

                            }
                            .tutorialIdentifier("ReminderButton")
                            .swipeActions{

                                Button("", systemImage: "trash"){
                                    reminderToDelete = reminder
                                    deleteAlert.toggle()
                                }
                                .tint(.red)

                                Button("", systemImage: "folder.fill"){
                                    remindersToMove = [reminder]
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
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)

                    }
                    .searchable(text: $searchText, placement: .navigationBarDrawer, prompt: "Search for a Reminder")
                    .listStyle(.plain)
                    .padding(0)

                }
            }

            if !selection.isEmpty {
                VStack {
                    Spacer()
                    HStack {
                        Button("Delete"){
                            deleteAlert.toggle()
                        }
                        .buttonStyle(.plain)
                        .padding()
                        .clipShape(.capsule)
                        .adaptiveGlass(scheme)

                        Spacer()


                        Button("Move", action: move)
                            .buttonStyle(.plain)
                            .padding()
                            .clipShape(.capsule)
                            .adaptiveGlass(scheme)
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
                            //                .background(newCardBackground)
                            //                .clipShape(.capsule)

                            Text("Select Reminders")
                        }


                    }




                }label: {
                    Image(systemName: "ellipsis")
                        .font(.subheadline)
                        .foregroundStyle(color.button(scheme))
                        .padding(7)
                    //                        .background(
                    //                            Circle()
                    //                                .fill(newCardBackground)
                    //                        )
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("Add Reminder", systemImage: "plus"){
                    let reminder = Reminder(title: "", text: "", link: "", folder: folder)
                    modelContext.insert(reminder)
                    newReminder = reminder
                    addReminder.toggle()
                    if TutorialManager.shared.inTutorial {
                        TutorialManager.shared.handleTargetViewClick(target: "PlusButton")
                    }
                }
                .tutorialIdentifier("PlusButton")
                .buttonStyle(.plain)
                .foregroundStyle(color.button(scheme))
                .padding(7)
                //                .background(newCardBackground)
                .clipShape(.capsule)
            }

            ToolbarItem(placement: .topBarLeading){
                Button("Go Back", systemImage: "chevron.left"){
                    dismiss()

                }
                .padding(.trailing)
                .font(.headline)
                .buttonStyle(.plain)
                .foregroundStyle(color.button(scheme))
                .padding(7)
                //                .background(newCardBackground)
                .clipShape(.capsule)




            }
            ToolbarItem(placement: .topBarLeading){
                Button("Quick Add", systemImage: "video.fill.badge.plus"){
                    videoRecorder.toggle()
                }
                .font(.caption)
                .buttonStyle(.plain)
                .foregroundStyle(color.button(scheme))
                .padding(8)
                //                .background(newCardBackground)
                //                .clipShape(.capsule)
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
                            TutorialManager.shared.viewId("Home")
                            TutorialManager.shared.startTutorial("Home")
                        }
                    }
            }
        }
        .sheet(isPresented: $refuseLoading){
            RefuseView(title: "You cannot access this Reminder yet", description: "The Video is still loading, wait a few seconds. Wait for the camera icon to appear")
                .presentationDetents([.height(300)])
        }

        .sheet(isPresented: $videoRecorder) {
            CustomCameraView(
                isPresented: $videoRecorder,
                onVideoRecorded: { url, isFront in
                    recordedVideoURL = url
                    self.isFront = isFront
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
        }

        .navigationBarBackButtonHidden()
    }

    func move() {
        remindersToMove = Array(selection)
        moveToFolder.toggle()

    }

    func delete() {
        if selection.isEmpty {
            if let reminder = reminderToDelete {
                deleteReminder(reminder)
            }

        } else {
            // Extract URLs before deletion
            let videoURLs = selection.compactMap { $0.firebaseVideoURL }

            selection.forEach{ reminder in
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

        loadVideo(reminder)

    }


    func loadVideo(_ reminder: Reminder) {
        Task {
            if let url = recordedVideoURL {
                // Generate thumbnail immediately
                if let thumbnail = await generateThumbnail(from: url) {
                    reminder.photo = thumbnail.jpegData(compressionQuality: 0.8)
                }

                // Upload video in background
                await uploadVideoToFirebase(videoURL: url, reminder: reminder)
            }
        }
    }

    // Generate thumbnail from video URL
    private func generateThumbnail(from videoURL: URL) async -> UIImage? {
        let asset = AVURLAsset(url: videoURL)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true

        // Get thumbnail at 0.1 seconds (very fast)
        let time = CMTime(seconds: 0.1, preferredTimescale: 600)

        do {
            let cgImage = try await generator.image(at: time).image
            return UIImage(cgImage: cgImage)
        } catch {
            print("Thumbnail generation error: \(error)")
            return nil
        }
    }

    func uploadVideoToFirebase(videoURL: URL, reminder: Reminder) async {
        uploadManager.startUpload(videoURL: videoURL){ result in
            switch result {
            case .success(let firebaseURL):
                reminder.firebaseVideoURL = firebaseURL

            case .failure(let error):
                print("Firebase upload failed: \(error.localizedDescription)")
            }
        }
    }

}

#Preview {
    HomeView(folder: .example)
}
