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
        let model = DetectingModel()

        model.onAppear()

        #expect(model.isConnected == false)
        #expect(model.motion == nil)
        #expect(model.motions == [])
        #expect(model.dozing == .idle)
        #expect(model.dozingCount == 0)
    }

    @Test("ヘッドフォンが接続・切断された")
    @MainActor func testOnHeadphoneConnectedAndDisconnected() async throws {
        let (connectionUpdates, connectionUpdatesContinuation) = AsyncStream<Bool>.makeStream()

        let model = withDependencies {
            $0.motionService.connectionUpdates = {
                connectionUpdates
            }
        } operation: {
            DetectingModel()
        }

        model.onAppear()

        connectionUpdatesContinuation.yield(true)

        try await Task.sleep(for: .seconds(1))

        #expect(model.isConnected == true)

        connectionUpdatesContinuation.yield(false)

        try await Task.sleep(for: .seconds(1))

        #expect(model.isConnected == false)
    }

    @Test("1個のモーションデータが検出された")
    @MainActor func testOn1MotionsStreamed() async throws {
        let (motionUpdates, motionUpdatesContinuation) = AsyncThrowingStream<DeviceMotion, Error>.makeStream()

        let model = withDependencies {
            $0.motionService.motionUpdates = { _ in
                motionUpdates
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

    @Test("windowSizeと同数のモーションデータが検出された")
    @MainActor func testOnWindowSizeMotionsStreamed() async throws {
        let (motionUpdates, motionUpdatesContinuation) = AsyncThrowingStream<DeviceMotion, Error>.makeStream()

        let model = withDependencies {
            $0.motionService.motionUpdates = { _ in
                motionUpdates
            }
        } operation: {
            DetectingModel()
        }

        model.onAppear()

        let motions = Array(repeating: DeviceMotion.stub, count: model.windowSize)
        motions.forEach { motion in
            motionUpdatesContinuation.yield(motion)
        }
        try await Task.sleep(for: .seconds(2))
        #expect(model.motion == motions.last)
        #expect(model.motions == [])
    }

    @Test("居眠りが1度検知された")
    @MainActor func testOnDozingDetected1Time() async throws {
        let (motionUpdates, motionUpdatesContinuation) = AsyncThrowingStream<DeviceMotion, Error>.makeStream()

        let model = withDependencies {
            $0.dozingDetectionService.predict = { _ in
                .dozing
            }
            $0.motionService.motionUpdates = { _ in
                motionUpdates
            }
        } operation: {
            DetectingModel()
        }

        model.onAppear()

        let motions = Array(repeating: DeviceMotion.stub, count: model.windowSize)
        motions.forEach { motion in
            motionUpdatesContinuation.yield(motion)
        }
        try await Task.sleep(for: .seconds(2))
        #expect(model.dozing == .dozing)
        #expect(model.dozingCount == 1)
    }

    @Test("居眠りが2度検知された")
    @MainActor func testOnDozingDetected2Times() async throws {
        let (motionUpdates, motionUpdatesContinuation) = AsyncThrowingStream<DeviceMotion, Error>.makeStream()

        let model = withDependencies {
            $0.uuid = .incrementing
            $0.dozingDetectionService.predict = { _ in
                .dozing
            }
            $0.motionService.motionUpdates = { _ in
                motionUpdates
            }
        } operation: {
            DetectingModel()
        }

        model.onAppear()

        let motions = Array(repeating: DeviceMotion.stub, count: model.windowSize)
        motions.forEach { motion in
            motionUpdatesContinuation.yield(motion)
        }
        motions.forEach { motion in
            motionUpdatesContinuation.yield(motion)
        }
        try await Task.sleep(for: .seconds(2))
        #expect(model.dozing == .dozing)
        #expect(model.dozingCount == 0)
    }
}
