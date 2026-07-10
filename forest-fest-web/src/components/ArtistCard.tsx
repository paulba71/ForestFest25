import type { Artist } from '../types'
import { useFavorites } from '../context/FavoritesContext'
import { artistImageUrl, getDuration } from '../utils/artistUtils'
import './ArtistCard.css'

interface ArtistCardProps {
  artist: Artist
}

export function ArtistCard({ artist }: ArtistCardProps) {
  const { isFavorited, toggleFavorite } = useFavorites()
  const favorited = isFavorited(artist)
  const duration = getDuration(artist)
  const hasTimes = artist.performanceTime && artist.performanceEndTime

  return (
    <article className="artist-card">
      <div className="artist-card-image-wrap">
        <img
          src={artistImageUrl(artist)}
          alt={artist.name}
          className="artist-card-image"
          loading="lazy"
          onError={(e) => {
            ;(e.target as HTMLImageElement).src = '/images/artists/artist-placeholder.png'
          }}
        />
        <button
          type="button"
          className={`artist-card-heart ${favorited ? 'favorited' : ''}`}
          onClick={() => toggleFavorite(artist)}
          aria-label={favorited ? 'Remove from favorites' : 'Add to favorites'}
        >
          {favorited ? '♥' : '♡'}
        </button>
      </div>
      <div className="artist-card-info">
        <h3 className="artist-card-name">{artist.name}</h3>
        {hasTimes ? (
          <p className="artist-card-time">
            {artist.performanceTime} – {artist.performanceEndTime}
          </p>
        ) : (
          <p className="artist-card-time tba">Set times TBA</p>
        )}
        {artist.performanceDay && (
          <p className="artist-card-day">{artist.performanceDay.split(',')[0]}</p>
        )}
        <p className="artist-card-stage">{artist.stage}</p>
        {duration && <p className="artist-card-duration">{duration}</p>}
      </div>
    </article>
  )
}
