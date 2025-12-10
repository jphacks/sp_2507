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
    private(set) var isAlarmAuthorized: Bool = false
    private(set) var isNotificationAuthorized: Bool = false

    private let detectingService = DetectingService()

    private var connectionTask: Task<Void, Never>? {
        didSet {
            oldValue?.cancel()
        }
    }

    func onAppear() async {
        isAlarmAuthorized = (try? await detectingService.requestAlarmAuthorization()) ?? false
        isNotificationAuthorized = (try? await detectingService.requestNotificationAuthorization()) ?? false

        await detectingService.restartTasks()

        connectionTask = Task {
            for await isConnected in detectingService.connectionStream {
                self.isConnected = isConnected
            }
        }
    }

    func onSceneChanged() async {
        await detectingService.cancelAllAlarms()
        await detectingService.restartTasks()
    }
}
