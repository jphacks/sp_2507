//
//  DetectingModelTests.swift
//  NemulertTests
//
//  Created by Kanta Oikawa on 2025/10/30.
//

import AlarmKit
import Dependencies
import Foundation
@testable import Nemulert
import Testing

struct DetectingModelTests {
    @MainActor
    @Test func testInit() async throws {
        let model = withDependencies {
            $0.uuid = UUIDGenerator {
                UUID(0)
            }
            $0[AlarmService.self] = AlarmService(
                requestAuthorization: {
                    .authorized
                },
                getAlarms: {
                    []
                },
                scheduleAlarm: { _ in
                },
                cancelAllAlarms: {
                }
            )
            $0[DozingDetectionService.self] = DozingDetectionService(
                predict: { _ in
                    .idle
                }
            )
            $0[MotionService.self] = MotionService(
                updateConnection: { _ in
                },
                updateMotion: { _, _ in
                }
            )
            $0[NotificationService.self] = NotificationService(
                requestAuthorization: {
                    true
                },
                requestNotification: { _, _, _ in
                }
            )
        } operation: {
            DetectingModel()
        }

        #expect(model.isConnected == false)
        #expect(model.motion == nil)
        #expect(model.startingPose == nil)
        #expect(model.motions == [])
        #expect(model.dozing == .idle)
        #expect(model.dozingCount == 0)
    }

    @MainActor
    @Test func testOnAppear() async throws {
        let model = withDependencies {
            $0.uuid = UUIDGenerator {
                UUID(0)
            }
            $0[AlarmService.self] = AlarmService(
                requestAuthorization: {
                    .authorized
                },
                getAlarms: {
                    []
                },
                scheduleAlarm: { _ in
                },
                cancelAllAlarms: {
                }
            )
            $0[DozingDetectionService.self] = DozingDetectionService(
                predict: { _ in
                    .idle
                }
            )
            $0[MotionService.self] = MotionService(
                updateConnection: { _ in
                },
                updateMotion: { _, _ in
                }
            )
            $0[NotificationService.self] = NotificationService(
                requestAuthorization: {
                    true
                },
                requestNotification: { _, _, _ in
                }
            )
        } operation: {
            DetectingModel()
        }

        model.onAppear()

        #expect(model.isConnected == false)
        #expect(model.motion == nil)
        #expect(model.startingPose == nil)
        #expect(model.motions == [])
        #expect(model.dozing == .idle)
        #expect(model.dozingCount == 0)
    }
}
