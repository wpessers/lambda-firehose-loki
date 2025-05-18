import * as esbuild from "esbuild";

await esbuild.build({
  entryPoints: ["src/helloWorldLambda.ts"],
  platform: "node",
  bundle: true,
  outdir: "dist/lambdas",
});
