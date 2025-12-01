import type { Metadata } from "next";
import { Inter } from "next/font/google";
import "./globals.css";
import { ThemeProvider } from "next-themes";

const inter = Inter({
  subsets: ["latin"],
  variable: "--font-inter",
  display: "swap",
});

export const metadata: Metadata = {
  title: "JuiceKeeper - Battery Health Management for macOS",
  description: "A lightweight macOS menu bar application that monitors your MacBook's battery level and temperature, alerting you when charging reaches your configured threshold to preserve battery capacity.",
  keywords: ["macOS", "battery", "battery health", "MacBook", "menu bar", "battery monitoring", "temperature monitoring"],
  authors: [{ name: "Hubert Kasperek" }],
  icons: {
    icon: [
      { url: "/JuiceKeeper/favicon.png", sizes: "32x32", type: "image/png" },
      { url: "/JuiceKeeper/icon-192.png", sizes: "192x192", type: "image/png" },
      { url: "/JuiceKeeper/icon-512.png", sizes: "512x512", type: "image/png" },
    ],
    apple: [
      { url: "/JuiceKeeper/apple-touch-icon.png", sizes: "512x512", type: "image/png" },
    ],
  },
  openGraph: {
    title: "JuiceKeeper - Battery Health Management for macOS",
    description: "Monitor your MacBook's battery and preserve its health with smart charging alerts.",
    type: "website",
  },
  twitter: {
    card: "summary_large_image",
    title: "JuiceKeeper - Battery Health Management for macOS",
    description: "Monitor your MacBook's battery and preserve its health with smart charging alerts.",
  },
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en" className="scroll-smooth" suppressHydrationWarning>
      <body
        className={`${inter.variable} font-sans antialiased`}
      >
        <ThemeProvider
            attribute="class"
            defaultTheme="system"
            enableSystem
            disableTransitionOnChange
          >
            {children}
        </ThemeProvider>
      </body>
    </html>
  );
}
