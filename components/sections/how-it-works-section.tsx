import { HowItWorksItem } from "./how-it-works-item";

export function HowItWorksSection() {
  return (
    <section className="container mx-auto px-4 py-20 sm:px-6 lg:px-8">
      <div className="mx-auto max-w-4xl">
        <div className="mb-16 text-center">
          <h2 className="mb-4 text-3xl font-bold tracking-tight sm:text-4xl">
            How It Works
          </h2>
          <p className="text-lg text-muted-foreground">
            Simple, intelligent battery management
          </p>
        </div>

        <div className="space-y-12">
          <HowItWorksItem
            number="1"
            title="Charge Threshold"
            description="JuiceKeeper polls your battery level at regular intervals. When the charge crosses your threshold (e.g., 79% → 80%), it fires a single notification reminding you to unplug. A small hysteresis prevents repeated alerts around the same level."
          />

          <HowItWorksItem
            number="2"
            title="Calibration Mode"
            description="For periodic battery calibration, enable 'Charge to 100%' to temporarily override your threshold. Once the battery reaches 100%, JuiceKeeper sends a completion notification, automatically restores your previous threshold, and disables calibration mode."
          />

          <HowItWorksItem
            number="3"
            title="Reminder Notifications"
            description="Enable reminder notifications to receive periodic alerts when conditions persist. Charge reminders continue while still charging above threshold, and temperature reminders continue until temperature drops. Configure the interval (1-60 minutes) to suit your workflow."
          />

          <HowItWorksItem
            number="4"
            title="Temperature Monitoring"
            description="Battery temperature is read directly from the AppleSmartBattery IOKit service — no kernel extensions, no drivers, no elevated privileges. When temperature exceeds your threshold, you'll receive a warning notification and the menu bar icon turns red."
          />

          <HowItWorksItem
            number="5"
            title="Battery Health"
            description="JuiceKeeper reads battery health metrics from the AppleSmartBattery IOKit service using standard macOS APIs. Track cycle count, maximum capacity (calculated as AppleRawMaxCapacity / DesignCapacity × 100%), and condition status. All values are refreshed alongside regular battery polling."
          />

          <HowItWorksItem
            number="6"
            title="Keep Awake Feature"
            description="If enabled, JuiceKeeper prevents idle system sleep while charging until the threshold is reached. Once your battery reaches the configured threshold, the sleep prevention is automatically released. This ensures alerts fire even during long charging sessions with the display off."
          />
        </div>
      </div>
    </section>
  );
}
