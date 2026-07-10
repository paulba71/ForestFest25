import { useMemo } from 'react'
import type { PerformanceDay } from '../types'
import { DAYS, STAGE_COLORS, STAGES } from '../types'
import { useFavorites } from '../context/FavoritesContext'
import { getClashCount, getDuration, hasClashes, sortArtists } from '../utils/artistUtils'
import { PageLayout } from '../components/PageLayout'
import './SchedulePage.css'

export function SchedulePage() {
  const { favoritedArtists } = useFavorites()

  const grouped = useMemo(() => {
    const map = new Map<PerformanceDay | 'weekend', typeof favoritedArtists>()
    for (const day of DAYS) {
      const dayArtists = sortArtists(favoritedArtists.filter((a) => a.performanceDay === day))
      if (dayArtists.length > 0) map.set(day, dayArtists)
    }
    const weekend = sortArtists(favoritedArtists.filter((a) => a.performanceDay === null))
    if (weekend.length > 0) map.set('weekend', weekend)
    return map
  }, [favoritedArtists])

  const clashCount = getClashCount(favoritedArtists)
  const hasTimes = favoritedArtists.some((a) => a.performanceTime)

  return (
    <PageLayout title="My Schedule">
      {favoritedArtists.length === 0 ? (
        <div className="schedule-empty">
          <span className="schedule-empty-icon">♡</span>
          <h2>No favorites added yet!</h2>
          <p>Add artists to your schedule by tapping the heart icon in the lineup.</p>
        </div>
      ) : (
        <>
          {!hasTimes && (
            <div className="schedule-clash-banner info">
              Set times haven&apos;t been published yet — your favorites are grouped by day and area.
            </div>
          )}
          {clashCount > 0 && (
            <div className="schedule-clash-banner">
              ⚠ {clashCount} performance{clashCount === 1 ? '' : 's'} clash
              {clashCount === 1 ? 'es' : ''} with other favorites
            </div>
          )}

          <div className="schedule-legend">
            {STAGES.map((stage) => (
              <span key={stage} className="schedule-legend-item">
                <span className="schedule-legend-dot" style={{ background: STAGE_COLORS[stage] }} />
                {stage}
              </span>
            ))}
          </div>

          <div className="schedule-list">
            {Array.from(grouped.entries()).map(([day, artists]) => (
              <section key={day} className="schedule-day">
                <h2 className="schedule-day-title">
                  {day === 'weekend' ? 'Forest Fleadh & Kickin\' Up Dust' : day}
                </h2>
                {artists.map((artist) => {
                  const clash = hasClashes(artist, favoritedArtists)
                  const duration = getDuration(artist)
                  return (
                    <div key={artist.id} className={`schedule-row ${clash ? 'clash' : ''}`}>
                      <div className="schedule-time">
                        {artist.performanceTime ? (
                          <>
                            <span>{artist.performanceTime}</span>
                            <span className="schedule-time-end">{artist.performanceEndTime}</span>
                          </>
                        ) : (
                          <span className="schedule-time-tba">TBA</span>
                        )}
                      </div>
                      <div
                        className="schedule-stage-bar"
                        style={{ background: STAGE_COLORS[artist.stage] }}
                      />
                      <div className="schedule-details">
                        <div className="schedule-artist-name">
                          {artist.name}
                          {clash && <span className="schedule-clash-icon">⚠</span>}
                        </div>
                        <div className="schedule-stage-name">{artist.stage}</div>
                        {duration && <div className="schedule-duration">({duration})</div>}
                      </div>
                    </div>
                  )
                })}
              </section>
            ))}
          </div>
        </>
      )}
    </PageLayout>
  )
}
