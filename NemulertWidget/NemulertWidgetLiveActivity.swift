//
//  NemulertWidgetLiveActivity.swift
//  NemulertWidget
//
//  Created by Kanta Oikawa on 2025/10/18.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct NemulertWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct NemulertWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: NemulertWidgetAttributes.self) { context in
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

extension NemulertWidgetAttributes {
    fileprivate static var preview: NemulertWidgetAttributes {
        NemulertWidgetAttributes(name: "World")
    }
}

extension NemulertWidgetAttributes.ContentState {
    fileprivate static var smiley: NemulertWidgetAttributes.ContentState {
        NemulertWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: NemulertWidgetAttributes.ContentState {
         NemulertWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: NemulertWidgetAttributes.preview) {
   NemulertWidgetLiveActivity()
} contentStates: {
    NemulertWidgetAttributes.ContentState.smiley
    NemulertWidgetAttributes.ContentState.starEyes
}
