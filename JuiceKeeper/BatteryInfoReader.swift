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
    
    /// Number of charge cycles the battery has gone through, if available.
    let cycleCount: Int?
    
    /// Battery's maximum charge relative to its original design capacity, as a percentage (0–100).
    /// This is similar to the "Maximum Capacity" value shown in macOS Battery settings.
    let maximumCapacityPercent: Int?
    
    /// Estimated maximum capacity in milliampere-hours (mAh), if available.
    /// Derived from AppleRawMaxCapacity reported by the system.
    let maximumCapacityMah: Int?
    
    /// Original design capacity in milliampere-hours (mAh), if available.
    let designCapacityMah: Int?
    
    /// Human-readable health or condition string provided by the system, if available.
    /// Example values include "Good", "Fair", or "Service Recommended" depending on macOS version.
    let conditionDescription: String?
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
            let healthMetrics = readBatteryHealthMetrics()

            let maximumCapacityPercent: Int?
            let maximumCapacityMah: Int?
            let designCapacityMah = healthMetrics?.designCapacity
            if let metrics = healthMetrics,
               let rawMaxCapacity = metrics.rawMaxCapacity,
               let designCapacity = metrics.designCapacity,
               designCapacity > 0 {
                // Use AppleRawMaxCapacity (mAh) / DesignCapacity (mAh) for accurate health %.
                let ratio = Double(rawMaxCapacity) / Double(designCapacity)
                let percent = min(100, Int((ratio * 100.0).rounded()))
                // Discard obviously bogus values instead of showing misleading data.
                if (1...100).contains(percent) {
                    maximumCapacityPercent = percent
                    maximumCapacityMah = rawMaxCapacity
                } else {
                    maximumCapacityPercent = nil
                    maximumCapacityMah = nil
                }
            } else {
                maximumCapacityPercent = nil
                maximumCapacityMah = nil
            }

            return BatteryInfo(
                percentage: percentage,
                isCharging: isCharging,
                isFullyCharged: isFullyCharged,
                temperatureCelsius: temperature,
                cycleCount: healthMetrics?.cycleCount,
                maximumCapacityPercent: maximumCapacityPercent,
                maximumCapacityMah: maximumCapacityMah,
                designCapacityMah: designCapacityMah,
                conditionDescription: healthMetrics?.healthDescription
            )
        }

        return nil
    }
    
    // MARK: - Temperature & Health Reading via IOKit
    
    /// Reads battery temperature directly from the AppleSmartBattery IOKit service.
    ///
    /// The temperature is reported in decikelvin (1/10 of a Kelvin) by the SMC,
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
    
    /// Raw health metrics fetched from the AppleSmartBattery service.
    private struct BatteryHealthMetrics {
        let cycleCount: Int?
        /// Raw maximum capacity in mAh (AppleRawMaxCapacity), not the percentage-based MaxCapacity.
        let rawMaxCapacity: Int?
        let designCapacity: Int?
        let healthDescription: String?
    }
    
    /// Reads long-term battery health metrics such as cycle count and design capacity.
    ///
    /// These values change infrequently, so we read them opportunistically alongside
    /// the regular battery status. All fields are optional to keep the app resilient
    /// across macOS versions and hardware that may not expose every key.
    private static func readBatteryHealthMetrics() -> BatteryHealthMetrics? {
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
        
        var propertiesRef: Unmanaged<CFMutableDictionary>?
        let propertiesResult = IORegistryEntryCreateCFProperties(
            service,
            &propertiesRef,
            kCFAllocatorDefault,
            0
        )
        
        guard propertiesResult == KERN_SUCCESS,
              let properties = propertiesRef?.takeRetainedValue() as? [String: Any]
        else {
            return nil
        }
        
        let cycleCount = properties["CycleCount"] as? Int
        // Use AppleRawMaxCapacity (mAh) instead of MaxCapacity which may already be a percentage.
        let rawMaxCapacity = properties["AppleRawMaxCapacity"] as? Int
        let designCapacity = properties["DesignCapacity"] as? Int
        let healthDescription = properties["BatteryHealth"] as? String
        
        return BatteryHealthMetrics(
            cycleCount: cycleCount,
            rawMaxCapacity: rawMaxCapacity,
            designCapacity: designCapacity,
            healthDescription: healthDescription
        )
    }
}
