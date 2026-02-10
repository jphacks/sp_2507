//
//  DetectingServiceTests.swift
//  NemulertTests
//
//  Created by Kanta Oikawa on 2025/12/07.
//

import Dependencies
@testable import Nemulert
import Testing

@MainActor
struct DetectingServiceTests {
    @Test("handleMotionでモーションが正しく処理されること", .timeLimit(.minutes(1)))
    func testHandleMotion() async throws {
        let (motionStream, motionContinuation) = AsyncThrowingStream<DeviceMotion, Error>.makeStream()
        let service = withDependencies {
            $0.motionRepository.motionUpdates = { _ in
                motionStream
            }
        } operation: {
            DetectingService()
        }

        #expect(await service.motion == nil)
        #expect(await service.motions.isEmpty)

        let mockedMotion = DeviceMotion.stub

        await confirmation { confirm in
            let task = Task {
                for await motion in await service.motionStream {
                    #expect(motion == mockedMotion)
                    confirm()
                }
            }
            motionContinuation.yield(mockedMotion)
            await task.value
        }

        #expect(await service.motion == mockedMotion)
        #expect(await service.motions == [mockedMotion])
    }

    @Test("handlePredictionResultで居眠り判定予測結果が正しく処理されること")
    func testHandlePredictionResult() async throws {
    }
}
