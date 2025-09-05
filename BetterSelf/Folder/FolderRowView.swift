//
//  FolderRowView.swift
//  BetterSelf
//
//  Created by Adam Damou on 05/09/2025.
//

import SwiftUI

struct FolderRowView: View {
    let folder: Folder?


    var body: some View {
        HStack {
            Image(systemName: "folder.fill")
            Text(folder?.name ?? "All Reminders")

        }

    }
}

#Preview {
    FolderRowView(folder: .example)
}
