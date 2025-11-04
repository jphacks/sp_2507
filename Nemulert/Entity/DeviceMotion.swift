//
//  DeviceMotion.swift
//  Nemulert
//
//  Created by Kanta Oikawa on 2025/11/04.
//

import CoreMotion

struct DeviceMotion {
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
}
