//
//  DetectingModel.swift
//  Nemulert
//
//  Created by 藤間里緒香 on 2025/10/18.
//

import CoreML
import CoreMotion
import Foundation
import HeadphoneMotion
import Observation

@Observable
final class DetectingModel {
    var motion: CMDeviceMotion?
    var startingPose: CMAttitude?

    func onAppear() async {
        let queue = OperationQueue()
        queue.name = "co.furari.Nemulert.headphone_motion_update"
        queue.maxConcurrentOperationCount = 1
        queue.qualityOfService = .background
        do {
            for try await motion in try HeadphoneMotionUpdate.updates(queue: queue) {
                if let startingPose {
                    motion.attitude.multiply(byInverseOf: startingPose)
                } else {
                    startingPose = motion.attitude
                }
                self.motion = motion
                print(motion.attitude.debugDescription)
            }
        } catch {
            print(error)
        }
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
}
