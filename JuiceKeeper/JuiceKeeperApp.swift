import SwiftUI

@main
struct JuiceKeeperApp: App {
    @StateObject private var settings: AppSettings
    @StateObject private var batteryMonitor: BatteryMonitor

    init() {
        let appSettings = AppSettings()
        _settings = StateObject(wrappedValue: appSettings)
        _batteryMonitor = StateObject(wrappedValue: BatteryMonitor(settings: appSettings))

        NotificationManager.shared.requestAuthorizationIfNeeded()
    }

    var body: some Scene {
        MenuBarExtra {
            ContentView()
                .environmentObject(settings)
                .environmentObject(batteryMonitor)
        } label: {
            MenuBarIconView()
                .environmentObject(settings)
                .environmentObject(batteryMonitor)
        }
        .menuBarExtraStyle(.window)
    }
}
