//
//  AlarmRepository.swift
//  Nemulert
//
//  Created by Kanta Oikawa on 2025/10/29.
//

import AlarmKit
import Dependencies
import DependenciesMacros
import SwiftUI

@DependencyClient
nonisolated struct AlarmRepository {
    var requestAuthorization: @Sendable () async throws -> Bool
    var getAlarms: @Sendable () throws -> [Alarm]
    var scheduleAlarm: @Sendable (_ id: Alarm.ID) async throws -> Void
    var cancelAllAlarms: @Sendable () async throws -> Void
}

extension AlarmRepository: DependencyKey {
    static let liveValue = AlarmRepository(
        requestAuthorization: {
            let status = try await AlarmManager.shared.requestAuthorization()

            switch status {
            case .authorized:
                return true

            default:
                return false
            }
        },
        getAlarms: {
            try AlarmManager.shared.alarms
        },
        scheduleAlarm: { id in
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
            _ = try await AlarmManager.shared.schedule(
                id: id,
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

nonisolated extension AlarmRepository: TestDependencyKey {
    static let testValue = AlarmRepository(
        requestAuthorization: {
            false
        },
        getAlarms: {
            []
        },
        scheduleAlarm: { _ in
        },
        cancelAllAlarms: {
        }
    )

    static let previewValue = AlarmRepository(
        requestAuthorization: {
            false
        },
        getAlarms: {
            []
        },
        scheduleAlarm: { _ in
        },
        cancelAllAlarms: {
        }
    )
}

extension DependencyValues {
    nonisolated var alarmRepository: AlarmRepository {
        get { self[AlarmRepository.self] }
        set { self[AlarmRepository.self] = newValue }
    }
}
