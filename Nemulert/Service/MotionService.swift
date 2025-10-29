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
    var getConnectionUpdatesTask: (_ handler: @escaping @Sendable (Bool) async throws -> Void) throws -> Task<Void, Error>
    var getMotionUpdatesTask: (_ name: String, _ handler: @escaping @Sendable (CMDeviceMotion) async throws -> Void) throws -> Task<Void, Error>
}

extension MotionService: DependencyKey {
    static let liveValue = MotionService(
        getConnectionUpdatesTask: { handler in
            Task.detached(priority: .background) {
                for await isConnected in HeadphoneMotionManager().connectionUpdates() {
                    try await handler(isConnected)
                }
            }
        },
        getMotionUpdatesTask: { name, handler in
            Task.detached(priority: .background) {
                let queue = OperationQueue()
                queue.name = name
                queue.maxConcurrentOperationCount = 1
                queue.qualityOfService = .background
                for try await motion in try HeadphoneMotionUpdate.updates(queue: queue) {
                    try await handler(motion)
                }
            }
        }
    )
}

extension MotionService: TestDependencyKey {
    static let testValue = MotionService()

    static let previewValue = MotionService(
        getConnectionUpdatesTask: { _ in
            Task {
            }
        },
        getMotionUpdatesTask: { _, _ in
            Task {
            }
        }
    )
}
