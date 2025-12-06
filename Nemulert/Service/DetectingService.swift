//
//  DetectingService.swift
//  Nemulert
//
//  Created by Kanta Oikawa on 2025/12/06.
//

import Dependencies
import Foundation

final actor DetectingService {
    private(set) var isConnected: Bool = false
    private(set) var motion: DeviceMotion? = nil {
        willSet {
            guard let newValue else { return }
            motions.append(newValue)
        }
    }
    private(set) var motions: [DeviceMotion] = []
    private(set) var dozing: Dozing = .idle {
        willSet {
            if dozing == .dozing {
                dozingCount += 1
            }
        }
    }
    private(set) var dozingCount: Int = 0

    let windowSize: Int = 130
    private let queueName: String = "com.kantacky.Nemulert.headphone_motion_update"

    private var updateConnectionTask: Task<Void, Error>? {
        didSet {
            oldValue?.cancel()
        }
    }
    private var updateMotionTask: Task<Void, Error>? {
        didSet {
            oldValue?.cancel()
        }
    }

    @Dependency(\.uuid) private var uuid
    @Dependency(\.alarmRepository) private var alarmRepository
    @Dependency(\.dozingDetectionRepository) private var dozingDetectionRepository
    @Dependency(\.motionRepository) private var motionRepository
    @Dependency(\.notificationRepository) private var notificationRepository

    func requestAuthorizations() async {
        do {
            let authorization = try await alarmRepository.requestAuthorization()
            await Logger.info("Alarm authorization status: \(authorization)")
        } catch {
            await Logger.error(error)
        }

        do {
            let isAuthorized = try await notificationRepository.requestAuthorization()
            await Logger.info("Notification authorization granted: \(isAuthorized)")
        } catch {
            await Logger.error(error)
        }
    }

    func cancelAllAlarms() async {
        do {
            try await alarmRepository.cancelAllAlarms()
        } catch {
            await Logger.error(error)
        }
    }

    func restartTasks() {
        dozing = .idle
        dozingCount = 0
        restartConnectionUpdateTask()
        restartMotionUpdateTask()
    }

    private func restartConnectionUpdateTask() {
        updateConnectionTask = Task {
            do {
                for await isConnected in try motionRepository.connectionUpdates() {
                    await Logger.info("Headphone is \(isConnected ? "connected" : "disconnected")")
                    self.isConnected = isConnected
                    if isConnected {
                        restartMotionUpdateTask()
                    }
                }
            } catch {
                await Logger.error(error)
                throw error
            }
        }
    }

    private func restartMotionUpdateTask() {
        updateMotionTask = Task {
            do {
                for try await motion in try await motionRepository.motionUpdates(queueName: queueName) {
                    try await handleMotion(motion)
                }
            } catch {
                await Logger.error(error)
                throw error
            }
        }
    }

    private func handleMotion(_ motion: DeviceMotion) async throws {
        guard try alarmRepository.getAlarms().isEmpty else {
            return
        }
        self.motion = motion
        guard motions.count >= windowSize else {
            return
        }
        let motions = Array(motions.prefix(windowSize))
        self.motions.removeAll()
        let result = try await dozingDetectionRepository.predict(motions: motions)
        try await handlePredictionResult(result)
    }

    private func handlePredictionResult(_ result: DozingResult) async throws {
        if await result.dozing.isDozing && result.confidence > 0.99 {
            dozing = .dozing
            if self.dozingCount >= 2 {
                _ = try await alarmRepository.scheduleAlarm(id: uuid())
                _ = try await notificationRepository.requestNotification(
                    title: String(localized: "Are you dozing off?"),
                    body: String(localized: "Tap to continue working!"),
                    categoryIdentifier: "dozing"
                )
                dozingCount = 0
            }
        } else {
            dozing = .idle
        }
        await Logger.info("Dozing prediction: \(dozing.rawValue)")
    }
}
