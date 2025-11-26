import Foundation
import IOKit.ps

/// Snapshot of the current battery status.
struct BatteryInfo {
    let percentage: Int
    let isCharging: Bool
    let isFullyCharged: Bool
    
    /// Battery temperature in degrees Celsius.
    /// Returns `nil` if temperature data is unavailable.
    let temperatureCelsius: Double?
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
            let temperature = readBatteryTemperature()

            return BatteryInfo(
                percentage: percentage,
                isCharging: isCharging,
                isFullyCharged: isFullyCharged,
                temperatureCelsius: temperature
            )
        }

        return nil
    }
    
    // MARK: - Temperature Reading via IOKit
    
    /// Reads battery temperature directly from the AppleSmartBattery IOKit service.
    ///
    /// The temperature is reported in centikelvin (1/100 of a Kelvin) by the SMC,
    /// and we convert it to degrees Celsius for display purposes.
    private static func readBatteryTemperature() -> Double? {
        var serviceIterator: io_iterator_t = 0
        
        let matchingDict = IOServiceMatching("AppleSmartBattery")
        let result = IOServiceGetMatchingServices(kIOMainPortDefault, matchingDict, &serviceIterator)
        
        guard result == KERN_SUCCESS else {
            return nil
        }
        
        defer {
            IOObjectRelease(serviceIterator)
        }
        
        let service = IOIteratorNext(serviceIterator)
        guard service != IO_OBJECT_NULL else {
            return nil
        }
        
        defer {
            IOObjectRelease(service)
        }
        
        // Read the Temperature property directly from AppleSmartBattery
        guard let temperatureRef = IORegistryEntryCreateCFProperty(
            service,
            "Temperature" as CFString,
            kCFAllocatorDefault,
            0
        ) else {
            return nil
        }
        
        let temperatureValue = temperatureRef.takeRetainedValue()
        
        guard let temperatureRaw = temperatureValue as? Int else {
            return nil
        }
        
        // Temperature is in decikelvin (1/10 K). Convert to Celsius.
        // Formula: °C = (decikelvin / 10) - 273.15
        let celsius = (Double(temperatureRaw) / 10.0) - 273.15
        
        return celsius
    }
}
