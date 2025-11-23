import Foundation
import IOKit.pwr_mgt

/// Controls a single system-wide idle sleep prevention assertion while the Mac is charging.
///
/// We intentionally use `kIOPMAssertionTypePreventUserIdleSystemSleep` so that:
/// - the Mac will not go into full idle sleep while charging (our timers keep running),
/// - the display is still allowed to sleep; we can gently wake it when needed.
final class ChargingSleepController {

    static let shared = ChargingSleepController()

    private var assertionID: IOPMAssertionID = 0
    private var isActive: Bool = false

    private init() {}

    /// Updates the assertion based on the current app settings and battery state.
    ///
    /// - Parameters:
    ///   - enabled: whether the user enabled "keep awake while charging".
    ///   - isCharging: whether the Mac is currently charging.
    ///   - belowThreshold: whether the battery is still below the alert threshold.
    func update(enabled: Bool, isCharging: Bool, belowThreshold: Bool) {
        let shouldHoldAssertion = enabled && isCharging && belowThreshold

        if shouldHoldAssertion {
            activateIfNeeded()
        } else {
            deactivateIfNeeded()
        }
    }

    /// Explicitly releases the assertion, if any.
    func deactivateIfNeeded() {
        guard isActive else { return }
        IOPMAssertionRelease(assertionID)
        assertionID = 0
        isActive = false
    }

    private func activateIfNeeded() {
        guard !isActive else { return }

        var newAssertionID: IOPMAssertionID = 0
        let reason = "JuiceKeeper – keep Mac awake while charging until battery threshold is reached" as CFString

        let result = IOPMAssertionCreateWithName(
            kIOPMAssertionTypePreventUserIdleSystemSleep as CFString,
            IOPMAssertionLevel(kIOPMAssertionLevelOn),
            reason,
            &newAssertionID
        )

        if result == kIOReturnSuccess {
            assertionID = newAssertionID
            isActive = true
        }
    }
}
