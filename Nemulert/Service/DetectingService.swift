//
//  DetectingService.swift
//  Nemulert
//
//  Created by Kanta Oikawa on 2025/12/06.
//

import Dependencies
import Foundation

final actor DetectingService {
    /// 直近のモーション
    ///
    /// セット時に`motions`に追加する。
    private(set) var motion: DeviceMotion? = nil {
        willSet {
            guard let newValue else { return }
            motions.append(newValue)
        }
    }
    /// モーションのログ
    ///
    /// `motion`セット時に追加される。
    private(set) var motions: [DeviceMotion] = []

    /// 直近の居眠り判定結果
    ///
    /// セット時に`dozingCount`の値をセットする。
    private(set) var dozing: Dozing = .idle {
        willSet {
            switch newValue {
            case .idle:
                dozingCount = 0

            case .dozing:
                dozingCount += 1
            }
        }
    }
    /// 連続居眠り判定回数
    ///
    /// `dozing`セット時に合わせてセットされる。
    private(set) var dozingCount: Int = 0

    /// AirPods 接続状態
    let (connectionStream, connectionContinuation) = AsyncStream<Bool>.makeStream()
    /// モーションデータ
    let (motionStream, motionContinuation) = AsyncStream<DeviceMotion>.makeStream()

    /// 居眠り判定に使用するモーションデータ数
    ///
    /// Core ML モデルのWindowサイズに合わせる。異なるとクラッシュする。
    let windowSize: Int = 130

    /// モーションデータを監視するQueueの名前
    private let queueName: String = "com.kantacky.Nemulert.headphone_motion_update"

    /// AirPods 接続状態を受け取るタスク
    ///
    /// 新しい値がセットされたら、古いタスクをキャンセルする。
    private var updateConnectionTask: Task<Void, Error>? {
        didSet {
            oldValue?.cancel()
        }
    }
    /// モーションデータを受け取るタスク
    ///
    /// 新しい値がセットされたら、古いタスクをキャンセルする。
    private var updateMotionTask: Task<Void, Error>? {
        didSet {
            oldValue?.cancel()
        }
    }

    @Dependency(\.uuid) private var uuid
    @Dependency(\.alarmRepository) private var alarmRepository
    @Dependency(\.dozingDetectionRepository) private var dozingDetectionRepository
    @Dependency(\.motionRepository) private var motionRepository
    @Dependency(\.notificationRepository) private var notificationRepository

    /// AlarmKit の権限リクエスト
    /// - Returns: 許可されたかどうか
    func requestAlarmAuthorization() async throws {
        try await alarmRepository.requestAuthorization()
    }

    /// 通知の権限リクエスト
    /// - Returns: 許可されたかどうか
    func requestNotificationAuthorization() async throws {
        try await notificationRepository.requestAuthorization()
    }

    /// アラーム解除
    ///
    /// 設定されている全てのアラームを解除する。
    func cancelAllAlarms() async throws {
        try await alarmRepository.cancelAllAlarms()
    }

    /// タスクを再起動
    ///
    /// AirPods 接続状態、モーションデータを受け取るタスクを再起動する。
    func restartTasks() async throws {
        dozing = .idle
        try restartConnectionUpdateTask()
        try await restartMotionUpdateTask()
    }

    /// AirPods 接続状態を受け取るタスクを再起動
    private func restartConnectionUpdateTask() throws {
        let updates = try motionRepository.connectionUpdates()

        updateConnectionTask = Task {
            for await isConnected in updates {
                connectionContinuation.yield(isConnected)
                if isConnected {
                    try await restartMotionUpdateTask()
                }
            }
        }
    }

    /// モーションデータを受け取るタスクを再起動
    private func restartMotionUpdateTask() async throws {
        let updates = try await motionRepository.motionUpdates(queueName: queueName)
        updateMotionTask = Task {
            for try await motion in updates {
                try await handleMotion(motion)
            }
        }
    }

    /// 受け取ったモーションデータを処理
    /// - Parameter motion: モーションデータ
    private func handleMotion(_ motion: DeviceMotion) async throws {
        guard try alarmRepository.getAlarms().isEmpty else { return }
        self.motion = motion
        guard motions.count >= windowSize else { return }
        let motions = Array(motions.prefix(windowSize))
        self.motions.removeAll()
        let result = try await dozingDetectionRepository.predict(motions: motions)
        try await handlePredictionResult(result)
    }

    /// 居眠り判定予測結果を処理
    /// - Parameter result: 居眠り判定予測結果
    private func handlePredictionResult(_ result: DozingResult) async throws {
        if await result.dozing.isDozing && result.confidence > 0.99 {
            dozing = .dozing
            if self.dozingCount >= 2 {
                _ = try await alarmRepository.scheduleAlarm(id: uuid())
                _ = try await notificationRepository.requestNotification(
                    title: String(localized: "Are you dozing off?"),
                    body: String(localized: "Tap to continue working!"),
                    categoryIdentifier: "dozing"
                )
            }
        } else {
            dozing = .idle
        }
        await Logger.info("Dozing prediction: \(dozing.rawValue)")
    }
}
