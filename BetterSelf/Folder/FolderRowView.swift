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
    
    var body: some View {
        HStack {
            Image(systemName: "folder.fill")
                .font(.title3)
            Text(folder?.name ?? "All Reminders")
            
            
            Spacer()
            
            if let folder = folder {
                if folder.faceID && folder.isLocked {
                    Image(systemName: "lock.fill")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                else {
                    Text("\(count)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            
            else {
                Text("\(count)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Image(systemName: "chevron.right")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundStyle(.secondary)


            
            
        }
    }
}

#Preview {
    FolderRowView(folder: .example)
}
