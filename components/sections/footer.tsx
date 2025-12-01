import Image from "next/image";
import Link from "next/link";

export function Footer() {
  return (
    <footer className="border-t bg-muted/30">
      <div className="container mx-auto px-4 py-12 sm:px-6 lg:px-8">
        <div className="mx-auto max-w-4xl">
          <div className="flex flex-col items-center justify-between gap-6 sm:flex-row">
            <div className="flex items-center gap-3">
              <Image
                src="/JuiceKeeper/logo.png"
                alt="JuiceKeeper Logo"
                width={32}
                height={32}
                className="rounded"
              />
              <div>
                <p className="font-semibold">JuiceKeeper</p>
                <p className="text-sm text-muted-foreground">
                  Made by{" "}
                  <Link
                    href="https://github.com/Hukasx0"
                    target="_blank"
                    rel="noopener noreferrer"
                    className="font-medium text-primary hover:underline"
                  >
                    Hubert Kasperek
                  </Link>
                </p>
              </div>
            </div>
            <div className="flex flex-col items-center gap-2 text-sm text-muted-foreground sm:items-end">
              <p>Open source under the MIT license</p>
              <Link
                href="https://github.com/Hukasx0/juiceKeeper"
                target="_blank"
                rel="noopener noreferrer"
                className="font-medium text-primary hover:underline"
              >
                View on GitHub
              </Link>
            </div>
          </div>
        </div>
      </div>
    </footer>
  );
}
