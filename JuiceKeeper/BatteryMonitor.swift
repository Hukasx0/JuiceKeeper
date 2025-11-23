import Foundation
import Combine

/// Monitors the battery level on a timer and coordinates alerts.
final class BatteryMonitor: ObservableObject {

    @Published private(set) var currentPercentage: Int?
    @Published private(set) var isCharging: Bool = false
    @Published private(set) var isFullyCharged: Bool = false

    private let settings: AppSettings
    private var timer: Timer?
    private var cancellables = Set<AnyCancellable>()

    private var lastPercentage: Int?
    private var lastBatteryInfo: BatteryInfo?
    private var hasAlertedForCurrentChargeCycle = false

    init(settings: AppSettings) {
        self.settings = settings
        bindToSettings()
        pollOnce()
        startTimer()
    }

    deinit {
        timer?.invalidate()
        ChargingSleepController.shared.deactivateIfNeeded()
    }

    /// Manually force a refresh (useful for debugging or future UI).
    func pollOnce() {
        DispatchQueue.global(qos: .utility).async {
            guard let info = BatteryInfoReader.read() else { return }

            DispatchQueue.main.async { [weak self] in
                self?.handleNewInfo(info)
            }
        }
    }

    private func bindToSettings() {
        settings.$pollingIntervalSeconds
            .removeDuplicates()
            .sink { [weak self] _ in
                self?.startTimer()
            }
            .store(in: &cancellables)

        settings.$alertThreshold
            .removeDuplicates()
            .sink { [weak self] _ in
                guard let self else { return }
                self.hasAlertedForCurrentChargeCycle = false
                if let info = self.lastBatteryInfo {
                    self.updateChargingSleepAssertion(info: info)
                }
            }
            .store(in: &cancellables)

        settings.$keepAwakeWhileCharging
            .removeDuplicates()
            .sink { [weak self] _ in
                guard let self, let info = self.lastBatteryInfo else {
                    ChargingSleepController.shared.deactivateIfNeeded()
                    return
                }
                self.updateChargingSleepAssertion(info: info)
            }
            .store(in: &cancellables)
    }

    private func startTimer() {
        timer?.invalidate()

        let interval = settings.pollingIntervalSeconds
        guard interval > 0 else { return }

        let newTimer = Timer(
            timeInterval: interval,
            repeats: true
        ) { [weak self] _ in
            self?.pollOnce()
        }

        timer = newTimer
        RunLoop.main.add(newTimer, forMode: .common)
    }

    private func handleNewInfo(_ info: BatteryInfo) {
        lastPercentage = currentPercentage
        lastBatteryInfo = info

        currentPercentage = info.percentage
        isCharging = info.isCharging
        isFullyCharged = info.isFullyCharged

        updateChargingSleepAssertion(info: info)
        evaluateThresholdIfNeeded(info: info)
    }

    private func evaluateThresholdIfNeeded(info: BatteryInfo) {
        let level = info.percentage
        let threshold = settings.alertThreshold

        guard let previous = lastPercentage else { return }

        if hasAlertedForCurrentChargeCycle {
            if level < threshold - 5 {
                hasAlertedForCurrentChargeCycle = false
            }
            return
        }

        guard previous < threshold, level >= threshold else { return }

        hasAlertedForCurrentChargeCycle = true
        ChargingSleepController.shared.deactivateIfNeeded()

        if settings.wakeDisplayOnAlert {
            DisplayWakeHelper.wakeDisplayIfPossible()
        }

        NotificationManager.shared.notifyBatteryThresholdReached(
            level: level,
            threshold: threshold,
            soundEnabled: settings.isSoundEnabled
        )
    }

    private func updateChargingSleepAssertion(info: BatteryInfo) {
        let belowThreshold = info.percentage < settings.alertThreshold
        ChargingSleepController.shared.update(
            enabled: settings.keepAwakeWhileCharging,
            isCharging: info.isCharging,
            belowThreshold: belowThreshold
        )
    }
}
