//
//  AlarmService.swift
//  Nemulert
//
//  Created by Kanta Oikawa on 2025/10/29.
//

import AlarmKit
import Dependencies
import DependenciesMacros
import SwiftUI

@DependencyClient
struct AlarmService {
    var requestAuthorization: @Sendable () async throws -> AlarmManager.AuthorizationState
    var requestAlarm: @Sendable () async throws -> Alarm
    var cancelAllAlarms: @Sendable () async throws -> Void
}

extension AlarmService: DependencyKey {
    static let liveValue = AlarmService(
        requestAuthorization: {
            try await AlarmManager.shared.requestAuthorization()
        },
        requestAlarm: {
            let stopButton = AlarmButton(
                text: "Back to Work",
                textColor: .white,
                systemImageName: "figure.run"
            )
            let alert = AlarmPresentation.Alert(
                title: "Wake Up!",
                stopButton: stopButton
            )
            let countDown = AlarmPresentation.Countdown(
                title: "Counting Down..."
            )
            let presentation = AlarmPresentation(
                alert: alert,
                countdown: countDown
            )
            let attributes = AlarmAttributes<DozingData>(
                presentation: presentation,
                tintColor: Color.orange
            )
            let countdownDuration = Alarm.CountdownDuration(
                preAlert: 60,
                postAlert: 60
            )
            let configuration = AlarmManager.AlarmConfiguration(
                countdownDuration: countdownDuration,
                attributes: attributes
            )
            try await cancelAllAlarms()
            return try await AlarmManager.shared.schedule(
                id: .init(),
                configuration: configuration
            )
        },
        cancelAllAlarms: {
            try await cancelAllAlarms()
        }
    )

    private static func cancelAllAlarms() throws {
        for alarm in try AlarmManager.shared.alarms {
            try AlarmManager.shared.cancel(id: alarm.id)
        }
    }
}

extension AlarmService: TestDependencyKey {
    static let testValue = AlarmService()

    static let previewValue = AlarmService()
}
