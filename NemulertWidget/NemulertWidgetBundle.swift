//
//  NemulertWidgetBundle.swift
//  NemulertWidget
//
//  Created by Kanta Oikawa on 2025/10/18.
//

import WidgetKit
import SwiftUI

@main
struct NemulertWidgetBundle: WidgetBundle {
    var body: some Widget {
        AlarmLiveActivity()
        StartNemulertControl()
    }
}
