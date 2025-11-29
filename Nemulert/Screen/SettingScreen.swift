//
//  SettingScreen.swift
//  Nemulert
//
//  Created by Kanta Oikawa on 2025/11/08.
//

import SwiftUI

struct SettingScreen: View {
    var body: some View {
        NavigationStack {
            List {
                LabeledContent {
                    if let version = Bundle.main.object(
                        forInfoDictionaryKey: "CFBundleShortVersionString"
                    ) as? String,
                       let buildNumber = Bundle.main.object(
                        forInfoDictionaryKey: "CFBundleVersion"
                       ) as? String
                    {
                        Text("\(version) (\(buildNumber))")
                    }
                } label: {
                    HStack {
                        Image(systemName: "info.circle")
                        Text("Version")
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingScreen()
}
