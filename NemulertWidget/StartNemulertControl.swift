//
//  StartNemulertControl.swift
//  NemulertWidgetExtension
//
//  Created by Kanta Oikawa on 2025/10/19.
//

import AppIntents
import SwiftUI
import WidgetKit

struct StartNemulertControl: ControlWidget {
    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(
            kind: "co.furari.Nemulert.NemulertWidget.StartNemulertControl",
            provider: Provider()
        ) { value in
            ControlWidgetButton(
                "Start Nemulert",
                action: OpenAppIntent()
            ) { _ in
                Image(systemName: "figure.run")
            }
        }
        .displayName("Start Nemulert")
        .description("Start monitoring on Nemulert.")
    }
}

extension StartNemulertControl {
    struct Provider: ControlValueProvider {
        var previewValue: Bool {
            false
        }

        func currentValue() async throws -> Bool {
            return false
        }
    }
}
