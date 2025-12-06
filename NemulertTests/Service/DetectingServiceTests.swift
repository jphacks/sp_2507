//
//  DetectingServiceTests.swift
//  NemulertTests
//
//  Created by Kanta Oikawa on 2025/12/07.
//

import AlarmKit
import Dependencies
@testable import Nemulert
import Testing

struct DetectingServiceTests {
    @Test("requestAuthorizationsが呼ばれた時にアラームと通知の許可を求めること")
    func testRequestAuthorizations() async throws {
        let service = withDependencies {
            $0.alarmRepository.requestAuthorization = {
                true
            }
            $0.notificationRepository.requestAuthorization = {
                true
            }
        } operation: {
            DetectingService()
        }

        #expect(await service.isAlarmAuthorized == false)
        #expect(await service.isNotificationAuthorized == false)

        await service.requestAuthorizations()

        #expect(await service.isAlarmAuthorized == true)
        #expect(await service.isNotificationAuthorized == true)
    }
}
