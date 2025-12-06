//
//  DetectingModel.swift
//  Nemulert
//
//  Created by 藤間里緒香 on 2025/10/18.
//

import Dependencies
import Observation
import SwiftUI

@Observable
final class DetectingModel {
    private let detectingService = DetectingService()

    func onAppear() {
        Task {
            await detectingService.requestAuthorizations()
            await detectingService.restartTasks()

        }
    }

    func onSceneChanged() {
        Task {
            await detectingService.cancelAllAlarms()
            await detectingService.restartTasks()
        }
    }
}
