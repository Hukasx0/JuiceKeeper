interface StatusColorCardProps {
  color: string;
  colorName: string;
  description: string;
  className?: string;
}

export function StatusColorCard({
  color,
  colorName,
  description,
  className,
}: StatusColorCardProps) {
  return (
    <div className={`rounded-lg border bg-card p-4 ${className || ""}`}>
      <div className="mb-3 flex items-center gap-3">
        <div className={`h-6 w-6 rounded ${color} border`} />
        <span className="font-semibold">{colorName}</span>
      </div>
      <p className="text-sm text-muted-foreground">{description}</p>
    </div>
  );
}
