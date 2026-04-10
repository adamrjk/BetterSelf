//
//  HomeViewModel.swift
//  BetterSelf
//
//  Created by Adam Damou on 20/11/2025.
//

import Foundation
import Observation

@MainActor
@Observable
final class HomeViewModel: ObservableObject {
    var searchText = ""
    var selection = Set<UUID>()
    var deleteAlert = false
    var moveToFolder = false
    var refuseLoading = false
    var remindersToMove: [Reminder] = []
    var reminderToDelete: Reminder?
    var sorting: Sorting = .dateNew

    @ObservationIgnored private var reminderService: ReminderService?
    @ObservationIgnored private weak var flow: AppFlow?

    init() {}

    func configure(reminderService: ReminderService, flow: AppFlow, folder : Folder?) {
        self.reminderService = reminderService
        self.flow = flow
        self.sorting = folder?.sorting ?? ReminderService.loadData()
    }

    func moveSelected(from reminders: [Reminder]) {
        remindersToMove = reminders.filter { selection.contains($0.id) }
        moveToFolder.toggle()
    }

    func unlockSortAndFilter(_ reminders: [Reminder]) -> [Reminder] {
        let unlockedReminders = reminders.filter{
            $0.isLocked == false
        }

        let filteredReminders = searchText.isEmpty ? unlockedReminders : unlockedReminders.filter { $0.title.localizedStandardContains(searchText) }

        switch sorting {
        case .dateOld:
            return filteredReminders.sorted{ $0.date < $1.date}
        case .dateNew:
            return filteredReminders.sorted{ $0.date > $1.date}
        case .name:
            return filteredReminders.sorted{ $0.title < $1.title}
        }

    }

    func confirmDelete(from reminders: [Reminder]) {
        guard let reminderService else { return }

        if selection.isEmpty {
            if let reminder = reminderToDelete {
                reminderService.deleteReminder(reminder)
            }
        } else {
            let selectedReminders = reminders.filter { selection.contains($0.id) }
            selectedReminders.forEach { reminder in
                reminderService.deleteReminder(reminder)
            }
        }
    }

    func requestDelete(_ reminder: Reminder?) {
        reminderToDelete = reminder
        deleteAlert = true
    }

}
