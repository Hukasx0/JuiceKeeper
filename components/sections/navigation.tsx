import Image from "next/image";
import Link from "next/link";
import { Button } from "@/components/ui/button";
import { ModeToggle } from "@/components/ui/mode-toggle";

export function Navigation() {
  return (
    <nav className="sticky top-0 z-50 w-full border-b bg-background/95 backdrop-blur supports-[backdrop-filter]:bg-background/60">
      <div className="container mx-auto flex h-16 items-center justify-between px-4 sm:px-6 lg:px-8">
        <div className="flex items-center gap-3">
          <Image
            src="/logo.png"
            alt="JuiceKeeper Logo"
            width={32}
            height={32}
            className="rounded"
          />
          <span className="text-xl font-semibold">JuiceKeeper</span>
        </div>
        <div className="flex items-center gap-6">
          <ModeToggle />
          <Button asChild variant="default" size="sm">
            <Link
              href="https://github.com/Hukasx0/juiceKeeper"
              target="_blank"
              rel="noopener noreferrer"
            >
              Get Started
            </Link>
          </Button>
        </div>
      </div>
    </nav>
  );
}
