//
//  Destinations.swift
//  BetterSelf
//
//  Created by Adam Damou on 18/11/2025.
//

import SwiftUI
import SwiftData



// Push-style navigation destinations
struct FolderDestination: Identifiable, Hashable {
    let id = UUID()
}

struct HomeDestination: Identifiable, Hashable {
    let id = UUID()
    let folder: Folder
}

struct AllRemindersDestination: Identifiable, Hashable{
    let id = UUID()
}

struct ReminderDestination: Identifiable, Hashable {
    let id = UUID()
    let reminder: Reminder
}

// Value-based routing for Reminders tab
enum InsightsDestination {
    case folder(Folder)
    case allReminders
    case reminder(Reminder)
    case allFolders
}



extension InsightsDestination: NavigationDestination {
    public var body: some View {
        switch self {
        case .folder(let folder):
            HomeView(folder: folder)

        case .allReminders:
            HomeView()
        case .reminder(let reminder):
            ReminderView(reminder: reminder)

        case .allFolders:
            FolderView()
        }
    }

}

// Sheet-style destinations
enum SheetDestination {
    case addReminder(Reminder) // optional reminder for editing
    case settings
    case addFolder(Folder)
    case camera(RecordingHandler)
    case titleSheet
    case share(URL)
}



extension SheetDestination: NavigationDestination {
    public var body: some View {
        switch self {
        case .addFolder(let folder):
            AddFolderView(folder: folder)
        case .addReminder(let reminder):
            AddReminderView(reminder: reminder)
        case .camera(let handler):
            CustomCameraView(
                onVideoRecorded: { url, isFront in
                    handler.onVideoRecorded(url, isFront)
                }
            )
            .ignoresSafeArea()
        case .settings:
            SettingsView()
        case .share(let url):
            ShareSheet(activityItems: [url])
        case .titleSheet:
            AddTitleSheet(title: "")
                .presentationDetents([.height(300)])
        }


    }

}

struct RecordingHandler: Hashable, Equatable {
    let id = UUID()
    let onVideoRecorded: (URL, Bool) -> Void
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
    static func ==(lhs: RecordingHandler, rhs: RecordingHandler) -> Bool { lhs.id == rhs.id}
}

