//
//  Attitude.swift
//  Nemulert
//
//  Created by Kanta Oikawa on 2025/11/04.
//

import CoreMotion

struct Attitude {
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
