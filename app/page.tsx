import { Navigation } from "@/components/sections/navigation";
import { HeroSection } from "@/components/sections/hero-section";
import { FeaturesSection } from "@/components/sections/features-section";
import { HowItWorksSection } from "@/components/sections/how-it-works-section";
import { RequirementsSection } from "@/components/sections/requirements-section";
import { PrivacySection } from "@/components/sections/privacy-section";
import { StatusColorsSection } from "@/components/sections/status-colors-section";
import { Footer } from "@/components/sections/footer";

export default function Home() {
  return (
    <div className="min-h-screen bg-gradient-to-b from-background via-background to-muted/20">
      <Navigation />
      <main id="main-content" className="flex flex-col">
        <HeroSection />
        <FeaturesSection />
        <HowItWorksSection />
        <RequirementsSection />
        <PrivacySection />
        <StatusColorsSection />
      </main>
      <Footer />
    </div>
  );
}
