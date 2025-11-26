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
    /// Range is clamped to 1...600 seconds.
    /// Values below 5 seconds are allowed but may increase energy usage.
    @Published var pollingIntervalSeconds: Double {
        didSet {
            if pollingIntervalSeconds < 1 {
                pollingIntervalSeconds = 1
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
    
    // MARK: - Temperature Monitoring Settings
    
    /// Whether temperature monitoring and alerts are enabled.
    @Published var isTemperatureAlertEnabled: Bool {
        didSet {
            persist(.isTemperatureAlertEnabled, isTemperatureAlertEnabled)
        }
    }
    
    /// Temperature threshold in degrees Celsius at which we fire an alert.
    /// Range is clamped to 30...50°C. Typical safe operating range is under 35°C.
    @Published var temperatureThresholdCelsius: Double {
        didSet {
            if temperatureThresholdCelsius < 30 {
                temperatureThresholdCelsius = 30
            } else if temperatureThresholdCelsius > 50 {
                temperatureThresholdCelsius = 50
            }
            persist(.temperatureThresholdCelsius, temperatureThresholdCelsius)
        }
    }

    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults

        let storedThreshold = userDefaults.object(forKey: Key.alertThreshold.rawValue) as? Int
        alertThreshold = Self.clamp(storedThreshold ?? 80, min: 1, max: 100)

        let storedInterval = userDefaults.object(forKey: Key.pollingIntervalSeconds.rawValue) as? Double
        pollingIntervalSeconds = Self.clamp(storedInterval ?? 15, min: 1, max: 600)

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
        
        // Temperature monitoring defaults: enabled at 45°C threshold
        if let storedTempAlert = userDefaults.object(forKey: Key.isTemperatureAlertEnabled.rawValue) as? Bool {
            isTemperatureAlertEnabled = storedTempAlert
        } else {
            isTemperatureAlertEnabled = true
        }
        
        let storedTempThreshold = userDefaults.object(forKey: Key.temperatureThresholdCelsius.rawValue) as? Double
        temperatureThresholdCelsius = Self.clamp(storedTempThreshold ?? 45.0, min: 30.0, max: 50.0)
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
        case isTemperatureAlertEnabled
        case temperatureThresholdCelsius
    }
}
