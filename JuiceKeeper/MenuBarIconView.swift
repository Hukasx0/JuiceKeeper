import SwiftUI

struct MenuBarIconView: View {
    @EnvironmentObject var settings: AppSettings
    @EnvironmentObject var monitor: BatteryMonitor

    var body: some View {
        let level = monitor.currentPercentage ?? 0
        let symbolName = symbolName(for: level)
        let color = color(for: level)

        Image(systemName: symbolName)
            .symbolRenderingMode(.palette)
            .foregroundStyle(color, color)
            .help(tooltipText(for: level))
    }

    private func symbolName(for level: Int) -> String {
        let bucket: Int
        switch level {
        case ..<20:
            bucket = 25
        case 20..<50:
            bucket = 50
        case 50..<80:
            bucket = 75
        default:
            bucket = 100
        }

        return "battery.\(bucket)"
    }

    private func color(for level: Int) -> Color {
        if level <= 30 {
            return .orange
        }

        if monitor.isFullyCharged {
            return .green
        }

        if monitor.isCharging {
            return .blue
        }

        return .white
    }

    private func tooltipText(for level: Int) -> String {
        guard level > 0 else {
            return "JuiceKeeper – reading battery status..."
        }

        if monitor.isFullyCharged {
            return "Battery: \(level)% (fully charged)"
        } else if monitor.isCharging {
            return "Battery: \(level)% (charging)"
        } else {
            return "Battery: \(level)% (on battery power)"
        }
    }
}
