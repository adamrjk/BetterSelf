//
//  SplitView.swift
//  BetterSelf
//
//  Created by Adam Damou on 18/10/2025.
//

import SwiftUI
import SwiftData

struct SplitView: View {
    @Binding var notifReminder: NavigableReminder?
    @Environment(\.colorScheme) var scheme
    @StateObject var color = ColorManager.shared

    @State private var selectedReminder: Reminder?
    @State private var selectedFolder = Folder(name: "")
    @State private var columnVisibility: NavigationSplitViewVisibility = .automatic
    @Query(filter: #Predicate<Reminder> { $0.isChecked == true }, sort: \Reminder.date) var reminders: [Reminder]

    private var unlockedReminders: [Reminder] {
        reminders.filter { $0.isLocked == false }
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
        NavigationSplitView(columnVisibility: $columnVisibility) {
            // Sidebar (Folders)
            IPadFolderView(selectedReminder: $selectedReminder, selectedFolder: $selectedFolder)
        } content: {
            // Content (Reminders list for selected folder)
            NavigationStack {
                if selectedFolder.name.isEmpty {
                    IPadHomeView(selectedReminder: $selectedReminder)
//                    IPadHomeView(onSelectReminder: { reminder in
//                        selectedReminder = reminder
//                        columnVisibility = .doubleColumn
//                    }, onToggleSidebar: {
//                        withAnimation { columnVisibility = (columnVisibility == .detailOnly) ? .all : .detailOnly }
//                    })
                } else {
//                    IPadHomeView(folder: selectedFolder, onSelectReminder: { reminder in
//                        selectedReminder = reminder
//                        columnVisibility = .doubleColumn
//                    }, onToggleSidebar: {
//                        withAnimation { columnVisibility = (columnVisibility == .detailOnly) ? .all : .detailOnly }
//                    })
                    IPadHomeView(folder: selectedFolder, selectedReminder: $selectedReminder)
                }
            }
        } detail: {

                if let reminder = selectedReminder {
                    IPadReminderView(reminder: reminder, selectedFolder: $selectedFolder, onExpandDetail: {
                        withAnimation {
                            columnVisibility = (columnVisibility == .detailOnly) ? .all : .detailOnly
                        }
                    })
                    .id(reminder.id)

                } else {
                    ZStack {
                        color.mainGradient(scheme)
                            .ignoresSafeArea()
                        color.overlayGradient(scheme)
                            .ignoresSafeArea()
                        VStack(spacing: 12) {
                            Text("Select a Reminder")
                                .font(.headline)
                                .foregroundStyle(.secondary)

                        }
                    }
                }
        }
        .navigationSplitViewColumnWidth(min: 300, ideal: 320, max: 400)
        .onAppear {
            // Default to All Reminders and first pinned, if any
            selectedFolder = Folder(name: "")
            columnVisibility = .doubleColumn
            if selectedReminder == nil, let firstPinned = pinned.first {
                selectedReminder = firstPinned
            }
        }
        .onChange(of: notifReminder) { _, newValue in
            if let nav = newValue {
                // Ensure detail column is visible when navigating via notification
                columnVisibility = .all
                if let folder = nav.reminder.folder {
                    selectedFolder = folder
                } else {
                    selectedFolder = Folder(name: "")
                }
                selectedReminder = nav.reminder
            }
        }
        .onChange(of: selectedFolder) { _, _ in
            // Reset detail when switching folders
            selectedReminder = nil
        }
    }
}

#Preview {
    SplitView(notifReminder: .constant(nil))
}
