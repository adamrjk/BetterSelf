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
    var text: String
    var photo: Data?
    var videoURL: URL?
    var firebaseVideoURL: String? // Store Firebase Storage URL
    var link: String
    var date: Date

    init(title: String, text: String, photo: Data? = nil, videoURL: URL? = nil, firebaseVideoURL: String? = nil, link: String) {
        self.title = title
        self.text = text
        self.photo = photo
        self.videoURL = videoURL
        self.firebaseVideoURL = firebaseVideoURL
        self.link = link

        self.date = .now
    }

    static let example =  Reminder(title: "The One Thing", text: "You can only pursue one goal at a time", link: "https://")

}

