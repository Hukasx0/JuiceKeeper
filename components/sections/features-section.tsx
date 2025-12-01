import {
  Battery,
  Thermometer,
  Bell,
  Settings,
  BarChart3,
  Menu,
} from "lucide-react";
import { FeatureCard } from "./feature-card";

export function FeaturesSection() {
  return (
    <section id="features" className="container mx-auto px-4 py-20 sm:px-6 lg:px-8">
      <div className="mx-auto max-w-6xl">
        <div className="mb-16 text-center">
          <h2 className="mb-4 text-3xl font-bold tracking-tight sm:text-4xl">
            Powerful Features
          </h2>
          <p className="text-lg text-muted-foreground">
            Everything you need to maintain your battery&apos;s health
          </p>
        </div>

        <div className="grid gap-8 md:grid-cols-2 lg:grid-cols-3">
          <FeatureCard
            icon={<Battery className="h-6 w-6" />}
            title="Battery Level Monitoring"
            features={[
              "Smart charging alerts at configurable thresholds",
              "One alert per charge cycle (no spam)",
              "Calibration mode for periodic 100% charges",
              "Reminder notifications at custom intervals",
            ]}
          />

          <FeatureCard
            icon={<Thermometer className="h-6 w-6" />}
            title="Temperature Monitoring"
            features={[
              "Real-time temperature tracking via IOKit",
              "Overheat alerts at configurable thresholds",
              "Persistent reminders while battery remains hot",
              "Visual warning with red icon when overheating",
            ]}
          />

          <FeatureCard
            icon={<BarChart3 className="h-6 w-6" />}
            title="Battery Health"
            features={[
              "Cycle count tracking",
              "Maximum capacity percentage",
              "Condition status (Good, Fair, Service Recommended)",
              "Color-coded health indicator",
            ]}
          />

          <FeatureCard
            icon={<Menu className="h-6 w-6" />}
            title="Menu Bar Integration"
            features={[
              "Lives in your menu bar (no Dock icon)",
              "Color-coded status indicators",
              "Minimal, unobtrusive design",
            ]}
          />

          <FeatureCard
            icon={<Bell className="h-6 w-6" />}
            title="Notification Options"
            features={[
              "Sound alerts (toggleable)",
              "Display wake before notifications",
              "Keep Mac awake while charging",
              "Customizable reminder intervals",
            ]}
          />

          <FeatureCard
            icon={<Settings className="h-6 w-6" />}
            title="Customization"
            features={[
              "Polling interval: 1-600 seconds",
              "Temperature threshold: 30-50°C",
              "Reminder interval: 1-60 minutes",
              "Flexible threshold settings (80%, 85%, 90%, 95%, or custom)",
            ]}
          />
        </div>
      </div>
    </section>
  );
}
