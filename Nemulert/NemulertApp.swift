//
//  NemulertApp.swift
//  Nemulert
//
//  Created by Kanta Oikawa on 2025/10/18.
//

import SwiftUI

@main
struct NemulertApp: App {
    var body: some Scene {
        WindowGroup {
            DetectingScreen()
                .preferredColorScheme(.dark)
        }
    }
}
