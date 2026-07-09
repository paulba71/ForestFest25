import type { CurrentWeather, DayWeather, WeatherResponse } from './weatherTypes'

const FESTIVAL_DATES = ['2026-07-24', '2026-07-25', '2026-07-26']
const LAT = 53.0869
const LON = -7.3375

interface OWMItem {
  dt: number
  main: { temp_min: number; temp_max: number; temp: number }
  weather: { main: string; description: string; icon: string }[]
  dt_txt: string
}

function mapIcon(owmIcon: string): string {
  const map: Record<string, string> = {
    '01d': 'sun.max.fill',
    '01n': 'sun.max.fill',
    '02d': 'cloud.sun.fill',
    '02n': 'cloud.sun.fill',
    '03d': 'cloud.fill',
    '03n': 'cloud.fill',
    '04d': 'cloud.fill',
    '04n': 'cloud.fill',
    '09d': 'cloud.drizzle.fill',
    '09n': 'cloud.drizzle.fill',
    '10d': 'cloud.rain.fill',
    '10n': 'cloud.rain.fill',
    '11d': 'cloud.bolt.rain.fill',
    '11n': 'cloud.bolt.rain.fill',
    '13d': 'snow',
    '13n': 'snow',
    '50d': 'cloud.fog.fill',
    '50n': 'cloud.fog.fill',
  }
  return map[owmIcon] ?? 'cloud.sun.fill'
}

function capitalize(text: string): string {
  return text.charAt(0).toUpperCase() + text.slice(1)
}

function dayWeatherFromItems(date: string, dayLabel: string, dayItems: OWMItem[]): DayWeather {
  const temps = dayItems.flatMap((i) => [i.main.temp_min, i.main.temp_max, i.main.temp])
  const highTemp = temps.length ? Math.max(...temps) : 0
  const lowTemp = temps.length ? Math.min(...temps) : 0
  const midday = dayItems[Math.floor(dayItems.length / 2)]
  const condition = midday?.weather[0]?.description ?? 'Unknown'
  const icon = mapIcon(midday?.weather[0]?.icon ?? '02d')

  return {
    date,
    dayOfWeek: dayLabel,
    highTemp,
    lowTemp,
    condition: capitalize(condition),
    icon,
    hourlyForecast: dayItems.map((item) => ({
      time: item.dt_txt.split(' ')[1]?.slice(0, 5) ?? '',
      temp: item.main.temp,
      condition: item.weather[0]?.description ?? '',
      icon: mapIcon(item.weather[0]?.icon ?? '02d'),
    })),
  }
}

function groupByDate(list: OWMItem[]): Map<string, OWMItem[]> {
  const grouped = new Map<string, OWMItem[]>()
  for (const item of list) {
    const date = item.dt_txt.split(' ')[0]
    const items = grouped.get(date) ?? []
    items.push(item)
    grouped.set(date, items)
  }
  return grouped
}

export async function fetchFestivalWeather(apiKey: string): Promise<WeatherResponse> {
  if (!apiKey) {
    throw new Error('Weather API key not configured')
  }

  const [forecastRes, currentRes] = await Promise.all([
    fetch(
      `https://api.openweathermap.org/data/2.5/forecast?lat=${LAT}&lon=${LON}&units=metric&appid=${apiKey}`,
    ),
    fetch(
      `https://api.openweathermap.org/data/2.5/weather?lat=${LAT}&lon=${LON}&units=metric&appid=${apiKey}`,
    ),
  ])

  if (!forecastRes.ok) {
    const body = await forecastRes.text()
    throw new Error(`OpenWeatherMap forecast failed: ${forecastRes.status} ${body}`)
  }

  const forecastData = await forecastRes.json()
  const list: OWMItem[] = forecastData.list ?? []
  const byDate = groupByDate(list)

  const festivalDayNames = ['Friday', 'Saturday', 'Sunday']
  const festivalDays = FESTIVAL_DATES.map((date, index) =>
    dayWeatherFromItems(date, festivalDayNames[index] ?? date, byDate.get(date) ?? []),
  )

  const festivalForecastAvailable = festivalDays.some((day) => day.hourlyForecast.length > 0)

  const upcomingDays = [...byDate.entries()]
    .sort(([a], [b]) => a.localeCompare(b))
    .slice(0, 5)
    .map(([date, items]) => {
      const label = new Date(`${date}T12:00:00`).toLocaleDateString('en-IE', {
        weekday: 'short',
        month: 'short',
        day: 'numeric',
      })
      return dayWeatherFromItems(date, label, items)
    })

  let current: CurrentWeather | null = null
  if (currentRes.ok) {
    const currentData = await currentRes.json()
    current = {
      temp: currentData.main?.temp ?? 0,
      condition: capitalize(currentData.weather?.[0]?.description ?? 'Unknown'),
      icon: mapIcon(currentData.weather?.[0]?.icon ?? '02d'),
      location: 'Emo Village, Co. Laois',
    }
  }

  return {
    festivalDays,
    festivalForecastAvailable,
    message: festivalForecastAvailable
      ? null
      : 'Festival weekend is more than 5 days away. OpenWeather provides a detailed forecast closer to the event — check back from around July 19.',
    current,
    upcomingDays,
  }
}
