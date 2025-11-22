//
//  FeedManager.swift
//  BetterSelf
//
//  Created by Adam Damou on 21/11/2025.
//

import Foundation
import FSRS


class FeedManager {

    private let fsrs = FSRS(
        parameters: FSRSParameters(
            requestRetention: 0.9,
            maximumInterval: 36500,
            w: [0.4, 0.6, 2.4, 5.8, 4.93, 0.94, 0.01, 1.49, 0.14, 0.94, 2.18, 0.05, 0.34, 1.26, 0.29, 2.61, 0.55],
            enableFuzz: true,
            enableShortTerm: false
        )
    )

    static let shared = FeedManager()

    init() {}

    func applyFSRSResult(_ record: RecordLogItem, to reminder: Reminder) {
        let c = record.card
        let log = record.log

        reminder.card = Card(
            due: c.due,
            stability: c.stability,
            difficulty: c.difficulty,
            elapsedDays: log.lastElapsedDays,
            scheduledDays: log.scheduledDays,
            reps: c.reps,
            lapses: c.lapses,
            state: c.state,
            lastReview: c.lastReview
        )
    }

    func reviewInsight(_ reminder: Reminder, rating: Rating) {
        let card = reminder.card ?? Card(due: .now)

        if let record = try? fsrs.next(card: card, now: .now, grade: rating) {
            applyFSRSResult(record, to: reminder)
        }
    }

    func dailyInsights(reminders: [Reminder], _ n : Int = -1) -> [Reminder] {
        let today = Calendar.current.startOfDay(for: .now)

        let insights = reminders
                            .filter { reminder in
                                if let due = reminder.card?.due {
                                    return due <= today
                                } else {
                                    return true
                                }
                            }
                            .sorted { ($0.card?.due ?? .distantPast) < ($1.card?.due ?? .distantPast) }


        return n == -1 ? insights
                        : insights
                            .prefix(n)
                            .map { $0 }
    }
}
