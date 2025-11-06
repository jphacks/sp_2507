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
import Foundation
import UserNotifications

enum DozingDetectionServiceError: Error {
    case modelResourceMissing
}

@DependencyClient
nonisolated struct DozingDetectionService {
    var predict: @Sendable (_ motions: [DeviceMotion]) async throws -> Dozing
}

extension DozingDetectionService: DependencyKey {
    static let liveValue = DozingDetectionService(
        predict: { motions in
            let configuration = MLModelConfiguration()
            guard let modelURL = Bundle.main.url(forResource: "DozingDetection", withExtension: "mlmodelc") else {
                throw DozingDetectionServiceError.modelResourceMissing
            }
            let model = try MLModel(contentsOf: modelURL, configuration: configuration)
            let rotationRateX = try MLMultiArray(motions.map { $0.rotationRate.x })
            let rotationRateY = try MLMultiArray(motions.map { $0.rotationRate.y })
            let stateIn = try MLMultiArray(shape: [400], dataType: .double)
            let input = try MLDictionaryFeatureProvider(
                dictionary: [
                    "rotation_rate_x": MLFeatureValue(multiArray: rotationRateX),
                    "rotation_rate_y": MLFeatureValue(multiArray: rotationRateY),
                    "stateIn": MLFeatureValue(multiArray: stateIn)
                ]
            )
            let prediction = try model.prediction(from: input)
            let label = prediction.featureValue(for: "label")?.stringValue ?? Dozing.idle.rawValue
            return Dozing(rawValue: label) ?? .idle
        }
    )
}

nonisolated extension DozingDetectionService: TestDependencyKey {
    static let testValue = DozingDetectionService(
        predict: { _ in
            .idle
        }
    )

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
