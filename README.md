## JuiceKeeper

JuiceKeeper is a minimal macOS menu bar app that helps you protect your MacBook’s battery health by notifying you when the battery reaches a configurable charge level (e.g. 80%, 85%, 90%, 95% or a custom value).

The app has **no regular window or Dock icon** – it lives only in the menu bar as a battery icon with a color that reflects the current state.

- **White**: normal battery usage above 30%, on battery power  
- **Orange**: low battery (30% and below)  
- **Blue**: charging but not yet fully charged  
- **Green**: fully charged  

When the configured threshold is reached while charging, JuiceKeeper can:

- show a system notification,
- play a notification sound,
- (optionally) wake the display,
- (optionally) keep the Mac awake while charging until the threshold is reached.

---

## Features

- **Menu bar only**: no Dock icon, no regular window.
- **Configurable battery threshold**:
  - Presets: 80%, 85%, 90%, 95%.
  - Custom value from 1–100%.
- **Check interval**:
  - Polling interval configurable from 1 to 600 seconds. 
  - Default: 15 seconds.
- **Notification options**:
  - Enable/disable notification sound.
  - Wake the display when the threshold is reached.
  - Optionally keep the Mac awake while charging until the threshold is reached
- **Battery-aware icon**: battery SF Symbol with colors reflecting current state.

---

## Requirements

- macOS 15 (or newer)  
- A Mac with an internal battery (MacBook, etc.)

---

## Running the app

1. Open the Xcode project `JuiceKeeper.xcodeproj`.
2. Select the `JuiceKeeper` target.
3. Build & run.
4. The app will appear in the macOS menu bar as a battery icon.

Click the icon to open the popover with:

- current battery status,
- alert threshold settings (presets + custom),
- check interval,
- notification sound toggle,
- display wake toggle,
- “keep Mac awake while charging” toggle,
- quit button.

---

## Notification settings (important)

For JuiceKeeper to work correctly and reliably show alerts, you need to enable notifications for the app in macOS Settings:

1. Open **System Settings**.
2. Go to **Notifications**.
3. Select **JuiceKeeper** from the list.

Then set:

- **Allow notifications**: **enabled** (ON).  
- **Alert style**: **Alerts (recommended)** or **Banners**.  
  - **Recommended**: Alerts (they stay visible until you dismiss them).  
  - Banners are also OK if you prefer a more lightweight experience.
- **Show notifications on Lock Screen**: **enabled** (ON).  
- **Show in Notification Center**: **enabled** (ON).  
- **Play sound for notifications**: **enabled** (ON)  
  - (You can disable the sound later both in system settings and in JuiceKeeper’s own settings.)

Without these permissions JuiceKeeper will still run in the menu bar, but you will not see or hear alerts when the battery reaches the configured threshold.

---

## Battery behavior

- The app periodically reads the current battery level and charging state.
- When the level crosses your configured threshold upwards (e.g. from 79% to 80%+), **one alert** is fired for that charging cycle.
- A small hysteresis is used internally so you are not spammed with multiple notifications around the same percentage.
- If you enable:
  - **Wake display when threshold is reached** – the app will ask macOS to wake the display so the notification is visible.
  - **Keep Mac awake while charging until threshold is reached** – the app will prevent idle system sleep while charging and below the threshold (the display can still sleep), so timers keep running and the alert can be delivered even after long idle periods.

---

## Privacy and safety

- JuiceKeeper only reads battery information from the system.
- No data is sent over the network.
- All settings are stored locally using `UserDefaults`.
