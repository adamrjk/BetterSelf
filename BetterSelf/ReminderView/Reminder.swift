//
//  Reminder.swift
//  BetterSelf
//
//  Created by Adam Damou on 15/08/2025.
//

import Foundation
import SwiftData


@Model
class Reminder {

    
    var title: String
    var type: ReminderType
    var text: String
    var photo: Data?
    var firebaseVideoURL: String? // Store Firebase Storage URL
    var link: String
    var date: Date
    var isChecked: Bool

    var folder: Folder?
    var pinned: Bool
    var datePinned: Date


    init(title: String, type: ReminderType = .InstantInsight,  text: String, photo: Data? = nil, firebaseVideoURL: String? = nil, link: String, folder: Folder? = nil) {
        self.title = title
        self.type = type
        self.text = text
        self.photo = photo
        self.firebaseVideoURL = firebaseVideoURL
        self.link = link
        self.isChecked = false
        self.folder = folder
        self.date = .now
        self.pinned = false
        self.datePinned = .distantPast
    }

    static let example =  Reminder(title: "The One Thing", text: "You can only pursue one goal at a time", firebaseVideoURL: "https://firebasestorage.googleapis.com:443/v0/b/betterself-29f7e.firebasestorage.app/o/videos%2FC29D7FD5-3EEF-417D-BB11-14448E115FFE.mov?alt=media&token=877e7031-36c1-4af0-9941-f85650676519", link: "https://", folder: .example)

    var isEmpty: Bool {
        text.isEmpty && photo == nil && firebaseVideoURL == nil && link.isEmpty
    }

    var isLocked: Bool{
        if let folder = folder {
            folder.faceID && folder.isLocked
        }
        else {
            false
        }

    }


}

enum ReminderType: String, Codable, CaseIterable {
    case InstantInsight = "InstantInsight"
    case EchoSnap = "EchoSnap"
    case TimeLessLetter = "TimeLessLetter"
}

