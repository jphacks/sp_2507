//
//  OpenAppIntent.swift
//  Nemulert
//
//  Created by Kanta Oikawa on 2025/10/19.
//

import AppIntents

struct OpenAppIntent: AppIntent {
    static let title: LocalizedStringResource = "Open App"
    static let openAppWhenRun: Bool = true
//    static let isDiscoverable: Bool = false

    @MainActor
    func perform() async throws -> some IntentResult {
        return .result()
    }
}
