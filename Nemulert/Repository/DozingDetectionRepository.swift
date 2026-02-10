//
//  DozingDetectionRepository.swift
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

@DependencyClient
nonisolated struct DozingDetectionRepository {
    var predict: @Sendable (_ motions: [DeviceMotion]) async throws -> DozingResult
}

nonisolated extension DozingDetectionRepository: DependencyKey {
    static let liveValue = DozingDetectionRepository(
        predict: { motions in
            let configuration = MLModelConfiguration()
            guard let modelURL = Bundle.main.url(forResource: "DozingDetection", withExtension: "mlmodelc") else {
                throw DozingDetectionRepositoryError.modelResourceMissing
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
            let prediction = try await model.prediction(from: input)
            let label = prediction.featureValue(for: "label")?.stringValue ?? Dozing.idle.rawValue
            let probabilityDict = prediction.featureValue(for: "labelProbability")?.dictionaryValue as? [String: Double] ?? [:]
            let probability = probabilityDict[label] ?? 0.0
            await Logger.debug("Probability for \(label): \(probability)")
            return DozingResult(
                dozing: Dozing(rawValue: label) ?? .idle,
                confidence: probability
            )
        }
    )
}

nonisolated extension DozingDetectionRepository: TestDependencyKey {
    static let testValue = DozingDetectionRepository(
        predict: { _ in
            DozingResult(dozing: .idle, confidence: 0.0)
        }
    )

    static let previewValue = DozingDetectionRepository(
        predict: { _ in
            DozingResult(dozing: .idle, confidence: 0.0)
        }
    )
}

nonisolated extension DependencyValues {
    var dozingDetectionRepository: DozingDetectionRepository {
        get { self[DozingDetectionRepository.self] }
        set { self[DozingDetectionRepository.self] = newValue }
    }
}
