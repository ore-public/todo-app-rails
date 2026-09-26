import path from 'path'
import fs from 'fs'

const config = {
  bundle: true,
  minify: true,
  sourcemap: 'external',
  entrypoints: ['app/javascript/application.js'],
  outdir: path.join(process.cwd(), 'app/assets/builds')
}

const build = async (config) => {
  const result = await Bun.build(config)

  if (result.success) return

  if (process.argv.includes('--watch')) {
    console.error('Build failed')
    for (const message of result.logs) {
      console.error(message)
    }
  } else {
    throw new AggregateError(result.logs, 'Build failed')
  }
}

await build(config)

if (process.argv.includes('--watch')) {
  fs.watch(path.join(process.cwd(), 'app/javascript'), { recursive: true }, (eventType, filename) => {
    if (!filename?.endsWith('.js')) return

    console.log(`File changed: ${filename}. Rebuilding...`)
    build(config)
  })
} else {
  process.exit(0)
}
