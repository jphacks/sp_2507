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
nonisolated struct DozingDetectionService {
    var predict: @Sendable (_ motions: [DeviceMotion]) async throws -> Dozing
}

extension DozingDetectionService: DependencyKey {
    static let liveValue = DozingDetectionService(
        predict: { motions in
            let configuration = MLModelConfiguration()
            let model = try await DozingDetection(configuration: configuration)
            let input = await DozingDetectionInput(
                rotation_rate_x: try MLMultiArray(motions.map { $0.rotationRate.x }),
                rotation_rate_y: try MLMultiArray(motions.map { $0.rotationRate.y }),
                stateIn: try MLMultiArray(shape: [400], dataType: .double)
            )
            let output = try await model.prediction(input: input)
            let label = await output.label
            print("\(label) detected.")
            return Dozing(rawValue: label) ?? .idle
        }
    )
}

nonisolated extension DozingDetectionService: TestDependencyKey {
    static let testValue = DozingDetectionService()

    static let previewValue = DozingDetectionService(
        predict: { _ in
            .idle
        }
    )
}

extension DependencyValues {
    nonisolated var dozingDetectionService: DozingDetectionService {
        get { self[DozingDetectionService.self] }
        set { self[DozingDetectionService.self] = newValue }
    }
}
