import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  output: "export",
  basePath: "/JuiceKeeper",
  assetPrefix: "/JuiceKeeper",
  images: {
    unoptimized: true,
  },
  trailingSlash: true,
};

export default nextConfig;
