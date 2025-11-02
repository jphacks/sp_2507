//
//  MotionService.swift
//  Nemulert
//
//  Created by Kanta Oikawa on 2025/10/29.
//

import CoreMotion
import Dependencies
import DependenciesMacros
import HeadphoneMotion
import UserNotifications

@DependencyClient
nonisolated struct MotionService {
    var connectionUpdates: @Sendable () throws -> AsyncStream<Bool>
    var motionUpdates: @Sendable (_ queueName: String) async throws -> AsyncThrowingStream<CMDeviceMotion, Error>
}

extension MotionService: DependencyKey {
    static let liveValue = MotionService(
        connectionUpdates: {
            HeadphoneMotionManager().connectionUpdates()
        },
        motionUpdates: { queueName in
            let queue = OperationQueue()
            queue.name = queueName
            queue.maxConcurrentOperationCount = 1
            queue.qualityOfService = .background
            return try HeadphoneMotionUpdate.updates(queue: queue)
        }
    )
}

nonisolated extension MotionService: TestDependencyKey {
    static let testValue = MotionService()

    static let previewValue = MotionService(
        connectionUpdates: {
            AsyncStream<Bool> { continuation in
                continuation.finish()
            }
        },
        motionUpdates: { _ in
            AsyncThrowingStream<CMDeviceMotion, Error> { continuation in
                continuation.finish()
            }
        }
    )
}

extension DependencyValues {
    nonisolated var motionService: MotionService {
        get { self[MotionService.self] }
        set { self[MotionService.self] = newValue }
    }
}
