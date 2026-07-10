export type Stage = 'Main Stage' | 'Forest Fleadh Stage' | "Kickin' Up Dust Arena"

export type PerformanceDay = 'Friday, July 24' | 'Saturday, July 25' | 'Sunday, July 26'

export type ScheduleStatus = 'announced' | 'tba'

export interface Artist {
  id: string
  name: string
  imageName: string
  imageUrl: string
  stage: Stage
  performanceDay: PerformanceDay | null
  performanceTime: string | null
  performanceEndTime: string | null
  scheduleStatus: ScheduleStatus
}

export type ChecklistState = 'notPacked' | 'packed' | 'notNeeded'

export interface ChecklistItem {
  id: string
  name: string
  category: string
  description: string
  state: ChecklistState
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

export interface HourlyWeather {
  time: string
  temp: number
  condition: string
  icon: string
}

export const STAGES: Stage[] = ['Main Stage', 'Forest Fleadh Stage', "Kickin' Up Dust Arena"]

export const DAYS: PerformanceDay[] = ['Friday, July 24', 'Saturday, July 25', 'Sunday, July 26']

export const STAGE_COLORS: Record<Stage, string> = {
  'Main Stage': '#a855f7',
  'Forest Fleadh Stage': '#3b82f6',
  "Kickin' Up Dust Arena": '#f97316',
}

export const DAY_ORDER: Record<PerformanceDay, number> = {
  'Friday, July 24': 0,
  'Saturday, July 25': 1,
  'Sunday, July 26': 2,
}

export function hasSchedule(artists: Artist[]): boolean {
  return artists.some((a) => a.scheduleStatus === 'announced' && a.performanceTime)
}
