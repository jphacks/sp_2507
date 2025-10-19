//
//  StartNemulertShortcut.swift
//  Nemulert
//
//  Created by Kanta Oikawa on 2025/10/19.
//

import AppIntents

struct StartNemulertShortcut: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: OpenAppIntent(),
            phrases: [
                "\(.applicationName)をスタートして",
            ],
            shortTitle: "Start Nemulert",
            systemImageName: "figure.run")
    }
}
