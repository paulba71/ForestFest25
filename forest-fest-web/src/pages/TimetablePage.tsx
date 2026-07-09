import artistsData from '../data/artists.json'
import type { Artist } from '../types'
import { hasSchedule } from '../types'
import { PageLayout } from '../components/PageLayout'
import { TimetableGrid } from '../components/TimetableGrid'
import './TimetablePage.css'

const allArtists = artistsData as Artist[]

export function TimetablePage() {
  const scheduleReady = hasSchedule(allArtists)

  return (
    <PageLayout title="Timetable">
      {scheduleReady ? (
        <TimetableGrid artists={allArtists} />
      ) : (
        <div className="timetable-coming-soon">
          <span className="timetable-coming-soon-icon">⏱</span>
          <h2>Set times coming soon</h2>
          <p>
            Forest Fest hasn&apos;t published the 2026 stage timetable yet. Check the lineup for
            announced artists, and we&apos;ll enable the full grid once times are released.
          </p>
          <a
            href="https://forestfest.ie/get-the-map/"
            target="_blank"
            rel="noopener noreferrer"
            className="timetable-coming-soon-link"
          >
            Sign up for timetable updates on forestfest.ie
          </a>
        </div>
      )}
    </PageLayout>
  )
}
