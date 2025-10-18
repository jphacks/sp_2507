//
//  DetectingScreen.swift
//  Nemulert
//
//  Created by 細田彩香 on 2025/10/18.
//

import SwiftUI

struct DetectingScreen: View {
    @State private var model = DetectingModel()

    var body: some View {
        VStack {
            LottieView(name: "Nemulert")

            Text(model.dozing.rawValue)
        }
        .task {
            await model.onAppear()
        }
    }
}

#Preview {
    DetectingScreen()
}
