//
//  DetectingModel.swift
//  Nemulert
//
//  Created by 藤間里緒香 on 2025/10/18.
//

import AlarmKit
import CoreML
import CoreMotion
import Dependencies
import Foundation
import HeadphoneMotion
import NotificationCenter
import Observation
import SwiftUI

@Observable
final class DetectingModel {
    private var isConnected: Bool = false
    @ObservationIgnored
    private var motion: CMDeviceMotion?
    @ObservationIgnored
    private var startingPose: CMAttitude?
    @ObservationIgnored
    private var motions: [CMDeviceMotion] = []
    @ObservationIgnored
    private var dozing: Dozing = .idle
    @ObservationIgnored
    private var dozingCount: Int = 0
    @ObservationIgnored
    nonisolated(unsafe) private var motionUpdateTask: Task<Void, Error>?
    @ObservationIgnored
    private let windowSize: Int = 150

    @ObservationIgnored
    @Dependency(\.uuid) private var uuid
    @ObservationIgnored
    @Dependency(AlarmService.self) private var alarmService
    @ObservationIgnored
    @Dependency(DozingDetectionService.self) private var dozingDetectionService
    @ObservationIgnored
    @Dependency(MotionService.self) private var motionService
    @ObservationIgnored
    @Dependency(NotificationService.self) private var notificationService

    func onAppear() async {
        await withTaskGroup { group in
            group.addTask { [weak self] in
                do {
                    _ = try await self?.alarmService.requestAuthorization()
                } catch {
                    print(error)
                }

                do {
                    _ = try await self?.notificationService.requestAuthorization()
                } catch {
                    print(error)
                }

                try? await self?.restartMotionUpdateTask()
            }

            group.addTask { [weak self] in
                for await isConnected in HeadphoneMotionManager().connectionUpdates() {
                    Task { @MainActor [weak self] in
                        self?.isConnected = isConnected
                    }

                    if isConnected {
                        try? await self?.restartMotionUpdateTask()
                    }
                }
            }

            await group.waitForAll()
        }
    }

    func onSceneChanged() {
        Task {
            try await restartMotionUpdateTask()
            try await alarmService.cancelAllAlarms()
        }
    }

    private func restartMotionUpdateTask() async throws {
        motionUpdateTask?.cancel()
        dozing = .idle
        dozingCount = 0
        motionUpdateTask = try motionService.getMotionUpdateTask(
            name: "com.kantacky.Nemulert.headphone_motion_update",
            handler: handleMotion
        )
        try await motionUpdateTask?.value
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
