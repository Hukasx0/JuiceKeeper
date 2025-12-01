interface HowItWorksItemProps {
  number: string;
  title: string;
  description: string;
}

export function HowItWorksItem({ number, title, description }: HowItWorksItemProps) {
  return (
    <div className="flex gap-6">
      <div className="flex shrink-0 flex-col items-center">
        <div className="flex h-12 w-12 items-center justify-center rounded-full bg-primary text-lg font-bold text-primary-foreground">
          {number}
        </div>
        <div className="mt-2 h-full w-0.5 bg-border" />
      </div>
      <div className="flex-1 pb-8">
        <h3 className="mb-2 text-xl font-semibold">{title}</h3>
        <p className="text-muted-foreground">{description}</p>
      </div>
    </div>
  );
}
