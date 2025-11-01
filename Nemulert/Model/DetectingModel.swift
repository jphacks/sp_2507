//
//  DetectingModel.swift
//  Nemulert
//
//  Created by 藤間里緒香 on 2025/10/18.
//

import CoreMotion
import Dependencies
import Observation
import SwiftUI

@Observable
final class DetectingModel {
    @ObservationIgnored
    private(set) var isConnected: Bool = false
    @ObservationIgnored
    private(set) var motion: CMDeviceMotion?
    @ObservationIgnored
    private(set) var startingPose: CMAttitude?
    @ObservationIgnored
    private(set) var motions: [CMDeviceMotion] = []
    @ObservationIgnored
    private(set) var dozing: Dozing = .idle
    @ObservationIgnored
    private(set) var dozingCount: Int = 0

    @ObservationIgnored
    private let windowSize: Int = 150
    @ObservationIgnored
    private let queueName: String = "com.kantacky.Nemulert.headphone_motion_update"

    @ObservationIgnored
    private var updateConnectionTask: Task<Void, Error>? {
        didSet {
            oldValue?.cancel()
            dozing = .idle
            dozingCount = 0
            Task {
                do {
                    try await updateConnectionTask?.value
                } catch {
                    Logger.error(error)
                }
            }
        }
    }
    @ObservationIgnored
    private var updateMotionTask: Task<Void, Error>? {
        didSet {
            oldValue?.cancel()
            Task {
                do {
                    try await updateMotionTask?.value
                } catch {
                    Logger.error(error)
                }
            }
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
        updateConnectionTask = Task.detached(priority: .background) { [weak self] in
            if let handler = self?.handleConnection {
                try await self?.motionService.updateConnection(handler)
            }
        }
    }

    private func restartMotionUpdateTask() {
        updateMotionTask = Task.detached(priority: .background) { [weak self] in
            if let name = self?.queueName,
               let handler = self?.handleMotion {
                try await self?.motionService.updateMotion(
                    name: name,
                    handler: handler
                )
            }
        }
    }

    private func handleConnection(_ isConnected: Bool) throws {
        self.isConnected = isConnected

        if isConnected {
            restartMotionUpdateTask()
        }
    }

    private func handleMotion(_ motion: CMDeviceMotion) async throws {
        if let startingPose {
            motion.attitude.multiply(byInverseOf: startingPose)
        } else {
            startingPose = motion.attitude
        }
        self.motion = motion
        motions.append(motion)
        if motions.count >= windowSize {
            if try alarmService.getAlarms().isEmpty {
                let motions = Array(motions.prefix(windowSize))
                dozing = try await dozingDetectionService.predict(motions: motions)
                if dozing.isDozing {
                    dozingCount += 1
                }
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
            motions.removeAll()
        }
    }
}

extension CMDeviceMotion: @retroactive @unchecked Sendable {
}
