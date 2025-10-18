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

struct AlarmActionIntent: LiveActivityIntent {
    static let title: LocalizedStringResource = "Alarm Action"
    static let isDiscoverable = false

    @Parameter
    var id: String

    init(id: Alarm.ID) {
        self.id = id.uuidString
    }

    init() {
    }

    func perform() async throws -> some IntentResult {
        if let alarmID = UUID(uuidString: id) {
            try AlarmManager.shared.cancel(id: alarmID)
        }
        return .result()
    }
}
