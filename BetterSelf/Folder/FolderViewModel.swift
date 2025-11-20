//
//  FolderViewModel.swift
//  BetterSelf
//
//  Created by Adam Damou on 24/10/2025.
//

@preconcurrency import LocalAuthentication
import SwiftUI
import SwiftData
import WidgetKit


@MainActor
@Observable
final class FolderViewModel: ObservableObject {


    var searchText = ""
    var showAlert = false
    var refuseLoading = false
    var folderToDelete: Folder?
    var deleteAlert = false


    @ObservationIgnored private var reminderService: ReminderService?
    @ObservationIgnored private var folderService: FolderService?
    @ObservationIgnored private weak var flow: AppFlow?

    init() {}

    func filter(_ unlockedReminders: [Reminder]) -> [Reminder] {
        if searchText.isEmpty { return unlockedReminders }
        return unlockedReminders.filter { $0.title.localizedStandardContains(searchText) }
    }

    func requestDelete(_ folder: Folder){
        folderToDelete = folder
        deleteAlert.toggle()
    }
    func getPinned(_ unlockedReminders: [Reminder]) -> [Reminder] {
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

    func configure(folderService: FolderService, reminderService: ReminderService, flow: AppFlow) {
        self.reminderService = reminderService
        self.flow = flow
    }

    func authenticate(_ folder: Folder) {
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

    func storePinnedReminders(_ pinned: [Reminder]) {
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

    func storePhotoForWidget(data: Data, id: UUID) -> String? {
        guard let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.adam.betterself") else { return nil }
        let fileURL = containerURL.appendingPathComponent("\(id).png")
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
        // Reserved for future use
    }



}


