import { PageLayout } from '../components/PageLayout'
import './MapPage.css'

const MAP_URL = 'https://forestfest.ie/wp-content/uploads/2026/07/Forest-Fest-2026-Sitemap-PDF.pdf'

export function MapPage() {
  return (
    <PageLayout
      title="Event Map"
      rightAction={
        <a
          href={MAP_URL}
          target="_blank"
          rel="noopener noreferrer"
          className="map-external-link"
          aria-label="Open map in browser"
        >
          ↗
        </a>
      }
    >
      <iframe
        src={MAP_URL}
        title="Forest Fest Event Map"
        className="map-iframe"
        loading="lazy"
      />
    </PageLayout>
  )
}
