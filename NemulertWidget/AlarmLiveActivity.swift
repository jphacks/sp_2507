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
    typealias Attributes = AlarmAttributes<DozingData>

    var body: some WidgetConfiguration {
        ActivityConfiguration(
            for: Attributes.self
        ) { context in
            lockScreen(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    dynamicIslandExpandedLeading(context: context)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    dynamicIslandExpandedTrailing(context: context)
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
                        .frame(maxWidth: 44)
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

    private func lockScreen(context: ActivityViewContext<Attributes>) -> some View {
        HStack {
            switch context.state.mode {
            case .countdown(let countdown):
                timerView(fireDate: countdown.fireDate)

            case .alert:
                Text("Wake Up!")
                    .font(.largeTitle)
                    .bold()
                    .foregroundStyle(.orange)

            default:
                EmptyView()
            }

            Spacer()

            cancelAlarmButton(alarmID: context.state.alarmID.uuidString)
        }
        .padding()
    }

    @ViewBuilder
    private func dynamicIslandExpandedLeading(context: ActivityViewContext<Attributes>) -> some View {
        switch context.state.mode {
        case .countdown(let countdown):
            timerView(fireDate: countdown.fireDate)
                .frame(maxHeight: .infinity, alignment: .center)

        default:
            EmptyView()
        }
    }

    private func dynamicIslandExpandedTrailing(context: ActivityViewContext<Attributes>) -> some View {
        cancelAlarmButton(alarmID: context.state.alarmID.uuidString)
            .frame(maxHeight: .infinity, alignment: .center)
    }

    private func timerView(fireDate: Date) -> some View {
        Text(fireDate, style: .timer)
            .monospacedDigit()
            .font(.largeTitle)
            .foregroundStyle(.orange)
    }

    private func cancelAlarmButton(alarmID: String) -> some View {
        Button(intent: CancelAlarmIntent(alarmID: alarmID)) {
            Image(systemName: "figure.run")
                .font(.title)
        }
        .buttonBorderShape(.circle)
        .tint(.orange)
    }
}
