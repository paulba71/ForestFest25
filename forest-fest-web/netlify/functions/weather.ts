import type { Config } from '@netlify/functions'
import { fetchFestivalWeather } from '../../shared/weather'

export default async () => {
  try {
    const apiKey = process.env.OPENWEATHER_API_KEY
    const dayWeather = await fetchFestivalWeather(apiKey ?? '')
    return new Response(JSON.stringify(dayWeather), {
      headers: {
        'Content-Type': 'application/json',
        'Cache-Control': 'public, max-age=1800',
      },
    })
  } catch (error) {
    const message = error instanceof Error ? error.message : 'Failed to fetch weather'
    const status = message.includes('not configured') ? 500 : 502
    return new Response(JSON.stringify({ error: message }), {
      status,
      headers: { 'Content-Type': 'application/json' },
    })
  }
}

export const config: Config = {
  path: '/api/weather',
}
