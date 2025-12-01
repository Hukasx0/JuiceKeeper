import { CheckCircle2 } from "lucide-react";

interface FeatureCardProps {
  icon: React.ReactNode;
  title: string;
  features: string[];
}

export function FeatureCard({ icon, title, features }: FeatureCardProps) {
  return (
    <div className="group rounded-lg border bg-card p-6 transition-all hover:shadow-lg">
      <div className="mb-4 flex h-12 w-12 items-center justify-center rounded-lg bg-primary/10 text-primary transition-colors group-hover:bg-primary/20">
        {icon}
      </div>
      <h3 className="mb-4 text-xl font-semibold">{title}</h3>
      <ul className="space-y-2">
        {features.map((feature, index) => (
          <li key={index} className="flex items-start gap-2 text-sm text-muted-foreground">
            <CheckCircle2 className="mt-0.5 h-4 w-4 shrink-0 text-primary" />
            <span>{feature}</span>
          </li>
        ))}
      </ul>
    </div>
  );
}
