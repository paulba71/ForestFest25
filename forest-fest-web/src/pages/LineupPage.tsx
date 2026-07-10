import { useMemo, useState } from 'react'
import type { Artist, PerformanceDay, Stage } from '../types'
import { DAYS, STAGES } from '../types'
import artistsData from '../data/artists.json'
import { useFavorites } from '../context/FavoritesContext'
import { sortArtists } from '../utils/artistUtils'
import { PageLayout } from '../components/PageLayout'
import { ArtistCard } from '../components/ArtistCard'
import './LineupPage.css'

const allArtists = artistsData as Artist[]

export function LineupPage() {
  const { isFavorited } = useFavorites()
  const [showFavoritesOnly, setShowFavoritesOnly] = useState(false)
  const [selectedDay, setSelectedDay] = useState<PerformanceDay | 'all'>('all')
  const [selectedStage, setSelectedStage] = useState<Stage | 'all'>('all')

  const filtered = useMemo(() => {
    let result = allArtists
    if (showFavoritesOnly) result = result.filter((a) => isFavorited(a))
    if (selectedStage !== 'all') result = result.filter((a) => a.stage === selectedStage)
    if (selectedDay !== 'all') {
      result = result.filter((a) => a.performanceDay === selectedDay || a.performanceDay === null)
    }
    return sortArtists(result)
  }, [showFavoritesOnly, selectedDay, selectedStage, isFavorited])

  return (
    <PageLayout title="Lineup 2026">
      <p className="lineup-notice">Lineup from forestfest.ie — set times coming soon.</p>
      <div className="lineup-filters">
        <label className="lineup-favorites-toggle">
          <input
            type="checkbox"
            checked={showFavoritesOnly}
            onChange={(e) => setShowFavoritesOnly(e.target.checked)}
          />
          <span className="lineup-heart">♥</span>
          Show Favorites Only
        </label>

        <div className="lineup-pills">
          <button
            type="button"
            className={`lineup-pill ${selectedDay === 'all' ? 'active' : ''}`}
            onClick={() => setSelectedDay('all')}
          >
            All Days
          </button>
          {DAYS.map((day) => (
            <button
              key={day}
              type="button"
              className={`lineup-pill ${selectedDay === day ? 'active' : ''}`}
              onClick={() => setSelectedDay(day)}
            >
              {day.split(',')[0]}
            </button>
          ))}
        </div>

        <select
          className="lineup-stage-select"
          value={selectedStage}
          onChange={(e) => setSelectedStage(e.target.value as Stage | 'all')}
        >
          <option value="all">All Areas</option>
          {STAGES.map((stage) => (
            <option key={stage} value={stage}>
              {stage}
            </option>
          ))}
        </select>
      </div>

      <p className="lineup-count">{filtered.length} artists</p>

      <div className="lineup-grid">
        {filtered.map((artist) => (
          <ArtistCard key={artist.id} artist={artist} />
        ))}
      </div>
    </PageLayout>
  )
}
