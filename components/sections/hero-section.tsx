import Image from "next/image";
import Link from "next/link";
import { Button } from "@/components/ui/button";
import { Zap } from "lucide-react";

export function HeroSection() {
  return (
    <section className="container mx-auto px-4 py-20 sm:px-6 lg:px-8 lg:py-32">
      <div className="mx-auto max-w-4xl text-center">
        <div className="mb-8 flex justify-center">
          <Image
            src="/logo.png"
            alt="JuiceKeeper Logo"
            width={128}
            height={128}
            className="rounded-2xl"
            priority
          />
        </div>
        <h1 className="mb-6 text-4xl font-bold tracking-tight sm:text-5xl lg:text-6xl">
          Keep Your Battery
          <span className="bg-gradient-to-r from-primary via-accent to-secondary bg-clip-text text-transparent">
            {" "}
            Healthy
          </span>
        </h1>
        <p className="mb-8 text-lg text-muted-foreground sm:text-xl lg:text-2xl">
          A lightweight macOS menu bar application that monitors your MacBook&apos;s battery
          level and temperature, alerting you when charging reaches your configured threshold
          to preserve battery capacity.
        </p>
        <div className="flex flex-col items-center justify-center gap-4 sm:flex-row">
          <Button asChild size="lg" className="w-full sm:w-auto">
            <Link
              href="https://github.com/Hukasx0/juiceKeeper"
              target="_blank"
              rel="noopener noreferrer"
            >
              View on GitHub
            </Link>
          </Button>
          <Button
            asChild
            variant="outline"
            size="lg"
            className="w-full sm:w-auto hover:bg-muted hover:text-foreground dark:hover:bg-muted/50 dark:hover:text-foreground transition-colors"
          >
            <Link href="#features" className="flex items-center gap-2">
              Learn More
              <Zap className="h-4 w-4" />
            </Link>
          </Button>
        </div>
        <p className="mt-8 text-sm text-muted-foreground">
          No Dock icon. No window clutter. Just a tiny battery icon in your menu bar.
        </p>
      </div>
    </section>
  );
}
