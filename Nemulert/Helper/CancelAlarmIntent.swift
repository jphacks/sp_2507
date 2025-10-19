//
//  AlarmActionIntent.swift
//  Nemulert
//
//  Created by Kanta Oikawa on 2025/10/18.
//

import ActivityKit
import AlarmKit
import AppIntents
import WidgetKit

struct CancelAlarmIntent: LiveActivityIntent {
    static let title: LocalizedStringResource = "Cancel the Alarm"
    static let description = IntentDescription("Cancels the specified alarm.")

    @Parameter
    var alarmID: String

    init(alarmID: String) {
        self.alarmID = alarmID
    }

    init() {
        alarmID = ""
    }

    func perform() async throws -> some IntentResult {
        if let alarmID = UUID(uuidString: alarmID) {
            try AlarmManager.shared.stop(id: alarmID)
        }
        return .result()
    }
}
