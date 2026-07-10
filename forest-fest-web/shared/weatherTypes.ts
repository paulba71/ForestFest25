export interface HourlyWeather {
  time: string
  temp: number
  condition: string
  icon: string
}

export interface DayWeather {
  date: string
  dayOfWeek: string
  highTemp: number
  lowTemp: number
  condition: string
  icon: string
  hourlyForecast: HourlyWeather[]
}

export interface CurrentWeather {
  temp: number
  condition: string
  icon: string
  location: string
}

export interface WeatherResponse {
  festivalDays: DayWeather[]
  festivalForecastAvailable: boolean
  message: string | null
  current: CurrentWeather | null
  upcomingDays: DayWeather[]
}
