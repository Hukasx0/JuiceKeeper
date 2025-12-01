import { StatusColorCard } from "./status-color-card";

export function StatusColorsSection() {
  return (
    <section className="container mx-auto px-4 py-20 sm:px-6 lg:px-8">
      <div className="mx-auto max-w-4xl">
        <div className="mb-12 text-center">
          <h2 className="mb-4 text-3xl font-bold tracking-tight sm:text-4xl">
            Menu Bar Status Colors
          </h2>
          <p className="text-lg text-muted-foreground">
            Understand what each color means
          </p>
        </div>

        <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
          <StatusColorCard
            color="bg-white"
            colorName="White"
            description="Normal usage (above 30%, on battery)"
          />
          <StatusColorCard
            color="bg-orange-500"
            colorName="Orange"
            description="Low battery (30% and below)"
          />
          <StatusColorCard
            color="bg-blue-500"
            colorName="Blue"
            description="Charging"
          />
          <StatusColorCard
            color="bg-green-500"
            colorName="Green"
            description="Fully charged"
          />
          <StatusColorCard
            color="bg-red-500"
            colorName="Red"
            description="Battery overheating"
            className="sm:col-span-2 lg:col-span-1"
          />
        </div>
      </div>
    </section>
  );
}
