//
//  BetterSelfWidgetLiveActivity.swift
//  BetterSelfWidget
//
//  Created by Adam Damou on 22/09/2025.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct BetterSelfWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct BetterSelfWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: BetterSelfWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension BetterSelfWidgetAttributes {
    fileprivate static var preview: BetterSelfWidgetAttributes {
        BetterSelfWidgetAttributes(name: "World")
    }
}

extension BetterSelfWidgetAttributes.ContentState {
    fileprivate static var smiley: BetterSelfWidgetAttributes.ContentState {
        BetterSelfWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: BetterSelfWidgetAttributes.ContentState {
         BetterSelfWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: BetterSelfWidgetAttributes.preview) {
   BetterSelfWidgetLiveActivity()
} contentStates: {
    BetterSelfWidgetAttributes.ContentState.smiley
    BetterSelfWidgetAttributes.ContentState.starEyes
}
