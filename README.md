# 🔋 JuiceKeeper

**A lightweight macOS menu bar application for battery health management.**

JuiceKeeper monitors your MacBook's battery level and temperature, alerting you when charging reaches your configured threshold (e.g., 80%) so you can unplug and preserve battery capacity. It also warns you when your battery is overheating to help prevent thermal damage.

No Dock icon. No window clutter. Just a tiny battery icon in your menu bar, keeping your battery healthy.

---

## ✨ Features

### Battery Level Monitoring
- **Smart charging alerts** — Get notified when your battery reaches a configurable threshold (80%, 85%, 90%, 95%, or custom)
- **One alert per charge cycle** — No notification spam; alerts reset when battery drops below threshold
- **Calibration mode** — One-time charge to 100% for battery calibration; automatically reverts to your previous threshold
- **Reminder notifications** — Repeat reminders at configurable intervals while still charging above threshold

### 🌡️ Temperature Monitoring
- **Real-time temperature tracking** — Monitor battery temperature via IOKit (no kernel extensions required)
- **Overheat alerts** — Receive notifications when battery temperature exceeds your configured threshold (default: 45°C)
- **Persistent overheat reminders** — Periodic reminders while battery remains hot (uses same interval as charge reminders)
- **Visual warning** — Battery icon turns red when overheating
- **Toggle on/off** — Enable or disable temperature alerts as needed

### 🩺 Battery Health
- **Cycle count** — Track how many charge cycles your battery has completed
- **Maximum capacity** — See your battery's current maximum capacity as a percentage of its original design capacity (just like macOS Battery settings)
- **Condition status** — View the system-reported battery condition (e.g., "Good", "Fair", "Service Recommended")
- **Color-coded health indicator** — Green (≥90%), orange (80–89%), red (<80%)
- **Tooltip details** — Hover over the menu bar icon for a quick health summary

### Menu Bar Integration
- **Lives in your menu bar** — No Dock icon, no windows, just a subtle battery indicator
- **Color-coded status:**
  - ⚪ **White** — Normal usage (above 30%, on battery)
  - 🟠 **Orange** — Low battery (30% and below)
  - 🔵 **Blue** — Charging
  - 🟢 **Green** — Fully charged
  - 🔴 **Red** — Battery overheating

### Notification Options
- **Sound alerts** — Enable or disable notification sounds
- **Display wake** — Wake your display before any notification (threshold, temperature, reminders, calibration)
- **Keep awake while charging** — Prevent system sleep until threshold is reached

### Customization
- **Polling interval** — Check battery every 1–600 seconds (default: 15s)
- **Temperature threshold** — Set your overheat warning between 30–50°C
- **Reminder interval** — Set how often to repeat notifications for both charge and temperature alerts (1–60 minutes, default: 5 min)

---

## 📋 Requirements

- **macOS 15** (Sequoia) or newer
- A Mac with an internal battery (MacBook Air, MacBook Pro, etc.)

---

## 🚀 Getting Started

1. Clone the repository or download the source code
2. Open `JuiceKeeper.xcodeproj` in Xcode
3. Build and run (⌘R)
4. JuiceKeeper appears as a battery icon in your menu bar

Click the icon to access:
- Current battery status and temperature
- Battery health info (cycle count, maximum capacity, condition)
- Threshold and temperature settings
- Notification preferences
- Quit button

---

## 🔔 Notification Setup

For JuiceKeeper to deliver alerts reliably, configure notifications in **System Settings**:

1. Open **System Settings** → **Notifications**
2. Find **JuiceKeeper** in the list
3. Enable:
   - ✅ Allow notifications
   - ✅ Alerts or Banners (Alerts recommended — they stay visible)
   - ✅ Show on Lock Screen
   - ✅ Show in Notification Center
   - ✅ Play sound (optional)

---

## 🔋 How It Works

### Charge Threshold
JuiceKeeper polls your battery level at regular intervals. When the charge crosses your threshold (e.g., 79% → 80%), it fires a single notification reminding you to unplug. A small hysteresis prevents repeated alerts around the same level.

### Calibration Mode
For periodic battery calibration, enable "Charge to 100%" to temporarily override your threshold. Once the battery reaches 100%, JuiceKeeper:
1. Sends a completion notification
2. Automatically restores your previous threshold
3. Disables calibration mode

This is a one-time action that doesn't persist across app restarts.

### Reminder Notifications
Enable reminder notifications to receive periodic alerts when conditions persist:
- **Charge reminders** — If you forget to unplug after reaching the threshold, reminders continue while still charging
- **Temperature reminders** — If battery remains overheated, reminders continue until temperature drops

Configure the interval (1–60 minutes) to suit your workflow. One setting controls both reminder types. Reminders stop automatically when the triggering condition resolves.

### Temperature Monitoring
Battery temperature is read directly from the `AppleSmartBattery` IOKit service — no kernel extensions, no drivers, no elevated privileges. When temperature exceeds your threshold, you'll receive a warning notification and the menu bar icon turns red.

### Battery Health
JuiceKeeper reads battery health metrics from the `AppleSmartBattery` IOKit service using standard macOS APIs:
- **Cycle count** — Total charge cycles completed
- **Maximum capacity** — Calculated as `AppleRawMaxCapacity / DesignCapacity × 100%`, matching the value shown in macOS System Information
- **Condition** — The system-reported `BatteryHealth` string

These values are refreshed alongside regular battery polling (default: every 15 seconds). All fields are optional and gracefully hidden if unavailable on your hardware or macOS version.

### Keep Awake Feature
If enabled, JuiceKeeper prevents idle system sleep while charging **until the threshold is reached**. Once your battery reaches the configured threshold, the sleep prevention is automatically released. This ensures alerts fire even during long charging sessions with the display off. The display can still sleep normally.

> **Tip:** For best results with display-off charging, enable macOS's *"Prevent automatic sleeping on power adapter when the display is off"* option in System Settings → Battery.

---

## 🔒 Privacy & Security

- **Local only** — All data stays on your Mac
- **No network access** — JuiceKeeper never connects to the internet
- **No special permissions** — Uses standard IOKit APIs for battery info
- **Settings persistence** — Preferences stored in `UserDefaults`

---

## 📄 License

This project is open source under the MIT license. See [LICENSE](LICENSE) for details.

---

**Made by [Hubert Kasperek](https://github.com/Hukasx0)**
