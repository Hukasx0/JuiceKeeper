import Foundation
import UserNotifications

/// Manages local user notifications for JuiceKeeper.
final class NotificationManager: NSObject, UNUserNotificationCenterDelegate {

    static let shared = NotificationManager()

    private override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }

    /// Ask for permission to show alerts and play sounds if not decided yet.
    func requestAuthorizationIfNeeded() {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { settings in
            guard settings.authorizationStatus == .notDetermined else { return }

            center.requestAuthorization(options: [.alert, .sound]) { _, _ in }
        }
    }

    /// Fire an immediate battery-level notification.
    func notifyBatteryThresholdReached(level: Int, threshold: Int, soundEnabled: Bool) {
        let content = UNMutableNotificationContent()
        content.title = "Battery threshold reached"
        content.body = "Battery reached \(level)% (configured threshold: \(threshold)%). Unplug the charger to preserve battery health."

        if soundEnabled {
            content.sound = .default
        }

        let request = UNNotificationRequest(
            identifier: "battery-threshold-\(UUID().uuidString)",
            content: content,
            trigger: nil
        )

        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    /// Fire an immediate battery overheating notification.
    func notifyBatteryOverheating(temperature: Double, threshold: Double, soundEnabled: Bool) {
        let content = UNMutableNotificationContent()
        content.title = "⚠️ Battery overheating"
        content.body = String(
            format: "Battery temperature is %.1f°C (threshold: %.0f°C). Consider reducing workload or improving ventilation.",
            temperature,
            threshold
        )

        if soundEnabled {
            content.sound = .default
        }

        let request = UNNotificationRequest(
            identifier: "battery-overheat-\(UUID().uuidString)",
            content: content,
            trigger: nil
        )

        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }
}
