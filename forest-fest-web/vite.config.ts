import { defineConfig, loadEnv, type Plugin } from 'vite'
import react from '@vitejs/plugin-react'
import { fetchFestivalWeather } from './shared/weather'

function weatherDevApi(): Plugin {
  return {
    name: 'weather-dev-api',
    configureServer(server) {
      server.middlewares.use('/api/weather', async (_req, res) => {
        const env = loadEnv(server.config.mode, server.config.root ?? process.cwd(), '')
        const apiKey = env.OPENWEATHER_API_KEY ?? process.env.OPENWEATHER_API_KEY

        try {
          const data = await fetchFestivalWeather(apiKey ?? '')
          res.statusCode = 200
          res.setHeader('Content-Type', 'application/json')
          res.end(JSON.stringify(data))
        } catch (error) {
          const message = error instanceof Error ? error.message : 'Failed to fetch weather'
          res.statusCode = message.includes('not configured') ? 500 : 502
          res.setHeader('Content-Type', 'application/json')
          res.end(JSON.stringify({ error: message }))
        }
      })
    },
  }
}

export default defineConfig({
  plugins: [react(), weatherDevApi()],
})
