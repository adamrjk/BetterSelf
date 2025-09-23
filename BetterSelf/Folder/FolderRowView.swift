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

    var unlockedReminders: [Reminder]{
        reminders.filter{
            $0.isLocked == false
        }
    }

    let folder: Folder?
    
    
    var count: Int {
        folder?.reminders.count ?? unlockedReminders.count
    }

    @StateObject var color = ColorManager.shared


    var body: some View {
        HStack {
            Image(systemName: "folder.fill")
                .foregroundColor(.primary)
                .font(.title3)
            Text(folder?.name ?? "All Reminders")
                .foregroundColor(.primary)

            
            Spacer()
            
            if let folder = folder {
                if folder.faceID && folder.isLocked {
                    Image(systemName: "lock.fill")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                else {
                    Text("\(count)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            else {
                Text("\(count)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Image(systemName: "chevron.right")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.secondary)


            
            
        }
    }
}

#Preview {
    FolderRowView(folder: .example)
}
