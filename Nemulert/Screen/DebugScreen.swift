//
//  DebugScreen.swift
//  Nemulert
//
//  Created by Kanta Oikawa on 2025/11/08.
//

import SwiftUI

struct DebugScreen: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
            }
            .navigationTitle("Debug")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(role: .close) {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    DebugScreen()
}
