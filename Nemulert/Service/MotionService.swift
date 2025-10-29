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
    var getMotionUpdateTask: (_ name: String, _ handler: @escaping @Sendable (CMDeviceMotion) async throws -> Void) throws -> Task<Void, Error>
}

extension MotionService: DependencyKey {
    static let liveValue = MotionService(
        getMotionUpdateTask: { name, handler in
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

    static let previewValue = MotionService()
}
