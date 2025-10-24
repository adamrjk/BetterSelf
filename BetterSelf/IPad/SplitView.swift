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
    @Environment(\.modelContext) var modelContext
    @StateObject var color = ColorManager.shared

    @State private var selectedReminder: Reminder?
    @State private var selectedFolder = Folder(name: "")
    @State private var columnVisibility: NavigationSplitViewVisibility = .automatic
    @State private var addReminder = false
    @State private var newReminder: Reminder?
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
                } else {
                    IPadHomeView(folder: selectedFolder, selectedReminder: $selectedReminder)
                }
            }
        } detail: {

            if let reminder = selectedReminder {
                ZStack {
                    IPadReminderView(reminder: reminder, selectedFolder: $selectedFolder, onExpandDetail:{
                        withAnimation {
                            columnVisibility = (columnVisibility == .detailOnly) ? .all : .detailOnly
                        }
                    }, isDetailOnly: columnVisibility == .detailOnly, column: $columnVisibility)
                    .id(reminder.id)

                    if columnVisibility != .detailOnly {
                        Button{
                            let reminder = Reminder(title: "", text: "", link: "", folder: selectedFolder)
                            modelContext.insert(reminder)
                            newReminder = reminder
                            addReminder.toggle()
                        }label: {
                            Image(systemName: "plus")
                                .font(.title2)
                                .foregroundStyle(scheme == .light ? .white : .black)
                                .padding(20)
                        }
                        .tutorialIdentifier("PlusButton")
                        .adaptiveTranslucent(color.plusButton(scheme))
                        .clipShape(.circle)
                        .padding(.trailing, 10)
                        .padding(.bottom, reminder.type == .InstantInsight ? 100 : 0)
                    }
                }
            }

            else {
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

                        if columnVisibility != .detailOnly {
                                VStack {
                                    Spacer()
                                    HStack {

                                        Spacer()
                                        Button{
                                            let reminder = Reminder(title: "", text: "", link: "", folder: selectedFolder)
                                            modelContext.insert(reminder)
                                            newReminder = reminder
                                            addReminder.toggle()
                                        }label: {
                                            Image(systemName: "plus")
                                                .font(.title2)
                                                .foregroundStyle(scheme == .light ? .white : .black)
                                                .padding(20)
                                        }
                                        .tutorialIdentifier("PlusButton")
                                        .adaptiveTranslucent(color.plusButton(scheme))
                                        .clipShape(.circle)
                                        .padding(.trailing, 10)
                                        .padding(.bottom, 0)
                                    }
                                }

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
        .sheet(isPresented: $addReminder, onDismiss: deleteEmptyReminder) {
            if let reminder = newReminder {
                if #available(iOS 18.0, *) {
                    AddReminderView(reminder: reminder)
                        .presentationDetents([.height(800)])
                        .presentationSizing(.page)
                        .presentationDragIndicator(.visible)
                } else {
                    AddReminderView(reminder: reminder)
                        .presentationDetents([.large])
                        .presentationDragIndicator(.visible)
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
}

#Preview {
    SplitView(notifReminder: .constant(nil))
}
