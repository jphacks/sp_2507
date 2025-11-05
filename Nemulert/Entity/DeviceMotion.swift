//
//  DeviceMotion.swift
//  Nemulert
//
//  Created by Kanta Oikawa on 2025/11/04.
//

import CoreMotion

protocol DeviceMotionProtocol {
    associatedtype AttitudeType: AttitudeProtocol

    var attitude: AttitudeType { get }
    var rotationRate: CMRotationRate { get }
    var gravity: CMAcceleration { get }
    var userAcceleration: CMAcceleration { get }
    var magneticField: CMCalibratedMagneticField { get }
    var heading: Double { get }
    var sensorLocation: CMDeviceMotion.SensorLocation { get }
}

struct DeviceMotion: DeviceMotionProtocol, Equatable {
    let attitude: Attitude
    let rotationRate: CMRotationRate
    let gravity: CMAcceleration
    let userAcceleration: CMAcceleration
    let magneticField: CMCalibratedMagneticField
    let heading: Double
    let sensorLocation: CMDeviceMotion.SensorLocation

    init(
        attitude: Attitude,
        rotationRate: CMRotationRate,
        gravity: CMAcceleration,
        userAcceleration: CMAcceleration,
        magneticField: CMCalibratedMagneticField,
        heading: Double,
        sensorLocation: CMDeviceMotion.SensorLocation
    ) {
        self.attitude = attitude
        self.rotationRate = rotationRate
        self.gravity = gravity
        self.userAcceleration = userAcceleration
        self.magneticField = magneticField
        self.heading = heading
        self.sensorLocation = sensorLocation
    }

    init(deviceMotion: CMDeviceMotion) {
        self.attitude = Attitude(attitude: deviceMotion.attitude)
        self.rotationRate = deviceMotion.rotationRate
        self.gravity = deviceMotion.gravity
        self.userAcceleration = deviceMotion.userAcceleration
        self.magneticField = deviceMotion.magneticField
        self.heading = deviceMotion.heading
        self.sensorLocation = deviceMotion.sensorLocation
    }

    init(deviceMotion: some DeviceMotionProtocol) {
        self.attitude = Attitude(attitude: deviceMotion.attitude)
        self.rotationRate = deviceMotion.rotationRate
        self.gravity = deviceMotion.gravity
        self.userAcceleration = deviceMotion.userAcceleration
        self.magneticField = deviceMotion.magneticField
        self.heading = deviceMotion.heading
        self.sensorLocation = deviceMotion.sensorLocation
    }
}

extension DeviceMotion {
    static let stub = DeviceMotion(
        attitude: .stub,
        rotationRate: CMRotationRate(x: 0, y: 0, z: 0),
        gravity: CMAcceleration(x: 0, y: 0, z: 0),
        userAcceleration: CMAcceleration(x: 0, y: 0, z: 0),
        magneticField: CMCalibratedMagneticField(
            field: CMMagneticField(x: 0, y: 0, z: 0),
            accuracy: CMMagneticFieldCalibrationAccuracy.uncalibrated
        ),
        heading: 0,
        sensorLocation: CMDeviceMotion.SensorLocation.default
    )
}

extension CMDeviceMotion: DeviceMotionProtocol {
}

extension CMRotationRate: @retroactive Equatable {
    public static func == (lhs: CMRotationRate, rhs: CMRotationRate) -> Bool {
        lhs.x == rhs.x && lhs.y == rhs.y && lhs.z == rhs.z
    }
}

extension CMAcceleration: @retroactive Equatable {
    public static func == (lhs: CMAcceleration, rhs: CMAcceleration) -> Bool {
        lhs.x == rhs.x && lhs.y == rhs.y && lhs.z == rhs.z
    }
}

extension CMCalibratedMagneticField: @retroactive Equatable {
    public static func == (lhs: CMCalibratedMagneticField, rhs: CMCalibratedMagneticField) -> Bool {
        lhs.field.x == rhs.field.x &&
        lhs.field.y == rhs.field.y &&
        lhs.field.z == rhs.field.z &&
        lhs.accuracy == rhs.accuracy
    }
}
