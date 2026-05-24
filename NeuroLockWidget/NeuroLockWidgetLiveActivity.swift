//
//  NeuroLockWidgetLiveActivity.swift
//  NeuroLockWidget
//
//  Created by Rahul Chauhan on 4/15/26.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct NeuroLockWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct NeuroLockWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: NeuroLockWidgetAttributes.self) { context in
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

extension NeuroLockWidgetAttributes {
    fileprivate static var preview: NeuroLockWidgetAttributes {
        NeuroLockWidgetAttributes(name: "World")
    }
}

extension NeuroLockWidgetAttributes.ContentState {
    fileprivate static var smiley: NeuroLockWidgetAttributes.ContentState {
        NeuroLockWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: NeuroLockWidgetAttributes.ContentState {
         NeuroLockWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: NeuroLockWidgetAttributes.preview) {
   NeuroLockWidgetLiveActivity()
} contentStates: {
    NeuroLockWidgetAttributes.ContentState.smiley
    NeuroLockWidgetAttributes.ContentState.starEyes
}
