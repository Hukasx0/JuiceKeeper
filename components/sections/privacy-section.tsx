import { Shield, CheckCircle2 } from "lucide-react";

export function PrivacySection() {
  return (
    <section className="container mx-auto px-4 py-20 sm:px-6 lg:px-8">
      <div className="mx-auto max-w-4xl">
        <div className="rounded-lg border bg-card p-12 text-center">
          <Shield className="mx-auto mb-6 h-12 w-12 text-primary" />
          <h2 className="mb-4 text-3xl font-bold">Privacy & Security</h2>
          <div className="mx-auto grid max-w-2xl gap-6 text-left sm:grid-cols-2">
            <div className="flex items-start gap-3">
              <CheckCircle2 className="mt-0.5 h-5 w-5 shrink-0 text-primary" />
              <div>
                <h3 className="text-lg font-semibold">Local Only</h3>
                <p className="text-sm text-muted-foreground">All data stays on your Mac</p>
              </div>
            </div>
            <div className="flex items-start gap-3">
              <CheckCircle2 className="mt-0.5 h-5 w-5 shrink-0 text-primary" />
              <div>
                <h3 className="text-lg font-semibold">No Network Access</h3>
                <p className="text-sm text-muted-foreground">JuiceKeeper never connects to the internet</p>
              </div>
            </div>
            <div className="flex items-start gap-3">
              <CheckCircle2 className="mt-0.5 h-5 w-5 shrink-0 text-primary" />
              <div>
                <h3 className="text-lg font-semibold">No Special Permissions</h3>
                <p className="text-sm text-muted-foreground">Uses standard IOKit APIs</p>
              </div>
            </div>
            <div className="flex items-start gap-3">
              <CheckCircle2 className="mt-0.5 h-5 w-5 shrink-0 text-primary" />
              <div>
                <h3 className="text-lg font-semibold">Settings Persistence</h3>
                <p className="text-sm text-muted-foreground">Preferences stored in UserDefaults</p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
