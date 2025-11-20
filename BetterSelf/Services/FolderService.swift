//
//  FolderService.swift
//  BetterSelf
//
//  Created by AI Assistant on 19/11/2025.
//

import Foundation
import SwiftData

@MainActor
final class FolderService {
    let provider: () -> ModelContext


    init(provider: @escaping () -> ModelContext) {
        self.provider = provider
    }

    func deleteEmptyFolder(_ folder: Folder) {
        guard folder.isChecked == false else { return }

        #warning("Handle Identical folder name")
        if folder.name.isEmpty{
            provider().delete(folder)
        }
        else {
            folder.isChecked = true
            AnalyticsService.log(AnalyticsService.EventName.folderCreated, params: [
                "name": folder.name
            ])
        }
    }


    func deleteFolder(_ folder: Folder) {
        let videoURLs = folder.reminders.compactMap { $0.firebaseVideoURL }
        provider().delete(folder)
        Task {
            for url in videoURLs { await deleteVideo(url) }
        }
    }

    func deleteVideo(_ url: String) async {
        FirebaseStorageService.shared.deleteVideo(firebaseURL: url) { _ in }
    }

    func getCount(_ folder: Folder? = nil, _ unlockedReminders: [Reminder]) -> Int {
        if let folder = folder {
            let id = folder.persistentModelID
            return unlockedReminders.filter { $0.folder?.persistentModelID == id }.count
        } else {
            return unlockedReminders.count
        }
    }




}



