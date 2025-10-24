//
//  FolderViewModel.swift
//  BetterSelf
//
//  Created by Adam Damou on 24/10/2025.
//

import SwiftUI
import SwiftData

final class FolderViewModel: ObservableObject {
    init() {}

    // MARK: - Reminder Helpers
    func deleteEmptyReminder(_ reminder: Reminder, in modelContext: ModelContext) {
        guard reminder.isChecked == false else { return }
        if reminder.isEmpty {
            modelContext.delete(reminder)
        }
        if (reminder.type != .TimeLessLetter && reminder.photo == nil && !reminder.isLoading) {
            reminder.type = .TimeLessLetter
        }
        reminder.isChecked = true
    }

    func saveRecordedReminder(title: String,
                              isFront: Bool?,
                              recordedVideoURL: URL?,
                              in modelContext: ModelContext,
                              uploadManager: UploadManager) {
        let reminder = Reminder(title: title, text: "", link: "")
        if let front = isFront { reminder.isFront = front }
        reminder.isChecked = true
        modelContext.insert(reminder)
        uploadManager.loadVideo(reminder, recordedVideoURL: recordedVideoURL)
    }

    // MARK: - Folder Helpers
    func deleteEmptyFolder(_ folder: Folder, existingFolders: [Folder], in modelContext: ModelContext) {
        guard folder.isChecked == false else { return }
        let nameIsNotValid = existingFolders.contains { $0.name.lowercased() == folder.name.lowercased() }
        if folder.name.isEmpty || nameIsNotValid {
            modelContext.delete(folder)
        } else {
            folder.isChecked = true
        }
    }

    // MARK: - Tutorial
    func ensureWelcomeShown() {
        if UserDefaults().bool(forKey: "Tutorial \(NotificationManager.shared.version)") {
            return
        } else {
            TutorialManager.shared.getStarted()
            UserDefaults().set(true, forKey: "Tutorial \(NotificationManager.shared.version)")
        }
    }
}


