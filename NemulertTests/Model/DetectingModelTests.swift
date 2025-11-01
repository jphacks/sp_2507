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
    /// 初期化された場合
    @MainActor
    @Test func testInit() async throws {
        let model = withDependencies {
            $0.alarmService.requestAuthorization = {
                .notDetermined
            }
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

    /// 画面が表示された場合
    @MainActor
    @Test func testOnAppear() async throws {
        let model = withDependencies {
            $0.alarmService.requestAuthorization = {
                .notDetermined
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
        #expect(model.startingPose == nil)
        #expect(model.motions == [])
        #expect(model.dozing == .idle)
        #expect(model.dozingCount == 0)
    }

    /// ヘッドフォンが接続された場合
    @MainActor
    @Test func testOnHeadphoneConnected() async throws {
        // TODO: Implement
    }

    /// ヘッドフォンの接続が切断された場合
    @MainActor
    @Test func testOnHeadphoneDisconnected() async throws {
        // TODO: Implement
    }

    /// 1個のモーションデータが検出された場合
    @MainActor
    @Test func testOn1MotionsStreamed() async throws {
        // TODO: Implement
    }

    /// 150個のモーションデータが検出された場合
    @MainActor
    @Test func testOn150MotionsStreamed() async throws {
        // TODO: Implement
    }

    /// 1度の居眠りが検知された場合
    @MainActor
    @Test func testOnDozingDetecting1Time() async throws {
        // TODO: Implement
    }

    /// 2度の居眠りが検知された場合
    @MainActor
    @Test func testOnDozingDetecting2Times() async throws {
        // TODO: Implement
    }
}
