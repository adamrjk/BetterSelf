//
//  Destinations.swift
//  BetterSelf
//
//  Created by Adam Damou on 18/11/2025.
//

import Foundation

// Push-style navigation destinations
struct FolderDestination: Identifiable, Hashable {
    let id = UUID()
}

struct HomeDestination: Identifiable, Hashable {
    let id = UUID()
    let folder: Folder
}

struct ReminderDestination: Identifiable, Hashable {
    let id = UUID()
    let reminder: Reminder
}

// Sheet-style destinations
enum SheetDestination: Identifiable {
    case addReminder(Reminder) // optional reminder for editing
    case settings
    case addFolder(Folder)
    case camera

    var id: String {
        switch self {
        case .addReminder: return "addReminder"
        case .settings: return "settings"
        case .addFolder: return "addFolder"
        case .camera: return "camera"
        }
    }
}
