//
//  Attitude.swift
//  Nemulert
//
//  Created by Kanta Oikawa on 2025/11/04.
//

import CoreMotion

protocol AttitudeProtocol {
    var roll: Double { get }
    var pitch: Double { get }
    var yaw: Double { get }
    var rotationMatrix: CMRotationMatrix { get }
    var quaternion: CMQuaternion { get }
}

struct Attitude: AttitudeProtocol {
    let roll: Double
    let pitch: Double
    let yaw: Double
    let rotationMatrix: CMRotationMatrix
    let quaternion: CMQuaternion

    init(
        roll: Double,
        pitch: Double,
        yaw: Double,
        rotationMatrix: CMRotationMatrix,
        quaternion: CMQuaternion
    ) {
        self.roll = roll
        self.pitch = pitch
        self.yaw = yaw
        self.rotationMatrix = rotationMatrix
        self.quaternion = quaternion
    }

    init(attitude: CMAttitude) {
        self.roll = attitude.roll
        self.pitch = attitude.pitch
        self.yaw = attitude.yaw
        self.rotationMatrix = attitude.rotationMatrix
        self.quaternion = attitude.quaternion
    }
}

extension CMAttitude: AttitudeProtocol {
}
