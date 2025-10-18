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
        LottieView(name: "Nemulert")
            .task {
                await model.onAppear()
            }
    }
}

#Preview {
    DetectingScreen()
}
