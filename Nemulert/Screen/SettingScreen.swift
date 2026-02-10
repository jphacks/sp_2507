//
//  SettingScreen.swift
//  Nemulert
//
//  Created by Kanta Oikawa on 2025/11/08.
//

import SwiftUI

struct SettingScreen: View {
    @State private var isDebugScreenPresented = false

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
                .onTapGesture {
#if DEBUG
                    isDebugScreenPresented = true
#endif
                }
            }
            .navigationTitle("Settings")
        }
        .sheet(isPresented: $isDebugScreenPresented) {
            DebugScreen()
        }
    }
}

#Preview {
    SettingScreen()
}
