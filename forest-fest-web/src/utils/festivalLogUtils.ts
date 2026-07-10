import type { Artist, PerformanceDay } from '../types'
import { sortArtists, timeToMinutes } from './artistUtils'

const FESTIVAL_DAY_BY_DATE: Record<string, PerformanceDay> = {
  '2026-07-24': 'Friday, July 24',
  '2026-07-25': 'Saturday, July 25',
  '2026-07-26': 'Sunday, July 26',
}

export function getCurrentFestivalDay(now = new Date()): PerformanceDay | null {
  const key = formatLocalDate(now)
  return FESTIVAL_DAY_BY_DATE[key] ?? null
}

export function formatLocalDate(date: Date): string {
  const y = date.getFullYear()
  const m = String(date.getMonth() + 1).padStart(2, '0')
  const d = String(date.getDate()).padStart(2, '0')
  return `${y}-${m}-${d}`
}

export function formatLogTime(iso: string): string {
  return new Date(iso).toLocaleString('en-IE', {
    weekday: 'short',
    hour: '2-digit',
    minute: '2-digit',
  })
}

function formatHHMM(date: Date): string {
  return `${String(date.getHours()).padStart(2, '0')}:${String(date.getMinutes()).padStart(2, '0')}`
}

function isPlayingAt(artist: Artist, time: string): boolean {
  if (!artist.performanceTime || !artist.performanceEndTime) return false
  const t = timeToMinutes(time)
  return t >= timeToMinutes(artist.performanceTime) && t < timeToMinutes(artist.performanceEndTime)
}

export function getLikelyArtistsAtTime(artists: Artist[], now = new Date()): Artist[] {
  const festivalDay = getCurrentFestivalDay(now)
  const currentTime = formatHHMM(now)

  let candidates = artists
  if (festivalDay) {
    candidates = artists.filter(
      (a) => a.performanceDay === festivalDay || a.performanceDay === null,
    )
  }

  const withTimes = candidates.filter((a) => a.performanceTime && a.performanceEndTime)
  if (withTimes.length > 0) {
    const onStageNow = withTimes.filter((a) => isPlayingAt(a, currentTime))
    if (onStageNow.length > 0) return sortArtists(onStageNow)
  }

  if (festivalDay) {
    const dayArtists = candidates.filter((a) => a.performanceDay === festivalDay)
    if (dayArtists.length > 0) return sortArtists(dayArtists)
  }

  return sortArtists(candidates).slice(0, 24)
}

export function getFestivalDayLabel(day: PerformanceDay | null): string {
  if (!day) return 'Outside festival weekend'
  return day.split(',')[0]
}

export function compareLogEntries(a: { createdAt: string }, b: { createdAt: string }): number {
  return b.createdAt.localeCompare(a.createdAt)
}
