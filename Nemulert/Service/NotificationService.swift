//
//  NotificationService.swift
//  Nemulert
//
//  Created by Kanta Oikawa on 2025/10/29.
//

import Dependencies
import DependenciesMacros
import UserNotifications

@DependencyClient
struct NotificationService {
    var requestAuthorization: @Sendable () async throws -> Bool
    var requestNotification: @Sendable (_ title: String, _ body: String, _ categoryIdentifier: String) async throws -> Void
}

extension NotificationService: DependencyKey {
    static let liveValue = NotificationService(
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

extension NotificationService: TestDependencyKey {
    static let testValue = NotificationService()

    static let previewValue = NotificationService(
        requestAuthorization: {
            true
        },
        requestNotification: { _, _, _ in
        }
    )
}
