//
//  DetectingModelTests.swift
//  NemulertTests
//
//  Created by Kanta Oikawa on 2025/10/30.
//

import AlarmKit
import CoreMotion
import Dependencies
import Foundation
@testable import Nemulert
import Testing

struct DetectingModelTests {
    @Test("画面が表示された")
    @MainActor func testOnAppear() async throws {
        let model = withDependencies {
            $0.alarmService.requestAuthorization = {
                .notDetermined
            }
            $0.motionService.connectionUpdates = {
                AsyncStream { continuation in
                    continuation.finish()
                }
            }
            $0.motionService.motionUpdates = { _ in
                AsyncThrowingStream { continuation in
                    continuation.finish()
                }
            }
            $0.notificationService.requestAuthorization = {
                false
            }
        } operation: {
            DetectingModel()
        }

        model.onAppear()

        #expect(model.isConnected == false)
        #expect(model.motion == nil)
        #expect(model.motions == [])
        #expect(model.dozing == .idle)
        #expect(model.dozingCount == 0)
    }

    @Test("ヘッドフォンが接続された")
    @MainActor func testOnHeadphoneConnected() async throws {
        let (connectionUpdates, connectionUpdatesContinuation) = AsyncStream<Bool>.makeStream()

        let model = withDependencies {
            $0.alarmService.requestAuthorization = {
                .notDetermined
            }
            $0.motionService.connectionUpdates = {
                connectionUpdates
            }
            $0.motionService.motionUpdates = { _ in
                AsyncThrowingStream { continuation in
                    continuation.finish()
                }
            }
            $0.notificationService.requestAuthorization = {
                false
            }
        } operation: {
            DetectingModel()
        }

        model.onAppear()

        let isConnected = true
        connectionUpdatesContinuation.yield(isConnected)
        try await Task.sleep(for: .seconds(1))
        #expect(model.isConnected == isConnected)
    }

    @Test("ヘッドフォンの接続が切断された")
    @MainActor func testOnHeadphoneDisconnected() async throws {
        // TODO: Implement
    }

    @Test("1個のモーションデータが検出された")
    @MainActor func testOn1MotionsStreamed() async throws {
        let (motionUpdates, motionUpdatesContinuation) = AsyncThrowingStream<DeviceMotion, Error>.makeStream()

        let model = withDependencies {
            $0.alarmService.requestAuthorization = {
                .notDetermined
            }
            $0.motionService.connectionUpdates = {
                AsyncStream { continuation in
                    continuation.finish()
                }
            }
            $0.motionService.motionUpdates = { _ in
                motionUpdates
            }
            $0.notificationService.requestAuthorization = {
                false
            }
        } operation: {
            DetectingModel()
        }

        model.onAppear()

        motionUpdatesContinuation.yield(DeviceMotion.stub)
        try await Task.sleep(for: .seconds(1))
        #expect(model.motion == DeviceMotion.stub)
        #expect(model.motions == [DeviceMotion.stub])
    }

    @Test("150個のモーションデータが検出された")
    @MainActor func testOn150MotionsStreamed() async throws {
        // TODO: Implement
    }

    @Test("1度の居眠りが検知された")
    @MainActor func testOnDozingDetecting1Time() async throws {
        // TODO: Implement
    }

    @Test("2度の居眠りが検知された")
    @MainActor func testOnDozingDetecting2Times() async throws {
        // TODO: Implement
    }
}
