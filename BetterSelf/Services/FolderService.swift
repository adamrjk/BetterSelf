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
    let ctx: ModelContext


    init(ctx: ModelContext) {
        self.ctx = ctx
    }

    func deleteEmptyFolder(_ folder: Folder) {
        guard folder.isChecked == false else { return }

        #warning("Handle Identical folder name")
        if folder.name.isEmpty{
            ctx.delete(folder)
        }
        else {
            folder.isChecked = true
            AnalyticsService.log(AnalyticsService.EventName.folderCreated, params: [
                "name": folder.name
            ])
        }
    }




}



