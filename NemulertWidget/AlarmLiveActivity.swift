//
//  AlarmLiveActivity.swift
//  Nemulert
//
//  Created by Kanta Oikawa on 2025/10/18.
//

import ActivityKit
import AlarmKit
import AppIntents
import WidgetKit
import SwiftUI

struct AlarmLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(
            for: AlarmAttributes<DozingData>.self
        ) { context in
            let alarmID = context.state.alarmID

            VStack(alignment: .leading) {
                Text(context.attributes.presentation.countdown?.title ?? "")

                HStack {
                    switch context.state.mode {
                    case .countdown(let countdown):
                        Text(countdown.fireDate, style: .timer)
                            .font(.largeTitle)
                            .monospacedDigit()

                    case .alert:
                        Text("Wake Up!")
                            .font(.largeTitle)

                    default:
                        EmptyView()
                    }

                    Button(intent: AlarmActionIntent(id: alarmID)) {
                        Image(systemName: "stop.fill")
                    }
                    .buttonStyle(.glassProminent)
                    .buttonBorderShape(.circle)
                    .font(.largeTitle)
                    .tint(.orange)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Text(context.attributes.presentation.countdown?.title ?? "")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    switch context.state.mode {
                    case .countdown(let countdown):
                        Text(countdown.fireDate, style: .timer)
                            .font(.largeTitle)
                            .monospacedDigit()
                            .foregroundStyle(.orange)
                            .multilineTextAlignment(.trailing)

                    default:
                        EmptyView()
                    }
                }
                DynamicIslandExpandedRegion(.bottom) {
                    let alarmID = context.state.alarmID

                    Button("Back to Work", intent: AlarmActionIntent(id: alarmID))
                        .buttonStyle(.glassProminent)
                        .tint(.orange)
                }
            } compactLeading: {
                Image(systemName: "alarm.fill")
                    .foregroundStyle(.orange)
            } compactTrailing: {
                switch context.state.mode {
                case .countdown(let countdown):
                    Text(countdown.fireDate, style: .timer)
                        .monospacedDigit()
                        .foregroundStyle(.orange)
                        .frame(maxWidth: 48)
                        .multilineTextAlignment(.trailing)

                default:
                    EmptyView()
                }
            } minimal: {
                Image(systemName: "alarm.fill")
                    .foregroundStyle(.orange)
            }
        }
    }
}
