//
//  DetectingModel.swift
//  Nemulert
//
//  Created by 藤間里緒香 on 2025/10/18.
//

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
}
