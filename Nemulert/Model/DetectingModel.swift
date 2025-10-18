//
//  DetectingModel.swift
//  Nemulert
//
//  Created by 藤間里緒香 on 2025/10/18.
//

import AlarmKit
import AsyncAlgorithms
import CoreML
import CoreMotion
import Foundation
import HeadphoneMotion
import Observation
import SwiftUI

@Observable
final class DetectingModel {
    private let alarmID = UUID()
    private let queueName = "co.furari.Nemulert.headphone_motion_update"

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

    func onAppear() async {
        Task {
            try await AlarmManager.shared.requestAuthorization()
        }

        _ = try? await setAlarm()

//        let queue = OperationQueue()
//        queue.name = queueName
//        queue.maxConcurrentOperationCount = 1
//        queue.qualityOfService = .background
//        do {
//            for try await motion in try HeadphoneMotionUpdate.updates(queue: queue) {
//                Task { @MainActor in
//                    if let startingPose = self.startingPose {
//                        motion.attitude.multiply(byInverseOf: startingPose)
//                    } else {
//                        self.startingPose = motion.attitude
//                    }
//                    self.motion = motion
//                    self.motions.append(motion)
//                    if self.motions.count >= 100 {
//                        do {
//                            let motions = self.motions.prefix(100)
//                            self.dozing = try self.predict(motions: Array(motions))
//                            if self.dozing.isDozing {
//                                self.dozingCount += 1
//                            } else {
//                                self.dozingCount = 0
//                            }
//                            if self.dozingCount >= 3 {
//                                _ = try await self.setAlarm()
//                            }
//                        } catch {
//                            print(error)
//                        }
//                        self.motions.removeAll()
//                    }
//                }
//            }
//        } catch {
//            print(error)
//        }
    }

    private func predict(motions: [CMDeviceMotion]) throws -> Dozing {
        let configuration = MLModelConfiguration()
        let model = try DozingDetection(configuration: configuration)
        let input = DozingDetectionInput(
            attitude_pitch: try MLMultiArray(motions.map { $0.attitude.pitch }),
            attitude_roll: try MLMultiArray(motions.map { $0.attitude.roll }),
            attitude_yaw: try MLMultiArray(motions.map { $0.attitude.yaw }),
            rotation_rate_x: try MLMultiArray(motions.map { $0.rotationRate.x }),
            rotation_rate_y: try MLMultiArray(motions.map { $0.rotationRate.y }),
            rotation_rate_z: try MLMultiArray(motions.map { $0.rotationRate.z }),
            stateIn: try MLMultiArray(shape: [400], dataType: .double)
        )
        let output = try model.prediction(input: input)
        print("\(output.label) detected.")
        return Dozing(rawValue: output.label) ?? .idle
    }

    private func setAlarm() async throws -> Alarm {
        let stopButton = AlarmButton(
            text: "Back to Work",
            textColor: .orange,
            systemImageName: "stop.fill"
        )
        let alert = AlarmPresentation.Alert(
            title: "Wake Up!",
            stopButton: stopButton
        )
        let countDown = AlarmPresentation.Countdown(
            title: "Counting Down..."
        )
        let presentation = AlarmPresentation(
            alert: alert,
            countdown: countDown
        )
        let attributes = AlarmAttributes<DozingData>(
            presentation: presentation,
            tintColor: Color.orange
        )
        let countdownDuration = Alarm.CountdownDuration(
            preAlert: 60,
            postAlert: 60
        )
        let configuration = AlarmManager.AlarmConfiguration(
            countdownDuration: countdownDuration,
            attributes: attributes
        )
        return try await AlarmManager.shared.schedule(
            id: alarmID,
            configuration: configuration
        )
    }
}

extension CMDeviceMotion: @retroactive @unchecked Sendable {
}
