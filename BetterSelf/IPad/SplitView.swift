//
//  SplitView.swift
//  BetterSelf
//
//  Created by Adam Damou on 18/10/2025.
//

import SwiftUI

struct SplitView: View {
    @Binding var notifReminder: NavigableReminder?

    @State private var selectedReminder: Reminder?
    @State private var selectedFolder = Folder(name: "")
    var body: some View {
        NavigationSplitView(sidebar: {
            IPadFolderView(selectedReminder: $selectedReminder, selectedFolder: $selectedFolder)
        }, detail: {
                if selectedFolder.name.isEmpty {
                    HomeView()
                }
                else {
                    HomeView(folder: selectedFolder)
                }


        })
//        .navigationDestination(item: $notifReminder){ navReminder in
//            ReminderView(reminder: navReminder.reminder)
//        }
    }
}

#Preview {
    SplitView(notifReminder: .constant(nil))
}
