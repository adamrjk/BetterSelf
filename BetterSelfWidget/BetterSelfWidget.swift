//
//  BetterSelfWidget.swift
//  BetterSelfWidget
//
//  Created by Adam Damou on 22/09/2025.
//

import WidgetKit
import SwiftUI
import Foundation
import UIKit
import Social
import CoreServices



struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> ReminderEntry {
        ReminderEntry(date: Date(), reminders: [])
    }

    func getSnapshot(in context: Context, completion: @escaping (ReminderEntry) -> ()) {
        let entry = ReminderEntry(date: Date(), reminders: loadReminders())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ReminderEntry>) -> ()) {
        let entry = ReminderEntry(date: Date(), reminders: loadReminders())
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }

    private func loadReminders() -> [ReminderSnapShot] {
        guard let data = UserDefaults(suiteName: "group.adam.betterself")?
            .data(forKey: "PinnedReminders"),
              let reminders = try? JSONDecoder().decode([ReminderSnapShot].self, from: data) else {
            return []
        }
        return reminders
    }
}

struct ReminderEntry: TimelineEntry {
    let date: Date
    let reminders: [ReminderSnapShot]
}

struct BetterSelfWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        ZStack {
//            Color.purpleMainGradient
//                .containerBackground(.fill.tertiary, for: .widget)
//                .frame(maxWidth: .infinity, maxHeight: .infinity)
//            Color.purpleOverlayGradient
//                .blendMode(.overlay)
//                .frame(maxWidth: .infinity, maxHeight: .infinity)
            VStack(alignment: .leading, spacing: 5) {

                Text("Pinned")
                    .foregroundStyle(Color.creamyYellowGradient)
                    .bold()
                    .padding(.bottom, 3)


                VStack {
                    Spacer()
                    ForEach(entry.reminders){ reminder in
//                        Button{
//                            
//                        } label:{
                        if let url = URL(string: "betterself://home?reminder=\(reminder.id.uuidString)") {
                            Link(destination: url){
                                HStack {
                                    if let image = loadImage(reminder.photoURL) {
                                        image
                                            .resizable()
                                            .rotation3DEffect(.degrees(reminder.isFront ? 180 : 0), axis: (x: 0, y: 1, z: 0))
                                            .scaledToFill()
                                            .frame(width: 20, height:  20)

                                            .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 6)
                                                    .stroke(Color.white.opacity(0.3), lineWidth: 0.5)
                                            )
                                            .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
                                    }
                                    Text(reminder.title)
                                        .font(.footnote)
                                    
                                    Spacer()
                                }
                                .padding(.vertical, 3)
                                .background(Color.clear)
                            }
                        }

                    }
                 Spacer()
                }
            }
        }
        .padding(0)
        .containerBackground(.fill.tertiary, for: .widget) // must be on the top-level view
    }
    func loadImage(_ url: String?) -> Image? {
        guard let url = URL(string: url ?? "") else { return nil }
        guard let data = try? Data(contentsOf: url),
              let uiImage = UIImage(data: data) else {
            return nil
        }
        return Image(uiImage: uiImage)
    }
}

struct BetterSelfWidget: Widget {
    let kind: String = "BetterSelfWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            BetterSelfWidgetEntryView(entry: entry)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .configurationDisplayName("BetterSelf Reminders")
        .description("Shows your latest reminders.")
        .supportedFamilies([.systemSmall])


    }

}

//extension ConfigurationAppIntent {
//    fileprivate static var smiley: ConfigurationAppIntent {
//        let intent = ConfigurationAppIntent()
//        intent.favoriteEmoji = "😀"
//        return intent
//    }
//
//    fileprivate static var starEyes: ConfigurationAppIntent {
//        let intent = ConfigurationAppIntent()
//        intent.favoriteEmoji = "🤩"
//        return intent
//    }
//}

//#Preview(as: .systemSmall) {
//    BetterSelfWidget()
//} timeline: {
//    SimpleEntry(date: .now, configuration: .smiley)
//    SimpleEntry(date: .now, configuration: .starEyes)
//}
