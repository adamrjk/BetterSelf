//
//  HomeListContent.swift
//  BetterSelf
//
//  Created by AI on 24/10/2025.
//

import SwiftUI
import SwiftData

enum HomeListLayoutMode {
    case phone
    case iPad
}

struct HomeListContent: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.editMode) var editMode
    @Environment(\.colorScheme) var scheme
    @EnvironmentObject var color: ColorManager

    private let folder: Folder?
    let mode: HomeListLayoutMode

    @Query private var reminders: [Reminder]

    @Binding var searchText: String
    @Binding var refuseLoading: Bool
    @Binding var selection: Set<Reminder.ID>

    let sorting: Sorting
    let selectedReminderId: Reminder.ID?

    let onSelectReminder: (Reminder) -> Void
    let onRequestDelete: (Reminder) -> Void
    let onRequestMove: (Reminder) -> Void
    let onShare: ((Reminder) -> Void)?

    init(folder: Folder?,
         mode: HomeListLayoutMode,
         searchText: Binding<String>,
         refuseLoading: Binding<Bool>,
         selection: Binding<Set<Reminder.ID>>,
         sorting: Sorting,
         onSelectReminder: @escaping (Reminder) -> Void,
         onRequestDelete: @escaping (Reminder) -> Void,
         onRequestMove: @escaping (Reminder) -> Void,
         onShare: ((Reminder) -> Void)? = nil,
         selectedReminderId: Reminder.ID? = nil) {
        self.folder = folder
        self.mode = mode
        _searchText = searchText
        _refuseLoading = refuseLoading
        _selection = selection
        self.sorting = sorting
        self.onSelectReminder = onSelectReminder
        self.onRequestDelete = onRequestDelete
        self.onRequestMove = onRequestMove
        self.onShare = onShare
        self.selectedReminderId = selectedReminderId

        if let folder = folder {
            let id = folder.persistentModelID
            _reminders = Query(filter: #Predicate<Reminder> { $0.folder?.persistentModelID == id })
        } else {
            _reminders = Query(filter: #Predicate<Reminder> { $0.isChecked == true })
        }
    }

    private var unlockedReminders: [Reminder] { reminders.filter { $0.isLocked == false } }

    private var filteredReminders: [Reminder] {
        if searchText.isEmpty { return unlockedReminders }
        return unlockedReminders.filter { $0.title.localizedStandardContains(searchText) }
    }

    private var sortedReminders: [Reminder] {
        switch sorting {
        case .dateOld: return filteredReminders.sorted { $0.date < $1.date }
        case .dateNew: return filteredReminders.sorted { $0.date > $1.date }
        case .name: return filteredReminders.sorted { $0.title < $1.title }
        }
    }

    var body: some View {
        List(selection: $selection) {
            ForEach(sortedReminders) { reminder in
                let isSelected = (selectedReminderId == reminder.id)
                Button {
                    if editMode?.wrappedValue == .active {
                        // In edit mode, taps should toggle selection, not activate navigation
                        return
                    }
                    if reminder.isLoading && reminder.firebaseVideoURL == nil {
                        refuseLoading.toggle()
                    } else {
                        onSelectReminder(reminder)
                    }
                } label: {
                    ReminderRowView(reminder: reminder, isPreview: false)
                        .background(
                            Group {
                                if isSelected {
                                    color.cardBackground(scheme).opacity(0.25)
                                } else {
                                    Color.clear
                                }
                            }
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(isSelected ? color.button(scheme) : Color.clear, lineWidth: isSelected ? 1.5 : 0)
                        )
                        .shadow(color: isSelected ? color.shadow(scheme).opacity(0.35) : color.shadow(scheme).opacity(0.15), radius: isSelected ? 18 : 8, x: 0, y: isSelected ? 10 : 4)
                }
                .tutorialIdentifier(isFirstId(reminder))
                .swipeActions {
                    Button("", systemImage: "trash") {
                        onRequestDelete(reminder)
                    }
                    .tint(.red)

                    Button("", systemImage: "folder.fill") {
                        onRequestMove(reminder)
                    }
                    .tint(.black)
                }
                .tag(reminder.id)
                .swipeActions(edge: .leading) {
                    Button("", systemImage: "pin.fill") {
                        reminder.pinned.toggle()
                        if reminder.pinned { reminder.datePinned = .now }
                    }
                    .tint(.orange)

                    if let onShare = onShare {
                        Button {
                            onShare(reminder)
                        } label: {
                            Image(systemName: "square.and.arrow.up")
                        }
                        .tint(.green)
                    }
                }
                .tag(reminder.id)
            }
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
        }
        .searchable(text: $searchText, placement: .navigationBarDrawer, prompt: "Search for a Reminder")
        .listStyle(.plain)
        .padding(0)
    }

    private func isFirstId(_ reminder: Reminder) -> String {
        if let first = sortedReminders.first {
            return reminder.id == first.id ? "FirstReminderButton" : "RemindersButton"
        } else {
            return "RemindersButton"
        }
    }
}


