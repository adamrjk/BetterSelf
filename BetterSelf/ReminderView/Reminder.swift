//
//  Reminder.swift
//  BetterSelf
//
//  Created by Adam Damou on 15/08/2025.
//

import Foundation
import FSRS
import SwiftData


@Model
class Reminder {
    var id: UUID
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
    
    var time: Int
    var isShared: Bool
    var isLoading: Bool
    var isFront: Bool

    var shareID: String?

    var card: Card?


    init(title: String, type: ReminderType = .InstantInsight,  text: String, photo: Data? = nil, firebaseVideoURL: String? = nil, link: String, folder: Folder? = nil) {
        self.id = UUID()
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
        self.time = 0
        self.isShared = false
        self.isLoading = false
        self.isFront = false
        self.shareID = generateShortID()
        self.card = Card(due: .now)
    }

    static let example =  Reminder(title: "The One Thing", text: "You can only pursue one goal at a time", firebaseVideoURL: "https://firebasestorage.googleapis.com:443/v0/b/betterself-29f7e.firebasestorage.app/o/videos%2FC29D7FD5-3EEF-417D-BB11-14448E115FFE.mov?alt=media&token=877e7031-36c1-4af0-9941-f85650676519", link: "https://", folder: .example)


    static let goggins = Reminder(title: "I know what I did", type: .InstantInsight, text: "I know what I did\nI have a resume full of motivation\nThere was no one there. It was you\nHaving proof of who you are allows you to never doubt yourself again", link: "https://www.youtube.com/watch?v=nDLb8_wgX50", folder: .mindset)

    static let quote = Reminder(title: "Pursue the Impossible", type: .TimeLessLetter, text: "Nietzsche said:\nI know of no better life purpose than to perish in attempting the great and impossible. The fact that something seems impossible shouldn't be a reason to not pursue it. That's exactly what makes it worth pursuing. where would the courage and greatness be if success was certain and there was no risk?", link: "", folder: .mindset)

    





    var isEmpty: Bool {
        text.isEmpty && photo == nil && firebaseVideoURL == nil && link.isEmpty && !isLoading
    }

    var isLocked: Bool{
        if let folder = folder {
            folder.faceID && folder.isLocked
        }
        else {
            false
        }

    }

    var onlyLink: Bool {
        text.isEmpty && photo == nil && firebaseVideoURL == nil
    }

    var isYoutube: Bool {
//        (link.localizedStandardContains("youtube.com") || link.localizedStandardContains("youtu.be")) && !link.localizedStandardContains("shorts")
        link.localizedStandardContains("youtube.com") || link.localizedStandardContains("youtu.be")
    }

    var isArticle: Bool {
        !isYoutube && !link.localizedStandardContains("instagram.com") && !link.localizedStandardContains("tiktok.com")
    }


    var shareLink: URL {
        if let share = shareID {
            URL(string: "https://bettermyself.app/share/\(share)")!
        }
        else {
            URL(string: "https://bettermyself.app/share/\(id.uuidString)")!
        }
    }



    func generateShortID(length: Int = 6) -> String {
        let chars = Array("abcdefghijklmnopqrstuvwxyz0123456789")
        var result = ""
        for _ in 0..<length {
            result.append(chars.randomElement()!)
        }
        return result
    }

}

struct ReminderSnapShot: Codable, Identifiable{
    var id: UUID
    var title: String
    var text: String
    var photoURL: String?
    var link: String
    var isFront: Bool
    var isYoutube: Bool


}


enum ReminderType: String, Codable, CaseIterable {
    case InstantInsight = "InstantInsight"
    case EchoSnap = "EchoSnap"
    case TimeLessLetter = "TimeLessLetter"
}
enum SimpleReminderType: String, Codable, CaseIterable {
    case InstantInsight = "Video"
    case EchoSnap = "Photo"
    case TimeLessLetter = "Text"
}



struct NavigableReminder: Identifiable, Equatable, Hashable {
    let id = UUID()  // Always unique
    let reminder: Reminder

    static func == (lhs: NavigableReminder, rhs: NavigableReminder) -> Bool {
        lhs.id == rhs.id
    }
}



class SharedReminder: Codable {
    var id: UUID
    var title: String
    var type: String
    var text: String
    var photo: String
    var video: String
    var link: String
    var time: Int
    var isFront: Bool

    init(id: UUID, title: String, type: String, text: String, photo: String?, video: String?, link: String, time: Int, isFront: Bool) {
        self.id = id
        self.title = title
        self.type = type
        self.text = text
        self.photo = photo ?? ""
        self.video = video ?? ""
        self.link = link
        self.time = time
        self.isFront = isFront
    }
}






