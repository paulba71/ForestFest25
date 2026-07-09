import type { FestivalLogEntryWithPhoto } from '../types/festivalLog'
import { formatLogTime } from '../utils/festivalLogUtils'
import './LogFeedCard.css'

interface LogFeedCardProps {
  entry: FestivalLogEntryWithPhoto
  selectionMode: boolean
  selected: boolean
  onToggleSelect: (id: string) => void
  onDelete: (id: string) => void
  onSaveToPhotos: (entry: FestivalLogEntryWithPhoto) => void
}

export function LogFeedCard({
  entry,
  selectionMode,
  selected,
  onToggleSelect,
  onDelete,
  onSaveToPhotos,
}: LogFeedCardProps) {
  function handleCardClick() {
    if (selectionMode) {
      onToggleSelect(entry.id)
    }
  }

  return (
    <article
      className={`log-feed-card ${selectionMode ? 'selectable' : ''} ${selected ? 'is-selected' : ''}`}
      onClick={handleCardClick}
    >
      <header className="log-feed-header">
        <div className="log-feed-header-main">
          {selectionMode && (
            <span className="log-feed-checkbox" aria-hidden="true">
              {selected ? '☑' : '☐'}
            </span>
          )}
          <div>
            <div className="log-feed-artist">{entry.artistName}</div>
            <div className="log-feed-time">{formatLogTime(entry.createdAt)}</div>
          </div>
        </div>
        {!selectionMode && (
          <div className="log-feed-actions">
            <button
              type="button"
              className="log-feed-save"
              onClick={(e) => {
                e.stopPropagation()
                onSaveToPhotos(entry)
              }}
              aria-label="Save branded photo to Photos"
              title="Save to Photos (opens share sheet on iPhone)"
            >
              ⬇
            </button>
            <button
              type="button"
              className="log-feed-delete"
              onClick={(e) => {
                e.stopPropagation()
                onDelete(entry.id)
              }}
              aria-label="Delete this moment"
              title="Delete moment"
            >
              ×
            </button>
          </div>
        )}
      </header>
      <img src={entry.photoUrl} alt={entry.artistName} className="log-feed-photo" />
      {entry.caption && <p className="log-feed-caption">{entry.caption}</p>}
    </article>
  )
}
