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
    @ObservationIgnored
    private(set) var isConnected: Bool = false
    @ObservationIgnored
    private(set) var motion: DeviceMotion?
    @ObservationIgnored
    private(set) var motions: [DeviceMotion] = []
    @ObservationIgnored
    private(set) var dozing: Dozing = .idle
    @ObservationIgnored
    private(set) var dozingCount: Int = 0

    @ObservationIgnored
    let windowSize: Int = 130
    @ObservationIgnored
    private let queueName: String = "com.kantacky.Nemulert.headphone_motion_update"

    @ObservationIgnored
    private var updateConnectionTask: Task<Void, Error>? {
        didSet {
            oldValue?.cancel()
        }
    }
    @ObservationIgnored
    private var updateMotionTask: Task<Void, Error>? {
        didSet {
            oldValue?.cancel()
        }
    }

    @ObservationIgnored
    @Dependency(\.uuid) private var uuid
    @ObservationIgnored
    @Dependency(\.alarmService) private var alarmService
    @ObservationIgnored
    @Dependency(\.dozingDetectionService) private var dozingDetectionService
    @ObservationIgnored
    @Dependency(\.motionService) private var motionService
    @ObservationIgnored
    @Dependency(\.notificationService) private var notificationService

    func onAppear() {
        Task {
            do {
                let authorization = try await alarmService.requestAuthorization()
                Logger.info("Alarm authorization status: \(authorization)")
            } catch {
                Logger.error(error)
            }

            do {
                let isAuthorized = try await notificationService.requestAuthorization()
                Logger.info("Notification authorization granted: \(isAuthorized)")
            } catch {
                Logger.error(error)
            }
        }

        restartConnectionUpdateTask()
        restartMotionUpdateTask()
    }

    func onSceneChanged() async {
        do {
            try await alarmService.cancelAllAlarms()
        } catch {
            Logger.error(error)
        }
        restartConnectionUpdateTask()
        restartMotionUpdateTask()
    }

    private func restartConnectionUpdateTask() {
        dozing = .idle
        dozingCount = 0
        updateConnectionTask = Task {
            do {
                for await isConnected in try motionService.connectionUpdates() {
                    Logger.info("Headphone is \(isConnected ? "connected" : "disconnected")")
                    try handleConnection(isConnected)
                }
            } catch {
                Logger.error(error)
                throw error
            }
        }
    }

    private func restartMotionUpdateTask() {
        updateMotionTask = Task {
            do {
                for try await motion in try await motionService.motionUpdates(queueName: queueName) {
                    try await handleMotion(motion)
                }
            } catch {
                Logger.error(error)
                throw error
            }
        }
    }

    private func handleConnection(_ isConnected: Bool) throws {
        self.isConnected = isConnected

        if isConnected {
            restartMotionUpdateTask()
        }
    }

    private func handleMotion(_ motion: DeviceMotion) async throws {
        self.motion = motion
        if !(try alarmService.getAlarms().isEmpty) {
            return
        }
        motions.append(motion)
        if motions.count < windowSize {
            return
        }
        let motions = Array(motions.prefix(windowSize))
        self.motions.removeAll()
        dozing = try await dozingDetectionService.predict(motions: motions)
        Logger.info("Dozing prediction: \(dozing)")
        if dozing.isDozing {
            try await incrementDozingCount()
        }
    }

    private func incrementDozingCount() async throws {
        dozingCount += 1
        if self.dozingCount >= 2 {
            _ = try await alarmService.scheduleAlarm(id: uuid())
            _ = try await notificationService.requestNotification(
                title: String(localized: "Are you dozing off?"),
                body: String(localized: "Tap to continue working!"),
                categoryIdentifier: "dozing"
            )
            dozingCount = 0
        }
    }
}
