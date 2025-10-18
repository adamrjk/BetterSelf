//
//  FoldersList.swift
//  BetterSelf
//
//  Created by Adam Damou on 13/09/2025.
//

import LocalAuthentication
import SwiftData
import SwiftUI
import UserNotifications
import WidgetKit

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
    @Binding var selectedFolder: Folder?
    @Binding var showAlert: Bool
    @Binding var refuseLoading: Bool
    @State private var deleteAlert = false
    @State private var folderToDelete: Folder?



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

    var pinned: [Reminder] {
        var pinned = unlockedReminders.filter{ $0.pinned}
        pinned = pinned.sorted{ $0.datePinned < $1.datePinned }
        while pinned.count > 3 {
            if let first = pinned.first {
                first.pinned = false

                pinned.removeFirst()
            }
        }
        return pinned
    }
    @Environment(\.colorScheme) var scheme
    @EnvironmentObject var color: ColorManager

    var body: some View {
        ScrollView {
            VStack(spacing: 0){
                if isSearching || !searchText.isEmpty {
                    searchResultsView
                }
                else {
                    pinnedSectionView
                    foldersSectionView
                }
            }

        }
        .defaultScrollAnchor(.center)
        .animation(.smooth, value: pinned)
        .alert("Are you Sure?", isPresented: $deleteAlert){
            Button("Delete", role: .destructive){
                if let folder = folderToDelete {
                    deleteFolder(folder)
                }
            }
        } message: {
            Text("This will delete all the Reminders in this Folder")
        }
        .onChange(of: pinned){ _, newValue in
            storePinnedReminders(newValue)
            if let last = pinned.last{
                addNotification(for: last)
            }
        }
    }
    
    // MARK: - View Components
    
    @ViewBuilder
    private var searchResultsView: some View {
        ForEach(filteredReminders){ reminder in
            Button {
                if reminder.type == .InstantInsight && reminder.firebaseVideoURL == nil && !reminder.isYoutube {
                    refuseLoading.toggle()
                }
                else {
                    selectedReminder = reminder
                }
            } label: {
                ReminderRowView(reminder: reminder, isPreview: true)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 7)
            }
        }
    }
    
    @ViewBuilder
    private var pinnedSectionView: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Pinned")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .padding(.horizontal, 20)
                    .padding(.top, 16)

                if pinned.isEmpty {
                    VStack(spacing: 8) {
                        Text("Choose up to 3 Reminders for Quick Access")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 20)
                            .padding(.top, 16)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 20)
                } else {
                    ForEach(pinned) { reminder in
                        Button {
                            if reminder.type == .InstantInsight && reminder.firebaseVideoURL == nil && !reminder.isYoutube {
                                refuseLoading.toggle()
                            }
                            else {
                                selectedReminder = reminder
                            }
                        } label: {
                            ReminderRowView(reminder: reminder, isPreview: true)
                        }
                        .padding(.horizontal, 16)
                    }
                }
            }
            .padding(.bottom, 8)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(color.shadow(scheme).opacity(0.2), lineWidth: 1)
                    .shadow(color: color.shadow(scheme).opacity(0.15), radius: 8, x: 0, y: 4)
                    .shadow(color: color.shadow(scheme).opacity(0.1), radius: 16, x: 0, y: 8)
            )
            .shadow(color: color.shadow(scheme).opacity(0.15), radius: 8, x: 0, y: 4)
            .shadow(color: color.shadow(scheme).opacity(0.1), radius: 16, x: 0, y: 8)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 5)
    }
    
    @ViewBuilder
    private var foldersSectionView: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 0) {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Folders")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        .padding(.bottom, 12)

                    VStack(spacing: 0) {
                        // All Reminders folder
                        Button {
                            if TutorialManager.shared.inTutorial {
                                TutorialManager.shared.handleTargetViewClick(target: "AllRemindersButton")
                            }
                            selectedFolder = Folder(name: "")
                        } label: {
                            FolderRowView(folder: nil, count: getCount())
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .opacity(1)
                        }
                        .tutorialIdentifier("AllRemindersButton")

                        if !folders.isEmpty {
                            Divider()
                                .padding(.top, 6)
                        }

                        foldersListView
                    }
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(color.shadow(scheme).opacity(0.2), lineWidth: 1)
                    .shadow(color: color.shadow(scheme).opacity(0.15), radius: 8, x: 0, y: 4)
                    .shadow(color: color.shadow(scheme).opacity(0.1), radius: 16, x: 0, y: 8)
            )
            .shadow(color: color.shadow(scheme).opacity(0.15), radius: 8, x: 0, y: 4)
            .shadow(color: color.shadow(scheme).opacity(0.1), radius: 16, x: 0, y: 8)
        }
        .padding(.horizontal, 16)
        .padding(.top, 10)
    }
    
    @ViewBuilder
    private var foldersListView: some View {
        List {
            ForEach(folders) { folder in
                if folder.faceID && folder.isLocked {
                    Button {
                        authenticate(folder)
                    } label: {
                        FolderRowView(folder: folder, count: getCount(folder))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                        if folder != folders.last {
                            Divider()
                        }
                    }

                } else {
                    Button {
                        selectedFolder = folder
                    } label: {
                        FolderRowView(folder: folder, count: getCount(folder))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)

                        if folder != folders.last {
                            Divider()
                        }
                    }
                    .swipeActions{
                        Button("", systemImage: "trash"){
                            folderToDelete = folder
                            deleteAlert.toggle()
                        }
                        .tint(.red)
                    }


                }
            }
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
        }
        .frame(height: CGFloat(55 * folders.count))
        .scrollDisabled(true)
        .listStyle(.plain)
    }
    
    // MARK: - Functions

    func deleteFolder(_ folder: Folder) {
        // Extract URLs before deletion
        let videoURLs = folder.reminders.compactMap { $0.firebaseVideoURL }
        modelContext.delete(folder)

        Task {
            for url in videoURLs {
                await deleteVideo(url)
            }

        }
    }

    func deleteVideo(_ url: String) async {
        FirebaseStorageService.shared.deleteVideo(firebaseURL: url) { _ in }
    }

    func getCount(_ folder: Folder? = nil) -> Int {
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
    func storePinnedReminders(_ newValue: [Reminder]){
        UserDefaults(suiteName: "group.adam.betterself")?.removeObject(forKey: "PinnedReminders")
        var pinnedReminders: [ReminderSnapShot] = []
        pinned.forEach{ reminder in
            if !reminder.isLocked {
                var photoURL: String? = nil
                if let photo = reminder.photo {
                    photoURL = storePhotoForWidget(data: photo, id: UUID())
                }
                let snapShot = ReminderSnapShot(id: reminder.id, title: reminder.title, text: reminder.text, photoURL: photoURL, link: reminder.link, isFront: reminder.isFront, isYoutube: reminder.isYoutube)
                pinnedReminders.append(snapShot)
            }
        }


        if let data = try? JSONEncoder().encode(pinnedReminders) {
            UserDefaults(suiteName: "group.adam.betterself")?.set(data, forKey: "PinnedReminders")
            WidgetCenter.shared.reloadAllTimelines()
        }
        else {
            print("Failed to Encode Reminders")
        }
    }

    func storePhotoForWidget(data: Data, id: UUID) -> String? {
        guard let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.adam.betterself") else { return nil }

        let fileURL = containerURL.appendingPathComponent("\(id).png")

        // Resize image to reduce memory
        if let uiImage = UIImage(data: data),
           let resizedData = resizeImage(uiImage, targetSize: CGSize(width: 50, height: 50)) {
            try? resizedData.write(to: fileURL)
            return fileURL.absoluteString
        }
        return nil
    }
    func resizeImage(_ image: UIImage, targetSize: CGSize) -> Data? {
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        let resized = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }
        return resized.pngData()
    }




    func addNotification(for reminder: Reminder) {

    }


}
#Preview {
    FoldersList(searchText: .constant(""), selectedReminder: .constant(.example), selectedFolder: .constant(.example), showAlert: .constant(false), refuseLoading: .constant(false))
}
