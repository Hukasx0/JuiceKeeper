import SwiftUI
import AppKit

struct ContentView: View {
    @EnvironmentObject var settings: AppSettings
    @EnvironmentObject var monitor: BatteryMonitor

    @State private var customThresholdText: String = ""
    @State private var selectedThresholdOption: ThresholdOption = .preset(80)

    private enum ThresholdOption: Hashable, Identifiable {
        case preset(Int)
        case custom

        var id: String {
            switch self {
            case .preset(let value): return "preset-\(value)"
            case .custom: return "custom"
            }
        }

        var label: String {
            switch self {
            case .preset(let value): return "\(value)%"
            case .custom: return "Custom"
            }
        }

        static let all: [ThresholdOption] = [
            .preset(80),
            .preset(85),
            .preset(90),
            .preset(95),
            .custom
        ]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            statusSection
            Divider()
            settingsSection
            Divider()
            footerSection
        }
        .padding(16)
        .frame(width: 320)
    }

    private var statusSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Status")
                .font(.headline)

            Text(statusText)
                .font(.body)

            Text("Alert threshold: \(settings.alertThreshold)%")
                .font(.caption)
                .foregroundColor(.secondary)

            temperatureStatusView
        }
    }
    
    @ViewBuilder
    private var temperatureStatusView: some View {
        if let temp = monitor.currentTemperature {
            HStack(spacing: 4) {
                if monitor.isOverheating {
                    Image(systemName: "thermometer.sun.fill")
                        .foregroundColor(.red)
                    Text(String(format: "Temperature: %.1f°C", temp))
                        .foregroundColor(.red)
                        .fontWeight(.medium)
                    Text("(overheating)")
                        .foregroundColor(.red)
                        .font(.caption)
                } else {
                    Image(systemName: "thermometer.medium")
                        .foregroundColor(.secondary)
                    Text(String(format: "Temperature: %.1f°C", temp))
                }
            }
            .font(.body)
        }
    }

    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Settings")
                .font(.headline)

            VStack(alignment: .leading, spacing: 8) {
                Text("Battery threshold")
                    .font(.subheadline)

                Picker("", selection: $selectedThresholdOption) {
                    ForEach(ThresholdOption.all) { option in
                        Text(option.label).tag(option)
                    }
                }
                .pickerStyle(.segmented)
                .onAppear {
                    syncSelectionFromSettings()
                }
                .onChange(of: settings.alertThreshold) {
                    syncSelectionFromSettings()
                }
                .onChange(of: selectedThresholdOption) { _, newValue in
                    switch newValue {
                    case .preset(let value):
                        settings.alertThreshold = value
                        customThresholdText = "\(value)"
                    case .custom:
                        if customThresholdText.isEmpty {
                            customThresholdText = "\(settings.alertThreshold)"
                        }
                    }
                }

                if case .custom = selectedThresholdOption {
                    HStack(spacing: 4) {
                        TextField("e.g. 92", text: $customThresholdText)
                            .frame(width: 60)
                            .multilineTextAlignment(.trailing)
                            .textFieldStyle(.roundedBorder)
                            .onSubmit(applyCustomThreshold)
                            .onChange(of: customThresholdText) {
                                applyCustomThreshold()
                            }
                        Text("%")
                    }
                    .font(.caption)
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Check interval")
                    .font(.subheadline)

                Stepper(
                    value: Binding(
                        get: { Int(settings.pollingIntervalSeconds) },
                        set: { settings.pollingIntervalSeconds = Double($0) }
                    ),
                    in: 1...600,
                    step: 1
                ) {
                    Text("Check every \(Int(settings.pollingIntervalSeconds)) seconds")
                }
                
                if settings.pollingIntervalSeconds < 5 {
                    Text("Intervals below 5 seconds may increase energy usage.")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
            }

            Toggle("Play notification sound", isOn: $settings.isSoundEnabled)

            Toggle(isOn: $settings.wakeDisplayOnAlert) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Wake display when threshold is reached")
                    Text("Works while Mac is awake (display-only sleep).")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
            }

            Toggle(isOn: $settings.keepAwakeWhileCharging) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Keep Mac awake while charging")
                    Text("until threshold is reached")
                    Text("(helps alerts fire during long idle charging).")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
            }
            .font(.footnote)
            
            Divider()
            
            temperatureSettingsSection
        }
    }
    
    private var temperatureSettingsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Temperature monitoring")
                .font(.subheadline)
            
            Toggle("Alert when battery overheats", isOn: $settings.isTemperatureAlertEnabled)
            
            if settings.isTemperatureAlertEnabled {
                HStack {
                    Text("Threshold:")
                    Stepper(
                        value: $settings.temperatureThresholdCelsius,
                        in: 30...50,
                        step: 1
                    ) {
                        Text(String(format: "%.0f°C", settings.temperatureThresholdCelsius))
                    }
                }
                .font(.caption)
                
                Text("Alert triggers when battery temperature exceeds this value.")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
        }
    }

    private var footerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("JuiceKeeper")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("by Hukasx0")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut(.escape, modifiers: [])
        }
    }

    private var statusText: String {
        guard let level = monitor.currentPercentage else {
            return "Reading battery status..."
        }

        if monitor.isFullyCharged {
            return "Battery: \(level)% (fully charged)"
        } else if monitor.isCharging {
            return "Battery: \(level)% (charging)"
        } else {
            return "Battery: \(level)% (on battery power)"
        }
    }

    private func applyCustomThreshold() {
        let trimmed = customThresholdText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let value = Int(trimmed) else { return }
        settings.alertThreshold = max(1, min(100, value))
    }

    private func syncSelectionFromSettings() {
        let current = settings.alertThreshold
        if let match = ThresholdOption.all.first(where: { option in
            if case .preset(let value) = option {
                return value == current
            }
            return false
        }) {
            selectedThresholdOption = match
        } else {
            selectedThresholdOption = .custom
            customThresholdText = "\(current)"
        }
    }
}

#Preview {
    let settings = AppSettings()
    let monitor = BatteryMonitor(settings: settings)
    return ContentView()
        .environmentObject(settings)
        .environmentObject(monitor)
}
