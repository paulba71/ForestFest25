import { useMemo, useState } from 'react'
import type { Artist, PerformanceDay, Stage } from '../types'
import { DAYS, STAGE_COLORS, STAGES } from '../types'
import { useFavorites } from '../context/FavoritesContext'
import {
  generateTimeIntervals,
  getDayStartTime,
  getTimeLabels,
  sortArtists,
  timeToMinutes,
} from '../utils/artistUtils'
import './TimetableGrid.css'

const SLOT_WIDTH = 10
const STAGE_LABEL_WIDTH = 120

interface TimetableGridProps {
  artists: Artist[]
}

export function TimetableGrid({ artists }: TimetableGridProps) {
  const { isFavorited } = useFavorites()
  const [selectedDay, setSelectedDay] = useState<PerformanceDay>('Friday, July 24')

  const intervals = useMemo(
    () => generateTimeIntervals(getDayStartTime(selectedDay), '02:00'),
    [selectedDay],
  )
  const timeLabels = useMemo(() => getTimeLabels(selectedDay), [selectedDay])
  const gridWidth = intervals.length * SLOT_WIDTH

  const dayArtists = useMemo(
    () =>
      sortArtists(
        artists.filter(
          (a) => a.performanceDay === selectedDay && a.performanceTime && a.performanceEndTime,
        ),
      ),
    [artists, selectedDay],
  )

  const artistsByStage = useMemo(() => {
    const map = new Map<Stage, Artist[]>()
    for (const stage of STAGES) {
      map.set(
        stage,
        dayArtists.filter((a) => a.stage === stage),
      )
    }
    return map
  }, [dayArtists])

  const startMinutes = timeToMinutes(getDayStartTime(selectedDay))

  function getEventStyle(artist: Artist) {
    const start = timeToMinutes(artist.performanceTime!)
    const end = timeToMinutes(artist.performanceEndTime!)
    const left = ((start - startMinutes) / 5) * SLOT_WIDTH
    const width = Math.max(((end - start) / 5) * SLOT_WIDTH, 60)
    return { left, width }
  }

  return (
    <>
      <div className="timetable-day-tabs">
        {DAYS.map((day) => (
          <button
            key={day}
            type="button"
            className={`timetable-day-tab ${selectedDay === day ? 'active' : ''}`}
            onClick={() => setSelectedDay(day)}
          >
            {day.split(',')[0]}
          </button>
        ))}
      </div>

      <div className="timetable-scroll">
        <div className="timetable-grid" style={{ width: STAGE_LABEL_WIDTH + gridWidth + 60 }}>
          <div className="timetable-header-row">
            <div className="timetable-corner" style={{ width: STAGE_LABEL_WIDTH }} />
            <div className="timetable-label-offset" style={{ width: 60 }} />
            <div className="timetable-time-labels" style={{ width: gridWidth }}>
              {timeLabels.map((time) => (
                <span
                  key={time}
                  className="timetable-time-label"
                  style={{ left: ((timeToMinutes(time) - startMinutes) / 5) * SLOT_WIDTH }}
                >
                  {time}
                </span>
              ))}
            </div>
          </div>

          {STAGES.map((stage) => (
            <div key={stage} className="timetable-stage-row">
              <div
                className="timetable-stage-label"
                style={{ width: STAGE_LABEL_WIDTH, color: STAGE_COLORS[stage] }}
              >
                {stage.replace(' Stage', '').replace(' Arena', '')}
              </div>
              <div className="timetable-stage-track" style={{ width: gridWidth + 60 }}>
                <div className="timetable-grid-bg" style={{ width: gridWidth }}>
                  {intervals.map((_, i) => (
                    <div
                      key={i}
                      className={`timetable-slot ${i % 6 === 0 ? 'major' : ''}`}
                      style={{ width: SLOT_WIDTH }}
                    />
                  ))}
                </div>
                <div className="timetable-events" style={{ width: gridWidth, left: 60 }}>
                  {(artistsByStage.get(stage) ?? []).map((artist) => {
                    const favorited = isFavorited(artist)
                    const style = getEventStyle(artist)
                    return (
                      <div
                        key={artist.id}
                        className={`timetable-event ${favorited ? 'favorited' : ''}`}
                        style={{
                          left: style.left,
                          width: style.width,
                          borderColor: STAGE_COLORS[stage],
                        }}
                        title={`${artist.name} (${artist.performanceTime}–${artist.performanceEndTime})`}
                      >
                        <span className="timetable-event-name">
                          {favorited && '♥ '}
                          {artist.name}
                        </span>
                      </div>
                    )
                  })}
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>
    </>
  )
}
