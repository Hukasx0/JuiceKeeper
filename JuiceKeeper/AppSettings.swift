import Foundation
import Combine

/// Shared application settings controlling when and how JuiceKeeper alerts the user.
///
/// Values are persisted in `UserDefaults` to survive app restarts.
final class AppSettings: ObservableObject {

    /// Battery percentage at which we fire an alert.
    /// Range is clamped to 1...100.
    @Published var alertThreshold: Int {
        didSet {
            if alertThreshold < 1 {
                alertThreshold = 1
            } else if alertThreshold > 100 {
                alertThreshold = 100
            }
            persist(.alertThreshold, alertThreshold)
        }
    }

    /// How often (in seconds) the battery level should be polled.
    /// Range is clamped to 5...600 seconds.
    @Published var pollingIntervalSeconds: Double {
        didSet {
            if pollingIntervalSeconds < 5 {
                pollingIntervalSeconds = 5
            } else if pollingIntervalSeconds > 600 {
                pollingIntervalSeconds = 600
            }
            persist(.pollingIntervalSeconds, pollingIntervalSeconds)
        }
    }

    /// Whether the notification should play a sound.
    @Published var isSoundEnabled: Bool {
        didSet {
            persist(.isSoundEnabled, isSoundEnabled)
        }
    }

    /// Whether we should try to wake the display when the alert fires.
    @Published var wakeDisplayOnAlert: Bool {
        didSet {
            persist(.wakeDisplayOnAlert, wakeDisplayOnAlert)
        }
    }

    /// Whether we should keep the Mac awake while charging until the threshold is reached.
    /// This prevents idle system sleep but still allows the display to turn off.
    @Published var keepAwakeWhileCharging: Bool {
        didSet {
            persist(.keepAwakeWhileCharging, keepAwakeWhileCharging)
        }
    }

    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults

        let storedThreshold = userDefaults.object(forKey: Key.alertThreshold.rawValue) as? Int
        alertThreshold = Self.clamp(storedThreshold ?? 80, min: 0, max: 100)

        let storedInterval = userDefaults.object(forKey: Key.pollingIntervalSeconds.rawValue) as? Double
        pollingIntervalSeconds = Self.clamp(storedInterval ?? 15, min: 5, max: 600)

        if let storedSound = userDefaults.object(forKey: Key.isSoundEnabled.rawValue) as? Bool {
            isSoundEnabled = storedSound
        } else {
            isSoundEnabled = true
        }

        if let storedWake = userDefaults.object(forKey: Key.wakeDisplayOnAlert.rawValue) as? Bool {
            wakeDisplayOnAlert = storedWake
        } else {
            wakeDisplayOnAlert = true
        }

        if let storedKeepAwake = userDefaults.object(forKey: Key.keepAwakeWhileCharging.rawValue) as? Bool {
            keepAwakeWhileCharging = storedKeepAwake
        } else {
            keepAwakeWhileCharging = false
        }
    }

    private func persist<T>(_ key: Key, _ value: T) {
        userDefaults.set(value, forKey: key.rawValue)
    }

    private static func clamp<T: Comparable>(_ value: T, min: T, max: T) -> T {
        if value < min { return min }
        if value > max { return max }
        return value
    }

    private enum Key: String {
        case alertThreshold
        case pollingIntervalSeconds
        case isSoundEnabled
        case wakeDisplayOnAlert
        case keepAwakeWhileCharging
    }
}
