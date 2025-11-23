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
            }

            Toggle("Play notification sound", isOn: $settings.isSoundEnabled)

            Toggle("Wake display when threshold is reached", isOn: $settings.wakeDisplayOnAlert)

            Toggle(isOn: $settings.keepAwakeWhileCharging) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Keep Mac awake while charging")
                    Text("until threshold is reached")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
            }
            .font(.footnote)
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
        settings.alertThreshold = max(0, min(100, value))
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
