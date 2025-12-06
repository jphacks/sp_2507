//
//  NotificationRepository.swift
//  Nemulert
//
//  Created by Kanta Oikawa on 2025/10/29.
//

import Dependencies
import DependenciesMacros
import UserNotifications

@DependencyClient
nonisolated struct NotificationRepository {
    var requestAuthorization: @Sendable () async throws -> Bool
    var requestNotification: @Sendable (_ title: String, _ body: String, _ categoryIdentifier: String) async throws -> Void
}

extension NotificationRepository: DependencyKey {
    static let liveValue = NotificationRepository(
        requestAuthorization: {
            try await UNUserNotificationCenter.current().requestAuthorization(
                options: [.alert, .badge, .sound]
            )
        },
        requestNotification: { title, body, categoryIdentifier in
            let identifier = UUID().uuidString
            let content = UNMutableNotificationContent()
            content.title = title
            content.body = body
            content.categoryIdentifier = categoryIdentifier
            content.sound = .default
            content.interruptionLevel = .timeSensitive
            let trigger = UNTimeIntervalNotificationTrigger(
                timeInterval: 1,
                repeats: false
            )
            let request = UNNotificationRequest(
                identifier: identifier,
                content: content,
                trigger: trigger
            )
            try await UNUserNotificationCenter.current().add(request)
        }
    )
}

nonisolated extension NotificationRepository: TestDependencyKey {
    static let testValue = NotificationRepository(
        requestAuthorization: {
            false
        },
        requestNotification: { _, _, _ in
        }
    )

    static let previewValue = NotificationRepository(
        requestAuthorization: {
            false
        },
        requestNotification: { _, _, _ in
        }
    )
}

extension DependencyValues {
    nonisolated var notificationService: NotificationRepository {
        get { self[NotificationRepository.self] }
        set { self[NotificationRepository.self] = newValue }
    }
}
