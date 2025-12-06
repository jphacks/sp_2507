//
//  ContentScreen.swift
//  Nemulert
//
//  Created by Kanta Oikawa on 2025/11/08.
//

import SwiftUI

struct ContentScreen: View {
    var body: some View {
        TabView {
            Tab("Nemulert", systemImage: "airpods.pro") {
                DetectingScreen()
            }

            Tab("Settings", systemImage: "gear") {
                SettingScreen()
            }
        }
    }
}

#Preview {
    ContentScreen()
}
