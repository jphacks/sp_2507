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
    var requestNotification: @Sendable () async throws -> Void
}

extension NotificationService: DependencyKey {
    static let liveValue = NotificationService(
        requestAuthorization: {
            try await UNUserNotificationCenter.current().requestAuthorization(
                options: [.alert, .badge, .sound]
            )
        },
        requestNotification: {
            let identifier = UUID().uuidString
            let content = UNMutableNotificationContent()
            content.title = String(localized: "Are you dozing off?")
            content.body = String(localized: "Tap to continue working!")
            content.categoryIdentifier = "dozing"
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

    static let previewValue = NotificationService()
}
