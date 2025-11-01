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
    var updateConnection: @Sendable (_ handler: @escaping @Sendable (Bool) async throws -> Void) async throws -> Void
    var updateMotion: @Sendable (_ name: String, _ handler: @escaping @Sendable (CMDeviceMotion) async throws -> Void) async throws -> Void
}

extension MotionService: DependencyKey {
    static let liveValue = MotionService(
        updateConnection: { handler in
            for await isConnected in HeadphoneMotionManager().connectionUpdates() {
                try await handler(isConnected)
            }
        },
        updateMotion: { name, handler in
            let queue = OperationQueue()
            queue.name = name
            queue.maxConcurrentOperationCount = 1
            queue.qualityOfService = .background
            for try await motion in try HeadphoneMotionUpdate.updates(queue: queue) {
                try await handler(motion)
            }
        }
    )
}

nonisolated extension MotionService: TestDependencyKey {
    static let testValue = MotionService()

    static let previewValue = MotionService(
        updateConnection: { _ in
        },
        updateMotion: { _, _ in
        }
    )
}

extension DependencyValues {
    nonisolated var motionService: MotionService {
        get { self[MotionService.self] }
        set { self[MotionService.self] = newValue }
    }
}
