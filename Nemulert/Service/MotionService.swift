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
struct MotionService {
    var getConnectionUpdatesTask: @Sendable (_ handler: @escaping @Sendable (Bool) async throws -> Void) async throws -> Void
    var getMotionUpdatesTask: @Sendable (_ name: String, _ handler: @escaping @Sendable (CMDeviceMotion) async throws -> Void) async throws -> Void
}

extension MotionService: DependencyKey {
    static let liveValue = MotionService(
        getConnectionUpdatesTask: { handler in
            for await isConnected in HeadphoneMotionManager().connectionUpdates() {
                try await handler(isConnected)
            }
        },
        getMotionUpdatesTask: { name, handler in
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

extension MotionService: TestDependencyKey {
    static let testValue = MotionService()

    static let previewValue = MotionService(
        getConnectionUpdatesTask: { _ in
        },
        getMotionUpdatesTask: { _, _ in
        }
    )
}
