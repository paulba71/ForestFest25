import { useCallback, useEffect, useState } from 'react'
import type { DayWeather } from '../types'
import { PageLayout } from '../components/PageLayout'
import './WeatherPage.css'

interface WeatherApiResponse {
  festivalDays: DayWeather[]
  festivalForecastAvailable: boolean
  message: string | null
  current: {
    temp: number
    condition: string
    icon: string
    location: string
  } | null
  upcomingDays: DayWeather[]
}

export function WeatherPage() {
  const [weather, setWeather] = useState<WeatherApiResponse | null>(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)
  const [expandedDay, setExpandedDay] = useState<string | null>(null)

  const fetchWeather = useCallback(async () => {
    setLoading(true)
    setError(null)
    try {
      const res = await fetch('/api/weather')
      const data = await res.json()
      if (!res.ok) {
        throw new Error(data.error ?? 'Failed to fetch weather data')
      }
      setWeather(data)
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Unable to load weather forecast.')
    } finally {
      setLoading(false)
    }
  }, [])

  useEffect(() => {
    fetchWeather()
  }, [fetchWeather])

  const displayDays = weather?.festivalForecastAvailable
    ? weather.festivalDays
    : weather?.upcomingDays ?? []

  return (
    <PageLayout
      title="Weather Forecast"
      rightAction={
        <button
          type="button"
          className="weather-refresh"
          onClick={fetchWeather}
          disabled={loading}
          aria-label="Refresh weather"
        >
          ↻
        </button>
      }
    >
      {loading ? (
        <div className="weather-state">
          <div className="weather-spinner" />
          <p>Fetching weather data...</p>
        </div>
      ) : error ? (
        <div className="weather-state">
          <span className="weather-error-icon">⚠</span>
          <h2>Weather Unavailable</h2>
          <p>{error}</p>
          <button type="button" className="weather-retry" onClick={fetchWeather}>
            Try Again
          </button>
        </div>
      ) : weather ? (
        <div className="weather-content">
          <div className="weather-location">
            <h2>Emo Village, Co. Laois</h2>
            <p>Forest Fest 2026 — July 24–26</p>
          </div>

          {weather.current && (
            <section className="weather-section">
              <h3>Current Conditions</h3>
              <div className="weather-current-card">
                <span className="weather-card-icon">{weatherEmoji(weather.current.icon)}</span>
                <div>
                  <div className="weather-current-temp">{Math.round(weather.current.temp)}°C</div>
                  <div className="weather-card-condition">{weather.current.condition}</div>
                </div>
              </div>
            </section>
          )}

          {weather.message && (
            <p className="weather-notice">{weather.message}</p>
          )}

          <section className="weather-section">
            <h3>
              {weather.festivalForecastAvailable
                ? 'Festival Weekend Forecast'
                : '5-Day Forecast (near Emo)'}
            </h3>
            <div className="weather-cards">
              {displayDays.map((day) => (
                <div key={day.date} className="weather-card">
                  <div className="weather-card-day">{day.dayOfWeek}</div>
                  <div className="weather-card-icon">{weatherEmoji(day.icon)}</div>
                  <div className="weather-card-condition">{day.condition}</div>
                  {day.highTemp > 0 && (
                    <div className="weather-card-temps">
                      <span className="high">{Math.round(day.highTemp)}°</span>
                      <span className="low">{Math.round(day.lowTemp)}°</span>
                    </div>
                  )}
                  {day.hourlyForecast.length > 0 && (
                    <>
                      <button
                        type="button"
                        className="weather-expand-btn"
                        onClick={() => setExpandedDay(expandedDay === day.date ? null : day.date)}
                      >
                        {expandedDay === day.date ? 'Hide hourly' : 'Hourly'}
                      </button>
                      {expandedDay === day.date && (
                        <div className="weather-hourly">
                          {day.hourlyForecast.map((h) => (
                            <div key={h.time} className="weather-hour">
                              <span>{h.time}</span>
                              <span>{weatherEmoji(h.icon)}</span>
                              <span>{Math.round(h.temp)}°</span>
                            </div>
                          ))}
                        </div>
                      )}
                    </>
                  )}
                </div>
              ))}
            </div>
          </section>

          <section className="weather-section">
            <h3>Festival Weather Tips</h3>
            <ul className="weather-tips">
              {getWeatherTips(displayDays).map((tip) => (
                <li key={tip}>{tip}</li>
              ))}
            </ul>
          </section>
        </div>
      ) : null}
    </PageLayout>
  )
}

function weatherEmoji(icon: string): string {
  const map: Record<string, string> = {
    'sun.max.fill': '☀️',
    'cloud.sun.fill': '⛅',
    'cloud.fill': '☁️',
    'cloud.rain.fill': '🌧️',
    'cloud.drizzle.fill': '🌦️',
    'cloud.bolt.rain.fill': '⛈️',
    'cloud.fog.fill': '🌫️',
    snow: '❄️',
  }
  return map[icon] ?? '🌤️'
}

function getWeatherTips(weather: DayWeather[]): string[] {
  const tips: string[] = []
  if (weather.some((d) => d.condition.toLowerCase().includes('rain'))) {
    tips.push('Pack a rain jacket and wellies — rain is in the forecast near the festival site.')
  }
  if (weather.some((d) => d.highTemp > 20)) {
    tips.push('Sunscreen and a bucket hat recommended — warm days ahead.')
  }
  if (weather.some((d) => d.lowTemp < 10)) {
    tips.push('Bring warm layers for chilly evenings at the campsite.')
  }
  tips.push('Irish summer weather changes fast — check again closer to the festival.')
  tips.push('Stay hydrated — bring a reusable water bottle.')
  return tips.slice(0, 6)
}
