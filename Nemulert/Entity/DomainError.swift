//
//  DomainError.swift
//  Nemulert
//
//  Created by Kanta Oikawa on 2025/12/10.
//

import Foundation

enum DomainError: LocalizedError {
    case alarmNotAuthorized
    case motionNotAuthorized
    case notificationNotAuthorized
    case failedToCancelAlarm
    case unknown(Error?)

    init(_ error: Error) {
        if let error = error as? DomainError {
            self = error
        } else {
            self = .unknown(error)
        }
    }

    var errorDescription: String? {
        switch self {
        case .alarmNotAuthorized:
            String(localized: "Alarm access is not authorized.")
        case .motionNotAuthorized:
            String(localized: "Motion access is not authorized.")
        case .notificationNotAuthorized:
            String(localized: "Notification access is not authorized.")
        case .failedToCancelAlarm:
            String(localized: "Failed to cancel the alarm.")
        case .unknown(let error):
            error?.localizedDescription
        }
    }

    var title: String {
        switch self {
        case .alarmNotAuthorized:
            String(localized: "Alarm Access Denied")
        case .motionNotAuthorized:
            String(localized: "Motion Access Denied")
        case .notificationNotAuthorized:
            String(localized: "Notification Access Denied")
        case .failedToCancelAlarm:
            String(localized: "Cancel Alarm Failed")
        case .unknown:
            String(localized: "Unknown Error")
        }
    }

    var description: String {
        switch self {
        case .alarmNotAuthorized:
            String(localized: "Please enable alarm access in Settings to use this feature.")
        case .motionNotAuthorized:
            String(localized: "Please enable motion access in Settings to use this feature.")
        case .notificationNotAuthorized:
            String(localized: "Please enable notification access in Settings to use this feature.")
        case .failedToCancelAlarm:
            String(localized: "An error occurred while trying to cancel the alarm. Please try again.")
        case .unknown:
            String(localized: "An unknown error has occurred. Please try again later.")
        }
    }
}
