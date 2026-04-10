//
//  ReminderContent.swift
//  BetterSelf
//
//  Created by Adam Damou on 22/11/2025.
//

import SwiftUI

struct ReminderContent: View {

    @State var reminder: Reminder

    let isInFeed: Bool
    @Binding var currentIndex: Int
    var index: Int

    var body: some View {
        Group {
            if reminder.isYoutube {
                SharedLinkView(link: reminder.link, time: $reminder.time, text: reminder.text, isSheet: false, isInFeed: isInFeed, currentIndex: $currentIndex, index: index)
            }
            else if reminder.onlyLink && reminder.isArticle {
                SharedLinkView(link: reminder.link, time: $reminder.time, text: "", isSheet: false, isInFeed: isInFeed, currentIndex: $currentIndex, index: index)
            }
            else {
                switch reminder.type {
                case .InstantInsight:
                    InstantInsightView(reminder: reminder, isInFeed: isInFeed, currentIndex: $currentIndex, index: index)
                case .EchoSnap:
                    EchoSnapView(reminder: reminder, isInFeed: isInFeed)
                default:
                    TimeLessLetterView(isSheet: false, reminder: reminder, isInFeed: isInFeed)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity) // ensure backgrounds can extend to full page
    }
    init(reminder: Reminder, isInFeed: Bool, currentIndex: Binding<Int> = .constant(0), index: Int = 0) {
        self.reminder = reminder
        self.isInFeed = isInFeed
        _currentIndex = currentIndex
        self.index = index
    }
}


