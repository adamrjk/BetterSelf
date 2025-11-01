//
//  FolderListContent.swift
//  BetterSelf
//
//  Created by AI on 24/10/2025.
//

import LocalAuthentication
import SwiftData
import SwiftUI
import WidgetKit

enum FolderListLayoutMode {
    case phone
    case iPad
}

struct FolderListContent: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.isSearching) var isSearching
    @Environment(\.colorScheme) var scheme
    @EnvironmentObject var color: ColorManager

    @Query(filter: #Predicate<Folder> { $0.isChecked == true},
           sort: \Folder.date) var folders: [Folder]

    @Query(filter: #Predicate<Reminder> { $0.isChecked == true },
           sort: \Reminder.date) var reminders: [Reminder]

    @Binding var searchText: String
    @Binding var showAlert: Bool
    @Binding var refuseLoading: Bool

    let mode: FolderListLayoutMode
    let onSelectReminder: (Reminder) -> Void
    let onSelectFolder: (Folder) -> Void

    @State private var deleteAlert = false
    @State private var folderToDelete: Folder?

    private var unlockedReminders: [Reminder] {
        reminders.filter { $0.isLocked == false }
    }

    private var filteredReminders: [Reminder] {
        if searchText.isEmpty { return unlockedReminders }
        return unlockedReminders.filter { $0.title.localizedStandardContains(searchText) }
    }

    private var pinned: [Reminder] {
        var pinned = unlockedReminders.filter { $0.pinned }
        pinned = pinned.sorted { $0.datePinned < $1.datePinned }
        while pinned.count > 3 {
            if let first = pinned.first {
                first.pinned = false
                pinned.removeFirst()
            }
        }
        return pinned
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                if isSearching || !searchText.isEmpty {
                    searchResultsView
                } else {
                    pinnedSectionView
                    foldersSectionView
                }
            }
        }
        .defaultScrollAnchor(.center)
        .animation(.smooth, value: pinned)
        .alert("Are you Sure?", isPresented: $deleteAlert) {
            Button("Delete", role: .destructive) {
                AnalyticsService.log(AnalyticsService.EventName.buttonTapped, params: [
                    "button": "delete_folder_confirm",
                    "view": "FolderListContent",
                    "folder": folderToDelete?.name ?? ""
                ])
                if let folder = folderToDelete { deleteFolder(folder) }
            }
        } message: {
            Text("This will delete all the Reminders in this Folder")
        }
        .onChange(of: pinned) { _, _ in
            storePinnedReminders(pinned)
            if let last = pinned.last {
                addNotification(for: last)
            }
        }
    }

    // MARK: - Subviews

    @ViewBuilder
    private var searchResultsView: some View {
        ForEach(filteredReminders) { reminder in
            Button {
                AnalyticsService.log(AnalyticsService.EventName.buttonTapped, params: [
                    "button": "search_result_open",
                    "view": "FolderListContent",
                    "id": reminder.id.uuidString
                ])
                if reminder.type == .InstantInsight && reminder.firebaseVideoURL == nil && !reminder.isYoutube {
                    refuseLoading.toggle()
                } else {
                    onSelectReminder(reminder)
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
                    if mode == .iPad {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 320, maximum: 480), spacing: 16)], spacing: 12) {
                            ForEach(pinned) { reminder in
                                Button {
                                    AnalyticsService.log(AnalyticsService.EventName.buttonTapped, params: [
                                        "button": "pinned_open",
                                        "view": "FolderListContent",
                                        "id": reminder.id.uuidString
                                    ])
                                    if reminder.type == .InstantInsight && reminder.firebaseVideoURL == nil && !reminder.isYoutube {
                                        refuseLoading.toggle()
                                    } else {
                                        onSelectReminder(reminder)
                                    }
                                } label: {
                                    ReminderRowView(reminder: reminder, isPreview: true)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                    } else {
                        ForEach(pinned) { reminder in
                            Button {
                                AnalyticsService.log(AnalyticsService.EventName.buttonTapped, params: [
                                    "button": "pinned_open",
                                    "view": "FolderListContent",
                                    "id": reminder.id.uuidString
                                ])
                                if reminder.type == .InstantInsight && reminder.firebaseVideoURL == nil && !reminder.isYoutube {
                                    refuseLoading.toggle()
                                } else {
                                    onSelectReminder(reminder)
                                }
                            } label: {
                                ReminderRowView(reminder: reminder, isPreview: true)
                            }
                            .padding(.horizontal, 16)
                        }
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
                        Button {
                            AnalyticsService.log(AnalyticsService.EventName.buttonTapped, params: [
                                "button": "open_all_reminders",
                                "view": "FolderListContent"
                            ])
                            if TutorialManager.shared.inTutorial {
                                TutorialManager.shared.handleTargetViewClick(target: "AllRemindersButton")
                            }
                            onSelectFolder(Folder(name: ""))
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
                    Button { AnalyticsService.log(AnalyticsService.EventName.buttonTapped, params: [
                        "button": "authenticate_folder",
                        "view": "FolderListContent",
                        "folder": folder.name
                    ]); authenticate(folder) } label: {
                        FolderRowView(folder: folder, count: getCount(folder))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                        if folder != folders.last { Divider() }
                    }
                } else {
                    Button { AnalyticsService.log(AnalyticsService.EventName.buttonTapped, params: [
                        "button": "open_folder",
                        "view": "FolderListContent",
                        "folder": folder.name
                    ]); onSelectFolder(folder) } label: {
                        FolderRowView(folder: folder, count: getCount(folder))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                        if folder != folders.last { Divider() }
                    }
                    .swipeActions {
                        Button("", systemImage: "trash") {
                            AnalyticsService.log(AnalyticsService.EventName.buttonTapped, params: [
                                "button": "folder_delete_swipe",
                                "view": "FolderListContent",
                                "folder": folder.name
                            ])
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

    private func deleteFolder(_ folder: Folder) {
        let videoURLs = folder.reminders.compactMap { $0.firebaseVideoURL }
        modelContext.delete(folder)
        Task {
            for url in videoURLs { await deleteVideo(url) }
        }
    }

    private func deleteVideo(_ url: String) async {
        FirebaseStorageService.shared.deleteVideo(firebaseURL: url) { _ in }
    }

    private func getCount(_ folder: Folder? = nil) -> Int {
        if let folder = folder {
            let id = folder.persistentModelID
            return unlockedReminders.filter { $0.folder?.persistentModelID == id }.count
        } else {
            return unlockedReminders.count
        }
    }

    private func authenticate(_ folder: Folder) {
        let context = LAContext()
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Please authenticate yourself to unlock your reminders."
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, _ in
                if success {
                    folder.isLocked = false
                } else {
                    context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: "Enter your device passcode to unlock your reminders.") { success, _ in
                        if success { folder.isLocked = false }
                    }
                }
            }
        } else {
            showAlert = true
        }
    }

    private func storePinnedReminders(_ newValue: [Reminder]) {
        UserDefaults(suiteName: "group.adam.betterself")?.removeObject(forKey: "PinnedReminders")
        var pinnedReminders: [ReminderSnapShot] = []
        pinned.forEach { reminder in
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
    }

    private func storePhotoForWidget(data: Data, id: UUID) -> String? {
        guard let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.adam.betterself") else { return nil }
        let fileURL = containerURL.appendingPathComponent("\(id).png")
        if let uiImage = UIImage(data: data),
           let resizedData = resizeImage(uiImage, targetSize: CGSize(width: 50, height: 50)) {
            try? resizedData.write(to: fileURL)
            return fileURL.absoluteString
        }
        return nil
    }

    private func resizeImage(_ image: UIImage, targetSize: CGSize) -> Data? {
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        let resized = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }
        return resized.pngData()
    }

    private func addNotification(for reminder: Reminder) {
        // Reserved for future use
    }
}


