//
//  DozingDetectionService.swift
//  Nemulert
//
//  Created by Kanta Oikawa on 2025/10/29.
//

import CoreML
import CoreMotion
import Dependencies
import DependenciesMacros
import UserNotifications

@DependencyClient
struct DozingDetectionService {
    var predict: @Sendable (_ motions: [CMDeviceMotion]) async throws -> Dozing
}

extension DozingDetectionService: DependencyKey {
    static let liveValue = DozingDetectionService(
        predict: { motions in
            let configuration = MLModelConfiguration()
            let model = try await DozingDetection(configuration: configuration)
            let input = await DozingDetectionInput(
                attitude_pitch: try MLMultiArray(motions.map { $0.attitude.pitch }),
                attitude_roll: try MLMultiArray(motions.map { $0.attitude.roll }),
                attitude_yaw: try MLMultiArray(motions.map { $0.attitude.yaw }),
                rotation_rate_x: try MLMultiArray(motions.map { $0.rotationRate.x }),
                rotation_rate_y: try MLMultiArray(motions.map { $0.rotationRate.y }),
                rotation_rate_z: try MLMultiArray(motions.map { $0.rotationRate.z }),
                stateIn: try MLMultiArray(shape: [400], dataType: .double)
            )
            let output = try await model.prediction(input: input)
            let label = await output.label
            print("\(label) detected.")
            return Dozing(rawValue: label) ?? .idle
        }
    )
}

extension DozingDetectionService: TestDependencyKey {
    static let testValue = DozingDetectionService()

    static let previewValue = DozingDetectionService()
}
