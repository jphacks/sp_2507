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

    /// 画面が表示された時
    ///
    /// アラームと通知の権限をリクエストし、タスクを起動する。
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

        do {
            try await detectingService.restartTasks()
        } catch {
            Logger.error(error)
            domainError = DomainError(error)
        }

        connectionTask = Task {
            for await isConnected in detectingService.connectionStream {
                self.isConnected = isConnected
            }
        }
    }
    
    /// シーンが切り替わった時
    ///
    /// 設定されている全てのアラームを解除し、タスクを再起動する。
    func onSceneChanged() async {
        do {
            try await detectingService.cancelAllAlarms()
            try await detectingService.restartTasks()
        } catch {
            Logger.error(error)
            domainError = DomainError(error)
        }
    }
}
