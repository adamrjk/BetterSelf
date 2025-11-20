//
//  ReminderService.swift
//  BetterSelf
//
//  Created by AI Assistant on 19/11/2025.
//

import Foundation
import SwiftData

@MainActor
final class ReminderService {

    let provider: () -> ModelContext
    private let uploadManager = UploadManager.shared

    private var modelContext: ModelContext { provider() }


    init(provider: @escaping () -> ModelContext) {
        self.provider = provider
    }

    func deleteEmptyReminder(_ reminder: Reminder) {
        guard reminder.isChecked == false else { return }
        if reminder.isEmpty {
            modelContext.delete(reminder)
        }
        if (reminder.type != .TimeLessLetter && reminder.photo == nil && !reminder.isLoading) {
            reminder.type = .TimeLessLetter
        }
        reminder.isChecked = true


    }

    static func getLink(_ reminder: Reminder) -> URL {
        if reminder.shareID != nil {
            return reminder.shareLink
        }
        else {
            reminder.shareID = IDGenerator.generateShortID()
            return reminder.shareLink
        }


    }

    func saveReminder(_ title: String,_ url: URL,_ isFront: Bool) {
        let reminder = Reminder(
            title: title,
            text: "",
            link: ""
        )
        reminder.isFront = isFront
        reminder.isChecked = true
        modelContext.insert(reminder)

        uploadManager.loadVideo(reminder, recordedVideoURL: url)

        AnalyticsService.log(AnalyticsService.EventName.reminderCreated, params: [
            "id": reminder.id.uuidString,
            "type": reminder.type.rawValue,
            "has_video":  "true",
            "has_photo": (reminder.photo != nil) ? "true" : "false",
            "has_link": reminder.link.isEmpty ? "false" : "true",
            "source": "video_quick_add"
        ])

    }

    func deleteReminder(_ reminder: Reminder) {
        if let url = reminder.firebaseVideoURL {
            Task {
                await deleteVideo(url)
            }
        }
        AnalyticsService.log(AnalyticsService.EventName.reminderDeleted, params: [
            "id": reminder.id.uuidString,
            "type": reminder.type.rawValue
        ])
        modelContext.delete(reminder)
    }



    func deleteVideo(_ url: String) async {
        FirebaseStorageService.shared.deleteVideo(firebaseURL: url) { _ in }
    }


    static func loadData() -> Sorting {
        if let data = UserDefaults.standard.data(forKey: "AllRemindersSorting") {
            if let decoded = try? JSONDecoder().decode(Sorting.self, from: data) {
                return decoded
            }
        }
        return .dateOld
    }
    static func saveData(_ newSorting: Sorting) {
        if let data = try? JSONEncoder().encode(newSorting) {
            UserDefaults.standard.set(data, forKey: "AllRemindersSorting")
        }
    }

    static func isFirstId(_ reminder: Reminder, _ sortedReminders: [Reminder]) -> String {
        if let first = sortedReminders.first {
            reminder.id == first.id  ? "FirstReminderButton" : "RemindersButton"
        }
        else {
            "RemindersButton"
        }

    }



}


