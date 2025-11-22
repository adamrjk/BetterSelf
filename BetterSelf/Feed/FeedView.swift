//
//  FeedView.swift
//  BetterSelf
//
//  Created by Adam Damou on 20/11/2025.
//

import SwiftData
import SwiftUI

struct FeedView: View {

    @Query(filter: #Predicate<Reminder> { $0.isChecked == true },
           sort: \Reminder.date) var all: [Reminder]
    var unlocked: [Reminder] {
        all.filter{ !$0.isLocked}
    }
    @State private var currentIndex: Int = 0

    let manager = FeedManager.shared


    var reminders: [Reminder]{
        manager.dailyInsights(reminders: unlocked)
    }




    var body: some View {
        ScrollViewReader { scroller in
            ScrollView(.vertical) {
                LazyVStack(spacing: 0) {
                    ForEach(Array(reminders.enumerated()), id: \.offset) { index, reminder in
                        ReminderContent(reminder: reminder, isInFeed: true, currentIndex: $currentIndex, index: index)
                            .containerRelativeFrame(.vertical)
                            .id(index)
                            .ignoresSafeArea(.all)
                    }
                }
                .scrollTargetLayout()                    // enable snap-to-item sizing on items
            }
            .scrollIndicators(.never)
            .scrollTargetBehavior(.paging)           // page one full view at a time
            .scrollPosition(
                id: Binding<Int?>(
                    get: { currentIndex },
                    set: { newValue in
                        if let value = newValue {
                            currentIndex = value
                        }
                    }
                )
            )
            .ignoresSafeArea(.all)
            // Optional programmatic jump:
            // .onChange(of: currentIndex) { _, i in scroller.scrollTo(i, anchor: .center) }
        }
        .onChange(of: currentIndex) { _, i in
            print("Current index is \(i)")
         }
    }
    init() {
        self.currentIndex = 0
    }


}

//#Preview {
//    FeedView()
//}
