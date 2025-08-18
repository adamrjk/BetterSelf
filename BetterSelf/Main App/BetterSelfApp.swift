//
//  BetterSelfApp.swift
//  BetterSelf
//
//  Created by Adam Damou on 15/08/2025.
//

import SwiftUI

@main
struct BetterSelfApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Reminder.self)
    }
}
