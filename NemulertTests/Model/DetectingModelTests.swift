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

@MainActor
struct DetectingModelTests {
    @Test("画面が表示された時に、アラームと通知の許可がリクエストされること")
    func testOnAppear() async throws {
        let model = DetectingModel()

        #expect(model.isAlarmAuthorized == false)
        #expect(model.isNotificationAuthorized == false)

        await model.onAppear()

        #expect(model.isAlarmAuthorized == true)
        #expect(model.isNotificationAuthorized == true)
    }

    @Test("画面が表示された時に、アラームと通知の許可がリクエストされ、拒否されること")
    func testOnAppearWithAuthorizationDenied() async throws {
        let model = withDependencies {
            $0.alarmRepository.requestAuthorization = {
                throw DomainError.alarmNotAuthorized
            }
            $0.notificationRepository.requestAuthorization = {
                throw DomainError.notificationNotAuthorized
            }
        } operation: {
            DetectingModel()
        }

        #expect(model.isAlarmAuthorized == false)
        #expect(model.isNotificationAuthorized == false)

        await model.onAppear()

        #expect(model.isAlarmAuthorized == false)
        #expect(model.isNotificationAuthorized == false)
    }

    @Test("ヘッドフォンが接続された時に、接続状態が変化すること", .timeLimit(.minutes(1)))
    func testOnHeadphoneConnected() async throws {
        let (connectionStream, connectionContinuation) = AsyncStream<Bool>.makeStream()

        let model = withDependencies {
            $0.motionRepository.connectionUpdates = {
                connectionStream
            }
        } operation: {
            DetectingModel()
        }

        await model.onAppear()

        #expect(model.isConnected == false)

        let task = Task {
            for await _ in Observations({ model.isConnected }).dropFirst() {
                break
            }
        }

        connectionContinuation.yield(true)

        await task.value

        #expect(model.isConnected == true)
    }

    @Test("シーンが切り替わった時に、全てのアラームが解除され、タスクが再起動されること")
    func testOnSceneChanged() async throws {
    }
}
