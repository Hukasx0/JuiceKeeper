import Foundation
import IOKit.pwr_mgt

enum DisplayWakeHelper {

    /// Attempt to wake the display by simulating local user activity.
    ///
    /// This only has an effect when the system is running but the display
    /// has gone to sleep / dimmed. It is a no-op if the display is already on.
    static func wakeDisplayIfPossible() {
        let reason = "JuiceKeeper battery threshold reached" as CFString
        var assertionID: IOPMAssertionID = 0

        let result = IOPMAssertionDeclareUserActivity(
            reason,
            kIOPMUserActiveLocal,
            &assertionID
        )

        if result == kIOReturnSuccess {
            IOPMAssertionRelease(assertionID)
        }
    }
}
