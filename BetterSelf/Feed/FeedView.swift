//
//  FeedView.swift
//  BetterSelf
//
//  Created by Adam Damou on 20/11/2025.
//

import SwiftUI

struct FeedView: View {
    let reminders: [Reminder]           // pass your 5 chosen items
    @State private var currentIndex = 0

    var body: some View {
        ScrollViewReader { scroller in
            ScrollView(.vertical) {
                LazyVStack(spacing: 0) {
                    ForEach(Array(reminders.prefix(5).enumerated()), id: \.offset) { index, reminder in
                        ReminderView(reminder: reminder, isInFeed: true)
                            .containerRelativeFrame([.horizontal, .vertical])
                            .id(index)
                            .onAppear {
                                currentIndex = index
                                // start video for this index
                            }
                            .onDisappear {
                                // pause/stop video for this index
                            }
                    }
                }
            }
            .scrollIndicators(.never)
            .scrollTargetLayout()                    // enable snap-to-item
            .scrollTargetBehavior(.paging)           // page one full view at a time
            .ignoresSafeArea(.all)
            // Optional programmatic jump:
            // .onChange(of: currentIndex) { _, i in scroller.scrollTo(i, anchor: .center) }
        }
        // Track index for analytics, preload, etc.
        // .onChange(of: currentIndex) { _, i in ... }
    }
    init(reminders: [Reminder]) {
        self.reminders = reminders
        self.currentIndex = 0
    }
}

//#Preview {
//    FeedView()
//}
