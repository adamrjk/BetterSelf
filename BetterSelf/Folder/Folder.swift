//
//  Folder.swift
//  BetterSelf
//
//  Created by Adam Damou on 05/09/2025.
//

import Foundation
import SwiftData



@Model
class Folder: Equatable {
    @Attribute(.unique) var name: String
    var faceID: Bool
    var date: Date

    var sorting: Sorting

    // Relationship to reminders
    @Relationship(deleteRule: .cascade) var reminders: [Reminder]

    init(name: String, reminders: [Reminder] = []) {
        self.name = name
        self.reminders = reminders
        self.faceID = false
        self.sorting = .date
        self.date = .now
    }


    static func ==(lhs: Folder, rhs: Folder) -> Bool {
        lhs.name == rhs.name

    }

    static let example = Folder(name: "Example", reminders: [.example])

    
}

enum Sorting: String, Codable, CaseIterable {
    case date = "By Date"
    case name = "By Name"


    
}
