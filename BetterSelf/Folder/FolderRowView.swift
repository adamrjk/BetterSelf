//
//  FolderRowView.swift
//  BetterSelf
//
//  Created by Adam Damou on 05/09/2025.
//

import SwiftData
import SwiftUI

struct FolderRowView: View {
    @Query var reminders: [Reminder]
    let folder: Folder?


    var count: Int {
        folder?.reminders.count ?? reminders.count
    }
    var body: some View {
        HStack {
            Image(systemName: "folder.fill")
            Text(folder?.name ?? "All Reminders")
                

            Spacer()

            Text("\(count)")
                .font(.subheadline)
                .foregroundStyle(.secondary)

        }

    }
}

#Preview {
    FolderRowView(folder: .example)
}
