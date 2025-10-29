//
//  DetectingScreen.swift
//  Nemulert
//
//  Created by 細田彩香 on 2025/10/18.
//

import SwiftUI

struct DetectingScreen: View {
    @Environment(\.scenePhase) private var scenePhase
    @State private var model = DetectingModel()

    var body: some View {
        LottieView(name: "Nemulert")
            .padding()
            .onAppear {
                model.onAppear()
            }
            .onChange(of: scenePhase) { oldPhase, newPhase in
                switch (oldPhase, newPhase) {
                case (.inactive, .active), (.background, .active):
                    model.onSceneChanged()

                default:
                    break
                }

            }
    }
}

#Preview {
    DetectingScreen()
}
