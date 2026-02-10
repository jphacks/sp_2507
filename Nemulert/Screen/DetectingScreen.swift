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
            .task {
                await model.onAppear()
            }
            .onChange(of: scenePhase) { oldPhase, newPhase in
                switch (oldPhase, newPhase) {
                case (.inactive, .active), (.background, .active):
                    Task {
                        await model.onSceneChanged()
                    }

                default:
                    break
                }
            }
            .alert(
                model.domainError?.title ?? "",
                isPresented: $model.isAlertPresented,
                presenting: model.domainError?.description,
                actions: { _ in },
                message: Text.init
            )
    }
}

#Preview {
    DetectingScreen()
}
