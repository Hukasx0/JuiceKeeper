import { CheckCircle2 } from "lucide-react";
import { Kbd, KbdGroup } from "@/components/ui/kbd";

export function RequirementsSection() {
  return (
    <section className="container mx-auto px-4 py-20 sm:px-6 lg:px-8">
      <div className="mx-auto max-w-4xl">
        <div className="grid gap-12 md:grid-cols-2">
          <div className="rounded-lg border bg-card p-8">
            <h3 className="mb-4 text-2xl font-bold">Requirements</h3>
            <ul className="space-y-3 text-muted-foreground">
              <li className="flex items-start gap-3">
                <CheckCircle2 className="mt-0.5 h-5 w-5 shrink-0 text-primary" />
                <span>macOS 15 (Sequoia) or newer</span>
              </li>
              <li className="flex items-start gap-3">
                <CheckCircle2 className="mt-0.5 h-5 w-5 shrink-0 text-primary" />
                <span>Mac with internal battery (MacBook Air, MacBook Pro, etc.)</span>
              </li>
            </ul>
          </div>

          <div className="rounded-lg border bg-card p-8">
            <h3 className="mb-4 text-2xl font-bold">Getting Started</h3>
            <ol className="space-y-3 text-muted-foreground">
              <li className="flex items-start gap-3">
                <span className="flex h-6 w-6 shrink-0 items-center justify-center rounded-full bg-primary text-xs font-semibold text-primary-foreground">
                  1
                </span>
                <span>Clone the repository or download the source code</span>
              </li>
              <li className="flex items-start gap-3">
                <span className="flex h-6 w-6 shrink-0 items-center justify-center rounded-full bg-primary text-xs font-semibold text-primary-foreground">
                  2
                </span>
                <span>Open JuiceKeeper.xcodeproj in Xcode</span>
              </li>
              <li className="flex items-start gap-3">
                <span className="flex h-6 w-6 shrink-0 items-center justify-center rounded-full bg-primary text-xs font-semibold text-primary-foreground">
                  3
                </span>
                <span>
                  Build and run (
                  <KbdGroup>
                    <Kbd>⌘</Kbd>
                    <Kbd>R</Kbd>
                  </KbdGroup>
                  )
                </span>
              </li>
              <li className="flex items-start gap-3">
                <span className="flex h-6 w-6 shrink-0 items-center justify-center rounded-full bg-primary text-xs font-semibold text-primary-foreground">
                  4
                </span>
                <span>JuiceKeeper appears as a battery icon in your menu bar</span>
              </li>
            </ol>
          </div>
        </div>
      </div>
    </section>
  );
}
