import Foundation
import Combine

/// Monitors the battery level on a timer and coordinates alerts.
final class BatteryMonitor: ObservableObject {

    @Published private(set) var currentPercentage: Int?
    @Published private(set) var isCharging: Bool = false
    @Published private(set) var isFullyCharged: Bool = false
    
    /// Current battery temperature in degrees Celsius, if available.
    @Published private(set) var currentTemperature: Double?
    
    /// Indicates whether the battery temperature exceeds the configured threshold.
    @Published private(set) var isOverheating: Bool = false

    private let settings: AppSettings
    private var timer: Timer?
    private var cancellables = Set<AnyCancellable>()

    private var lastPercentage: Int?
    private var lastBatteryInfo: BatteryInfo?
    private var hasAlertedForCurrentChargeCycle = false
    
    /// Tracks whether we've already alerted for the current overheating event.
    /// Resets when temperature drops below threshold with hysteresis.
    private var hasAlertedForCurrentOverheat = false

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
        currentTemperature = info.temperatureCelsius

        updateChargingSleepAssertion(info: info)
        evaluateThresholdIfNeeded(info: info)
        evaluateTemperatureIfNeeded(info: info)
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
    
    // MARK: - Temperature Monitoring
    
    /// Evaluates battery temperature and triggers alert if threshold is exceeded.
    ///
    /// Uses a 2°C hysteresis to prevent alert spam when temperature fluctuates around the threshold.
    private func evaluateTemperatureIfNeeded(info: BatteryInfo) {
        guard let temperature = info.temperatureCelsius else {
            isOverheating = false
            return
        }
        
        let threshold = settings.temperatureThresholdCelsius
        let currentlyOverheating = temperature >= threshold
        
        isOverheating = currentlyOverheating
        
        // Reset alert flag when temperature drops sufficiently below threshold (2°C hysteresis)
        if hasAlertedForCurrentOverheat && temperature < threshold - 2.0 {
            hasAlertedForCurrentOverheat = false
        }
        
        // Skip if alerts are disabled or we've already alerted for this overheat event
        guard settings.isTemperatureAlertEnabled,
              currentlyOverheating,
              !hasAlertedForCurrentOverheat else {
            return
        }
        
        hasAlertedForCurrentOverheat = true
        
        if settings.wakeDisplayOnAlert {
            DisplayWakeHelper.wakeDisplayIfPossible()
        }
        
        NotificationManager.shared.notifyBatteryOverheating(
            temperature: temperature,
            threshold: threshold,
            soundEnabled: settings.isSoundEnabled
        )
    }
}
