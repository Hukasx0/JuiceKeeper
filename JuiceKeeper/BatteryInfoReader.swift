import Foundation
import IOKit.ps

/// Snapshot of the current battery status.
struct BatteryInfo {
    let percentage: Int
    let isCharging: Bool
    let isFullyCharged: Bool
}

/// Reads battery information from the system using IOKit.
enum BatteryInfoReader {

    /// Returns the current `BatteryInfo` if an internal battery is present.
    static func read() -> BatteryInfo? {
        guard let snapshot = IOPSCopyPowerSourcesInfo()?.takeRetainedValue() else {
            return nil
        }

        guard let sources = IOPSCopyPowerSourcesList(snapshot)?.takeRetainedValue() as? [CFTypeRef] else {
            return nil
        }

        for powerSource in sources {
            guard
                let description = IOPSGetPowerSourceDescription(snapshot, powerSource)?
                    .takeUnretainedValue() as? [String: Any]
            else {
                continue
            }

            guard let type = description[kIOPSTypeKey as String] as? String,
                  type == kIOPSInternalBatteryType as String
            else {
                continue
            }

            guard
                let currentCapacity = description[kIOPSCurrentCapacityKey as String] as? Int,
                let maxCapacity = description[kIOPSMaxCapacityKey as String] as? Int,
                maxCapacity > 0
            else {
                continue
            }

            let percentage = Int((Double(currentCapacity) / Double(maxCapacity)) * 100.0)
            let isCharging = (description[kIOPSIsChargingKey as String] as? Bool) ?? false
            let isFullyCharged = (description[kIOPSIsChargedKey as String] as? Bool) ?? false

            return BatteryInfo(
                percentage: percentage,
                isCharging: isCharging,
                isFullyCharged: isFullyCharged
            )
        }

        return nil
    }
}
