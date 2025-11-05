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

struct Attitude: AttitudeProtocol, Equatable {
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

    init(attitude: some AttitudeProtocol) {
        self.roll = attitude.roll
        self.pitch = attitude.pitch
        self.yaw = attitude.yaw
        self.rotationMatrix = attitude.rotationMatrix
        self.quaternion = attitude.quaternion
    }
}

extension Attitude {
    static let stub = Attitude(
        roll: 0,
        pitch: 0,
        yaw: 0,
        rotationMatrix: CMRotationMatrix(
            m11: 0,
            m12: 0,
            m13: 0,
            m21: 0,
            m22: 0,
            m23: 0,
            m31: 0,
            m32: 0,
            m33: 0
        ),
        quaternion: CMQuaternion(x: 0, y: 0, z: 0, w: 0)
    )
}

extension CMAttitude: AttitudeProtocol {
}

extension CMRotationMatrix: @retroactive Equatable {
    public static func == (lhs: CMRotationMatrix, rhs: CMRotationMatrix) -> Bool {
        lhs.m11 == rhs.m11 &&
        lhs.m12 == rhs.m12 &&
        lhs.m13 == rhs.m13 &&
        lhs.m21 == rhs.m21 &&
        lhs.m22 == rhs.m22 &&
        lhs.m23 == rhs.m23 &&
        lhs.m31 == rhs.m31 &&
        lhs.m32 == rhs.m32 &&
        lhs.m33 == rhs.m33
    }
}

extension CMQuaternion: @retroactive Equatable {
    public static func == (lhs: CMQuaternion, rhs: CMQuaternion) -> Bool {
        lhs.x == rhs.x &&
        lhs.y == rhs.y &&
        lhs.z == rhs.z &&
        lhs.w == rhs.w
    }
}
