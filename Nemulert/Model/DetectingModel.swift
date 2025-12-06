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
    private(set) var isConnected: Bool = false

    private let detectingService = DetectingService()

    func onAppear() {
        Task {
            await detectingService.requestAuthorizations()
            await detectingService.restartTasks()

            for await isConnected in detectingService.connectionStream {
                self.isConnected = isConnected
            }
        }
    }

    func onSceneChanged() {
        Task {
            await detectingService.cancelAllAlarms()
            await detectingService.restartTasks()
        }
    }
}
