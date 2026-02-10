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
    var requestAuthorization: @Sendable () async throws -> Void
    var getAlarms: @Sendable () throws -> [Alarm]
    var scheduleAlarm: @Sendable (_ id: Alarm.ID) async throws -> Void
    var cancelAllAlarms: @Sendable () async throws -> Void
}

nonisolated extension AlarmRepository: DependencyKey {
    static let liveValue = AlarmRepository(
        requestAuthorization: {
            do {
                let status = try await AlarmManager.shared.requestAuthorization()

                switch status {
                case .authorized:
                    return

                default:
                    throw DomainError.alarmNotAuthorized
                }
            } catch {
                throw DomainError.alarmNotAuthorized
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
            try cancelAllAlarms()
            _ = try await AlarmManager.shared.schedule(
                id: id,
                configuration: configuration
            )
        },
        cancelAllAlarms: {
            do {
                try cancelAllAlarms()
            } catch {
                throw DomainError.failedToCancelAlarm
            }
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

nonisolated extension DependencyValues {
    var alarmRepository: AlarmRepository {
        get { self[AlarmRepository.self] }
        set { self[AlarmRepository.self] = newValue }
    }
}
