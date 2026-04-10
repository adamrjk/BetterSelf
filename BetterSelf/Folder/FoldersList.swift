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

// MARK: - Compatibility wrapper
// Uses existing FoldersList on iOS 18/26+, and a safer iOS 17 layout to avoid nested scroll issues
struct FoldersListCompat: View {
    @Binding var searchText: String
    @Binding var selectedReminder: Reminder?
    @Binding var selectedFolder: Folder?
    @Binding var showAlert: Bool
    @Binding var refuseLoading: Bool

    var body: some View {
        if #available(iOS 18, *) {
            FoldersList(
                searchText: $searchText,
                selectedReminder: $selectedReminder,
                selectedFolder: $selectedFolder,
                showAlert: $showAlert,
                refuseLoading: $refuseLoading
            )
        } else {
            FoldersList_iOS17(
                searchText: $searchText,
                selectedReminder: $selectedReminder,
                selectedFolder: $selectedFolder,
                showAlert: $showAlert,
                refuseLoading: $refuseLoading
            )
        }
    }
}

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
        AnalyticsService.log(AnalyticsService.EventName.folderDeleted, params: [
            "name": folder.name,
            "reminders_count": String(folder.reminders.count)
        ])
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
                let snapShot = ReminderSnapShot(id: reminder.id, title: reminder.title, text: reminder.text, photoURL: reminder.photoURL, link: reminder.link, isFront: reminder.isFront, isYoutube: reminder.isYoutube)
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

#if !os(macOS)
// MARK: - iOS 17 specific implementation (no nested List inside ScrollView)
struct FoldersList_iOS17: View {
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
        reminders.filter{ $0.isLocked == false }
    }
    var filteredReminders: [Reminder] {
        if searchText.isEmpty { unlockedReminders }
        else { unlockedReminders.filter { $0.title.localizedStandardContains(searchText) } }
    }

    var pinned: [Reminder] {
        var pinned = unlockedReminders.filter{ $0.pinned}
        pinned = pinned.sorted{ $0.datePinned < $1.datePinned }
        while pinned.count > 3 {
            if let first = pinned.first { first.pinned = false; pinned.removeFirst() }
        }
        return pinned
    }
    @Environment(\.colorScheme) var scheme
    @EnvironmentObject var color: ColorManager

    var body: some View {
        List {
            if isSearching || !searchText.isEmpty {
                searchResults
            } else {
                pinnedSection
                foldersSection
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Color.clear)
        .alert("Are you Sure?", isPresented: $deleteAlert){
            Button("Delete", role: .destructive){
                AnalyticsService.log(AnalyticsService.EventName.buttonTapped, params: [
                    "button": "delete_folder_confirm",
                    "view": "FoldersList",
                    "folder": folderToDelete?.name ?? ""
                ])
                if let folder = folderToDelete { deleteFolder(folder) }
            }
        } message: { Text("This will delete all the Reminders in this Folder") }
    }

    // MARK: - Subviews
    @ViewBuilder private var searchResults: some View {
        ForEach(filteredReminders){ reminder in
            Button {
                AnalyticsService.log(AnalyticsService.EventName.buttonTapped, params: [
                    "button": "search_result_open",
                    "view": "FoldersList",
                    "id": reminder.id.uuidString
                ])
                if reminder.type == .InstantInsight && reminder.firebaseVideoURL == nil && !reminder.isYoutube {
                    refuseLoading.toggle()
                } else {
                    selectedReminder = reminder
                }
            } label: {
                ReminderRowView(reminder: reminder, isPreview: true)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 7)
            }
        }
    }

    @ViewBuilder private var pinnedSection: some View {
        Section {
            if pinned.isEmpty {
                Text("Choose up to 3 Reminders for Quick Access")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .listRowBackground(Color.clear)
            } else {
                ForEach(pinned) { reminder in
                    Button {
                        AnalyticsService.log(AnalyticsService.EventName.buttonTapped, params: [
                            "button": "pinned_open",
                            "view": "FoldersList",
                            "id": reminder.id.uuidString
                        ])
                        if reminder.type == .InstantInsight && reminder.firebaseVideoURL == nil && !reminder.isYoutube {
                            refuseLoading.toggle()
                        } else {
                            selectedReminder = reminder
                        }
                    } label: {
                        ReminderRowView(reminder: reminder, isPreview: true)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(color.cardBackground(scheme))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .stroke(color.shadow(scheme).opacity(0.2), lineWidth: 1)
                            )
                            .shadow(color: color.shadow(scheme).opacity(0.15), radius: 8, x: 0, y: 4)
                            .shadow(color: color.shadow(scheme).opacity(0.1), radius: 16, x: 0, y: 8)
                    }
                    .buttonStyle(.plain)
                    .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                    .listRowBackground(Color.clear)
                }
            }
        } header: {
            Text("Pinned")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .padding(.horizontal, 20)
                .padding(.top, 16)
        }
    }

    @ViewBuilder private var foldersSection: some View {
        Section {
            let total = folders.count + 2 // title + All Reminders + folders

            // index 0: Title row inside the container
            HStack {
                Text("Folders")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .padding(.leading, 20)
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 16)
            .padding(.bottom, 12)
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            .listRowBackground(Color.clear)
            .background(containerBackground(index: 0, total: total))
            .padding(.top, 6)

            // index 1: All Reminders
            Button {
                AnalyticsService.log(AnalyticsService.EventName.buttonTapped, params: [
                    "button": "open_all_reminders",
                    "view": "FoldersList"
                ])
                if TutorialManager.shared.inTutorial {
                    TutorialManager.shared.handleTargetViewClick(target: "AllRemindersButton")
                }
                selectedFolder = Folder(name: "")
            } label: {
                FolderRowView(folder: nil, count: getCount())
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.plain)
            .tutorialIdentifier("AllRemindersButton")
            .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
            .listRowBackground(Color.clear)
            .background(containerBackground(index: 1, total: total))

            // Remaining rows: real folders with swipe actions
            ForEach(Array(folders.enumerated()), id: \.element.persistentModelID) { idx, folder in
                let rowIndex = idx + 2
                Button {
                    AnalyticsService.log(AnalyticsService.EventName.buttonTapped, params: [
                        "button": "folder_row_tap",
                        "view": "FoldersList",
                        "folder": folder.name
                    ])
                    if folder.faceID && folder.isLocked {
                        authenticate(folder)
                    } else {
                        selectedFolder = folder
                    }
                } label: {
                    FolderRowView(folder: folder, count: getCount(folder))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                }
                .buttonStyle(.plain)
                .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                .listRowBackground(Color.clear)
                .background(containerBackground(index: rowIndex, total: total))
                .padding(.bottom, rowIndex == total - 1 ? 6 : 0)
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive) {
                        AnalyticsService.log(AnalyticsService.EventName.buttonTapped, params: [
                            "button": "folder_delete_swipe",
                            "view": "FoldersList",
                            "folder": folder.name
                        ])
                        folderToDelete = folder
                        deleteAlert.toggle()
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
        }
    }

    // One big rounded rectangle background spanning all folder rows
    @ViewBuilder
    private func containerBackground(index: Int, total: Int) -> some View {
        let stroke = color.shadow(scheme).opacity(0.2)
        let topRadius: CGFloat = index == 0 ? 16 : 0
        let bottomRadius: CGFloat = index == total - 1 ? 16 : 0
        let shape = UnevenRoundedRectangle(
            cornerRadii: .init(topLeading: topRadius, bottomLeading: bottomRadius, bottomTrailing: bottomRadius, topTrailing: topRadius)
        )
        shape
            .fill(color.cardBackground(scheme))
            .overlay(shape.stroke(stroke, lineWidth: 1))
            .overlay(alignment: .bottom) {
                if index < total - 1 {
                    Rectangle()
                        .fill(stroke)
                        .frame(height: 0.5)
                        .padding(.leading, 16)
                        .padding(.trailing, 16)
                }
            }
            .shadow(color: color.shadow(scheme).opacity(0.15), radius: 8, x: 0, y: 4)
            .shadow(color: color.shadow(scheme).opacity(0.1), radius: 16, x: 0, y: 8)
    }

    // MARK: - Functions (duplicated minimal to keep isolation)
    func deleteFolder(_ folder: Folder) {
        let videoURLs = folder.reminders.compactMap { $0.firebaseVideoURL }
        modelContext.delete(folder)
        Task { for url in videoURLs { await deleteVideo(url) } }
    }
    func deleteVideo(_ url: String) async {
        FirebaseStorageService.shared.deleteVideo(firebaseURL: url) { _ in }
    }
    func getCount(_ folder: Folder? = nil) -> Int {
        if let folder = folder {
            let id = folder.persistentModelID
            return unlockedReminders.filter({ $0.folder?.persistentModelID == id }).count
        } else {
            return unlockedReminders.count
        }
    }
    func authenticate(_ folder: Folder) {
        let context = LAContext()
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Please authenticate yourself to unlock your reminders."
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, _ in
                if success { folder.isLocked = false } else {
                    context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: "Enter your device passcode to unlock your reminders.") { success, _ in
                        if success { folder.isLocked = false }
                    }
                }
            }
        } else { showAlert = true }
    }
}
#endif
