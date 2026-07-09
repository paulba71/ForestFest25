import type { Artist, PerformanceDay } from '../types'
import { DAY_ORDER } from '../types'

export function timeToMinutes(timeString: string): number {
  const [hourStr, minuteStr] = timeString.split(':')
  const hour = parseInt(hourStr, 10)
  const minute = parseInt(minuteStr, 10)
  const adjustedHour = hour >= 0 && hour <= 5 ? hour + 24 : hour
  return adjustedHour * 60 + minute
}

export function getDuration(artist: Artist): string | null {
  if (!artist.performanceTime || !artist.performanceEndTime) return null
  const start = timeToMinutes(artist.performanceTime)
  const end = timeToMinutes(artist.performanceEndTime)
  const duration = end - start
  if (duration <= 0) return null
  const hours = Math.floor(duration / 60)
  const minutes = duration % 60
  if (hours > 0) return `${hours}h ${minutes}m`
  return `${minutes}m`
}

export function overlaps(a: Artist, b: Artist): boolean {
  if (!a.performanceTime || !b.performanceTime || !a.performanceEndTime || !b.performanceEndTime) {
    return false
  }
  if (a.performanceDay !== b.performanceDay) return false
  const start1 = timeToMinutes(a.performanceTime)
  const end1 = timeToMinutes(a.performanceEndTime)
  const start2 = timeToMinutes(b.performanceTime)
  const end2 = timeToMinutes(b.performanceEndTime)
  return start1 < end2 && start2 < end1
}

export function sortArtists(artists: Artist[]): Artist[] {
  return [...artists].sort((a, b) => {
    const dayA = a.performanceDay ? DAY_ORDER[a.performanceDay] : 99
    const dayB = b.performanceDay ? DAY_ORDER[b.performanceDay] : 99
    if (dayA !== dayB) return dayA - dayB
    if (a.performanceTime && b.performanceTime) {
      return timeToMinutes(a.performanceTime) - timeToMinutes(b.performanceTime)
    }
    return a.name.localeCompare(b.name)
  })
}

export function generateTimeIntervals(from: string, to: string, stepMinutes = 5): string[] {
  const intervals: string[] = []
  let current = timeToMinutes(from)
  const end = timeToMinutes(to)
  while (current <= end) {
    const hour = Math.floor(current / 60)
    const minute = current % 60
    intervals.push(`${String(hour).padStart(2, '0')}:${String(minute).padStart(2, '0')}`)
    current += stepMinutes
  }
  return intervals
}

export function getTimeLabels(day: PerformanceDay): string[] {
  if (day === 'Friday, July 24') {
    return [
      '16:00', '16:30', '17:00', '17:30', '18:00', '18:30', '19:00', '19:30',
      '20:00', '20:30', '21:00', '21:30', '22:00', '22:30', '23:00', '23:30',
      '00:00', '00:30', '01:00', '01:30', '02:00',
    ]
  }
  return [
    '12:00', '12:30', '13:00', '13:30', '14:00', '14:30', '15:00', '15:30',
    '16:00', '16:30', '17:00', '17:30', '18:00', '18:30', '19:00', '19:30',
    '20:00', '20:30', '21:00', '21:30', '22:00', '22:30', '23:00', '23:30',
    '00:00', '00:30', '01:00', '01:30', '02:00',
  ]
}

export function getDayStartTime(day: PerformanceDay): string {
  return day === 'Friday, July 24' ? '16:00' : '12:00'
}

export function artistImageUrl(artist: Artist): string {
  return artist.imageUrl || `/images/artists/${artist.imageName}.png`
}

export function hasClashes(artist: Artist, favorites: Artist[]): boolean {
  return favorites.some(
    (other) =>
      other.id !== artist.id &&
      other.performanceDay === artist.performanceDay &&
      overlaps(artist, other),
  )
}

export function getClashCount(favorites: Artist[]): number {
  return favorites.filter((a) => hasClashes(a, favorites)).length
}
