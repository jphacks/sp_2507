//
//  MotionRepository.swift
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
nonisolated struct MotionRepository {
    var connectionUpdates: @Sendable () throws -> AsyncStream<Bool>
    var motionUpdates: @Sendable (_ queueName: String) async throws -> AsyncThrowingStream<DeviceMotion, Error>
}

extension MotionRepository: DependencyKey {
    static let liveValue = MotionRepository(
        connectionUpdates: {
            HeadphoneMotionManager().connectionUpdates()
        },
        motionUpdates: { queueName in
            let queue = OperationQueue()
            queue.name = queueName
            queue.maxConcurrentOperationCount = 1
            queue.qualityOfService = .background
            let updates = try HeadphoneMotionUpdate.updates(queue: queue)
            return AsyncThrowingStream { continuation in
                let task = Task {
                    do {
                        for try await update in updates {
                            let motion = await DeviceMotion(deviceMotion: update)
                            continuation.yield(motion)
                        }
                    } catch {
                        continuation.finish(throwing: error)
                    }
                }
                continuation.onTermination = { _ in
                    task.cancel()
                }
            }
        }
    )
}

nonisolated extension MotionRepository: TestDependencyKey {
    static let testValue = MotionRepository(
        connectionUpdates: {
            AsyncStream<Bool> { continuation in
                continuation.finish()
            }
        },
        motionUpdates: { _ in
            AsyncThrowingStream<DeviceMotion, Error> { continuation in
                continuation.finish()
            }
        }
    )

    static let previewValue = MotionRepository(
        connectionUpdates: {
            AsyncStream<Bool> { continuation in
                continuation.finish()
            }
        },
        motionUpdates: { _ in
            AsyncThrowingStream<DeviceMotion, Error> { continuation in
                continuation.finish()
            }
        }
    )
}

extension DependencyValues {
    nonisolated var motionRepository: MotionRepository {
        get { self[MotionRepository.self] }
        set { self[MotionRepository.self] = newValue }
    }
}
