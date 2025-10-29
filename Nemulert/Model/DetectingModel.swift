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
    nonisolated(unsafe) private var motionUpdateTask: Task<Void, Never>?
    @ObservationIgnored
    private let windowSize: Int = 150

    @ObservationIgnored
    @Dependency(AlarmService.self) private var alarmService
    @ObservationIgnored
    @Dependency(DozingDetectionService.self) private var dozingDetectionService
    @ObservationIgnored
    @Dependency(NotificationService.self) private var notificationService

    func onAppear() async {
        await withTaskGroup { group in
            group.addTask {
                do {
                    _ = try await AlarmManager.shared.requestAuthorization()
                } catch {
                    print(error)
                }

                do {
                    _ = try await self.notificationService.requestAuthorization()
                } catch {
                    print(error)
                }

                await self.restartMotionUpdateTask()
            }

            group.addTask {
                for await isConnected in HeadphoneMotionManager().connectionUpdates() {
                    print("Headphone connection status changed: \(isConnected ? "Connected" : "Disconnected")")
                    Task { @MainActor in
                        self.isConnected = isConnected
                    }

                    if isConnected {
                        await self.restartMotionUpdateTask()
                    }
                }
            }

            await group.waitForAll()
        }
    }

    func onSceneChanged() {
        Task {
            await restartMotionUpdateTask()
            try await alarmService.cancelAllAlarms()
        }
    }

    private func restartMotionUpdateTask() async {
        self.motionUpdateTask?.cancel()
        await Task { @MainActor in
            self.dozing = .idle
            self.dozingCount = 0
            self.motionUpdateTask = self.getMotionUpdateTask()
        }.value
        await self.motionUpdateTask?.value
    }

    private func getMotionUpdateTask() -> Task<Void, Never>? {
        Task.detached(priority: .background) { [weak self] in
            let queue = OperationQueue()
            queue.name = "com.kantacky.Nemulert.headphone_motion_update"
            queue.maxConcurrentOperationCount = 1
            queue.qualityOfService = .background
            do {
                for try await motion in try HeadphoneMotionUpdate.updates(queue: queue) {
                    try await self?.handleMotion(motion)
                }
            } catch {
                print(error)
            }
        }
    }

    private func handleMotion(_ motion: CMDeviceMotion) async throws {
        if let startingPose = self.startingPose {
            motion.attitude.multiply(byInverseOf: startingPose)
        } else {
            self.startingPose = motion.attitude
        }
        self.motion = motion
        self.motions.append(motion)
        if self.motions.count >= windowSize {
            if try AlarmManager.shared.alarms.isEmpty {
                do {
                    let motions = self.motions.prefix(windowSize)
                    self.dozing = try await self.dozingDetectionService.predict(motions: Array(motions))
                    if self.dozing.isDozing {
                        self.dozingCount += 1
                    }
                    if self.dozingCount >= 2 {
                        _ = try await self.alarmService.requestAlarm()
                        _ = try await self.notificationService.requestNotification()
                        self.dozingCount = 0
                    }
                } catch {
                    print(error)
                }
            }
            self.motions.removeAll()
        }
    }
}

extension CMDeviceMotion: @retroactive @unchecked Sendable {
}
