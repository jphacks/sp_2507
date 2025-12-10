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
    var isAlertPresented: Bool {
        get {
            domainError != nil
        }
        set {
            if !newValue {
                domainError = nil
            }
        }
    }
    private(set) var domainError: DomainError?

    private let detectingService = DetectingService()

    private var connectionTask: Task<Void, Never>? {
        didSet {
            oldValue?.cancel()
        }
    }

    func onAppear() async {
        do {
            try await detectingService.requestAlarmAuthorization()
            isAlarmAuthorized = true
        } catch {
            Logger.error(error)
            isAlarmAuthorized = false
        }
        do {
            try await detectingService.requestNotificationAuthorization()
            isNotificationAuthorized = true
        } catch {
            Logger.error(error)
            isNotificationAuthorized = false
        }

        await detectingService.restartTasks()

        connectionTask = Task {
            for await isConnected in detectingService.connectionStream {
                self.isConnected = isConnected
            }
        }
    }

    func onSceneChanged() async {
        do {
            try await detectingService.cancelAllAlarms()
        } catch {
            Logger.error(error)
            domainError = DomainError(error)
        }
        await detectingService.restartTasks()
    }
}
