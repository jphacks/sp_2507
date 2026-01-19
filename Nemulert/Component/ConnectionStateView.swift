//
//  ConnectionStateView.swift
//  Nemulert
//
//  Created by 細田彩香 on 2026/01/19.
//

import SwiftUI

struct ConnectionStateView: View {
    let isConnected: Bool

    var body: some View {
        Image(systemName: "airpods.pro")
            .foregroundColor(isConnected ? .primary : .red)
    }
}

#Preview {
    VStack {
        ConnectionStateView(isConnected: true)
        ConnectionStateView(isConnected: false)
    }
}
