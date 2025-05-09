import * as esbuild from 'esbuild'

await esbuild.build({
  entryPoints: ['app.js'],
  platform: 'node',
  bundle: true,
  outfile: 'out.js',
})