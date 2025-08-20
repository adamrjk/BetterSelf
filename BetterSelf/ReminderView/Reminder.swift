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


    init(title: String, type: ReminderType = .InstantInsight,  text: String, photo: Data? = nil, firebaseVideoURL: String? = nil, link: String) {
        self.title = title
        self.type = type
        self.text = text
        self.photo = photo
        self.firebaseVideoURL = firebaseVideoURL
        self.link = link

        self.date = .now
    }

    static let example =  Reminder(title: "The One Thing", text: "You can only pursue one goal at a time", firebaseVideoURL: "https://firebasestorage.googleapis.com:443/v0/b/betterself-29f7e.firebasestorage.app/o/videos%2FAABD7649-771B-46E2-8218-6438F558283D.mov?alt=media&token=eaf00810-84cb-46e8-aada-6045ba3eab02", link: "https://")


}

enum ReminderType: String, Codable, CaseIterable {
    case InstantInsight = "InstantInsight"
    case EchoSnap = "EchoSnap"
    case TimeLessLetter = "TimeLessLetter"
}


