import { useEffect, useMemo, useRef, useState } from 'react'
import type { Artist } from '../types'
import {
  GENERAL_FROLLOCKS_ID,
  GENERAL_FROLLOCKS_LABEL,
  type FestivalLogEntry,
  type FestivalLogEntryWithPhoto,
} from '../types/festivalLog'
import artistsData from '../data/artists.json'
import { useFestivalLog } from '../hooks/useFestivalLog'
import {
  getCurrentFestivalDay,
  getFestivalDayLabel,
  getLikelyArtistsAtTime,
} from '../utils/festivalLogUtils'
import { savePhotoToDevice } from '../utils/savePhotoToDevice'
import { exportAllFestivalLogPhotos } from '../utils/exportFestivalLog'
import { brandFestivalPhoto, getSelectedArtistLabel } from '../utils/brandedPhoto'
import { PageLayout } from '../components/PageLayout'
import { LogFeedCard } from '../components/LogFeedCard'
import './FestivalLogPage.css'

const allArtists = artistsData as Artist[]

type Step = 'feed' | 'tag'

export function FestivalLogPage() {
  const { entries, loading, addEntry, removeEntry, removeEntries, clearAll } = useFestivalLog()
  const fileInputRef = useRef<HTMLInputElement>(null)
  const [step, setStep] = useState<Step>('feed')
  const [photoBlob, setPhotoBlob] = useState<Blob | null>(null)
  const [photoPreview, setPhotoPreview] = useState<string | null>(null)
  const [previewLoading, setPreviewLoading] = useState(false)
  const [brandingError, setBrandingError] = useState<string | null>(null)
  const [caption, setCaption] = useState('')
  const [selectedArtistId, setSelectedArtistId] = useState<string>(GENERAL_FROLLOCKS_ID)
  const [showAllArtists, setShowAllArtists] = useState(false)
  const [saving, setSaving] = useState(false)
  const [exporting, setExporting] = useState(false)
  const [selectionMode, setSelectionMode] = useState(false)
  const [selectedIds, setSelectedIds] = useState<string[]>([])

  const now = useMemo(() => new Date(), [step])
  const festivalDay = getCurrentFestivalDay(now)
  const likelyArtists = useMemo(() => getLikelyArtistsAtTime(allArtists, now), [now])
  const pickerArtists = showAllArtists ? allArtists : likelyArtists
  const selectedArtistLabel = getSelectedArtistLabel(
    selectedArtistId,
    allArtists,
    GENERAL_FROLLOCKS_LABEL,
  )

  useEffect(() => {
    if (step !== 'tag' || !photoBlob) return

    let cancelled = false
    setPreviewLoading(true)
    setBrandingError(null)

    brandFestivalPhoto(photoBlob, selectedArtistLabel)
      .then((branded) => {
        if (cancelled) return
        const url = URL.createObjectURL(branded)
        setPhotoPreview((prev) => {
          if (prev) URL.revokeObjectURL(prev)
          return url
        })
      })
      .catch((error) => {
        if (cancelled) return
        setBrandingError(
          error instanceof Error ? error.message : 'Could not add the festival label to this photo.',
        )
        const url = URL.createObjectURL(photoBlob)
        setPhotoPreview((prev) => {
          if (prev) URL.revokeObjectURL(prev)
          return url
        })
      })
      .finally(() => {
        if (!cancelled) setPreviewLoading(false)
      })

    return () => {
      cancelled = true
    }
  }, [step, photoBlob, selectedArtistLabel])

  function resetCapture() {
    if (photoPreview) URL.revokeObjectURL(photoPreview)
    setPhotoBlob(null)
    setPhotoPreview(null)
    setCaption('')
    setSelectedArtistId(GENERAL_FROLLOCKS_ID)
    setShowAllArtists(false)
    setBrandingError(null)
    setStep('feed')
  }

  function handleFileChange(e: React.ChangeEvent<HTMLInputElement>) {
    const file = e.target.files?.[0]
    if (!file) return
    setPhotoBlob(file)
    setStep('tag')
    e.target.value = ''
  }

  async function handleSave() {
    if (!photoBlob) return
    setSaving(true)
    try {
      const artist =
        selectedArtistId === GENERAL_FROLLOCKS_ID
          ? null
          : allArtists.find((a) => a.id === selectedArtistId) ?? null

      const entry: FestivalLogEntry = {
        id: crypto.randomUUID(),
        createdAt: new Date().toISOString(),
        artistId: artist?.id ?? null,
        artistName: artist?.name ?? GENERAL_FROLLOCKS_LABEL,
        caption: caption.trim(),
        photoId: crypto.randomUUID(),
      }

      const brandedPhoto = await brandFestivalPhoto(photoBlob, entry.artistName)
      await addEntry(entry, brandedPhoto)
      resetCapture()
    } catch (error) {
      alert(
        error instanceof Error
          ? error.message
          : 'Could not save this festival moment. Please try another photo.',
      )
    } finally {
      setSaving(false)
    }
  }

  async function handleDelete(id: string) {
    if (confirm('Delete this festival log moment?')) {
      await removeEntry(id)
    }
  }

  function exitSelectionMode() {
    setSelectionMode(false)
    setSelectedIds([])
  }

  function toggleSelected(id: string) {
    setSelectedIds((prev) =>
      prev.includes(id) ? prev.filter((entryId) => entryId !== id) : [...prev, id],
    )
  }

  async function handleDeleteSelected() {
    if (selectedIds.length === 0) return

    const count = selectedIds.length
    const confirmed = confirm(
      `Delete ${count} selected moment${count === 1 ? '' : 's'}?\n\nThis cannot be undone.`,
    )

    if (confirmed) {
      await removeEntries(selectedIds)
      exitSelectionMode()
    }
  }

  async function handleClearLog() {
    if (entries.length === 0) return

    const count = entries.length
    const confirmed = confirm(
      `Are you sure you want to clear your entire Festival Log?\n\nThis will permanently delete all ${count} moment${count === 1 ? '' : 's'} from this device. This cannot be undone.`,
    )

    if (confirmed) {
      await clearAll()
    }
  }

  async function handleSaveToPhotos(entry: FestivalLogEntryWithPhoto) {
    try {
      const response = await fetch(entry.photoUrl)
      const blob = await response.blob()
      await savePhotoToDevice(blob, entry.artistName)
    } catch {
      // Ignore dismiss / unsupported save flows.
    }
  }

  async function handleExportAll() {
    if (entries.length === 0 || exporting) return

    setExporting(true)
    try {
      const result = await exportAllFestivalLogPhotos(entries)
      if (result === 'zip') {
        alert(
          'Your festival log was downloaded as forest-fest-log.zip. On iPhone, open the file in Files and save images to Photos from there.',
        )
      }
    } catch (error) {
      if (error instanceof DOMException && error.name === 'AbortError') return
      alert(
        error instanceof Error
          ? error.message
          : 'Could not export your festival log. Please try again.',
      )
    } finally {
      setExporting(false)
    }
  }

  return (
    <PageLayout
      title="Festival Log"
      rightAction={
        step === 'feed' && !loading && entries.length > 0 ? (
          <button
            type="button"
            className="festival-log-clear-btn"
            onClick={handleClearLog}
          >
            Clear log
          </button>
        ) : undefined
      }
    >
      <input
        ref={fileInputRef}
        type="file"
        accept="image/*"
        capture="environment"
        className="log-file-input"
        onChange={handleFileChange}
      />

      {step === 'feed' ? (
        <div className="festival-log">
          <p className="festival-log-intro">
            Your personal photo timeline of Forest Fest — snap moments and tag who&apos;s on stage.
            Use Export all to save every branded photo at once.
          </p>

          {!loading && entries.length > 0 && (
            <div className="festival-log-toolbar">
              {!selectionMode ? (
                <>
                  <button
                    type="button"
                    className="festival-log-export-btn"
                    onClick={handleExportAll}
                    disabled={exporting}
                  >
                    {exporting ? 'Exporting…' : `Export all (${entries.length})`}
                  </button>
                  <button
                    type="button"
                    className="festival-log-select-btn"
                    onClick={() => setSelectionMode(true)}
                  >
                    Select moments
                  </button>
                </>
              ) : (
                <>
                  <button
                    type="button"
                    className="festival-log-delete-selected-btn"
                    onClick={handleDeleteSelected}
                    disabled={selectedIds.length === 0}
                  >
                    Delete selected ({selectedIds.length})
                  </button>
                  <button
                    type="button"
                    className="festival-log-select-btn"
                    onClick={exitSelectionMode}
                  >
                    Cancel
                  </button>
                </>
              )}
            </div>
          )}

          {loading ? (
            <div className="festival-log-empty">Loading your log...</div>
          ) : entries.length === 0 ? (
            <div className="festival-log-empty">
              <span className="festival-log-empty-icon" aria-hidden="true">
                <svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                  <path
                    d="M4 8.5V18a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8.5a2 2 0 0 0-2-2h-2.2l-1.2-1.6A2 2 0 0 0 14.9 4H9.1a2 2 0 0 0-1.7.9L6.2 6.5H4a2 2 0 0 0-2 2Z"
                    stroke="currentColor"
                    strokeWidth="1.75"
                    strokeLinejoin="round"
                  />
                  <circle cx="12" cy="13" r="3.5" stroke="currentColor" strokeWidth="1.75" />
                </svg>
              </span>
              <h2>No moments yet</h2>
              <p>Tap the camera button to capture your first festival memory.</p>
            </div>
          ) : (
            <div className="festival-log-feed">
              {entries.map((entry) => (
                <LogFeedCard
                  key={entry.id}
                  entry={entry}
                  selectionMode={selectionMode}
                  selected={selectedIds.includes(entry.id)}
                  onToggleSelect={toggleSelected}
                  onDelete={handleDelete}
                  onSaveToPhotos={handleSaveToPhotos}
                />
              ))}
            </div>
          )}

          {!selectionMode && (
            <button
              type="button"
              className="festival-log-fab"
              onClick={() => fileInputRef.current?.click()}
              aria-label="Snap a festival moment"
            >
            <span className="festival-log-fab-icon" aria-hidden="true">
              <svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                <path
                  d="M4 8.5V18a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8.5a2 2 0 0 0-2-2h-2.2l-1.2-1.6A2 2 0 0 0 14.9 4H9.1a2 2 0 0 0-1.7.9L6.2 6.5H4a2 2 0 0 0-2 2Z"
                  stroke="currentColor"
                  strokeWidth="1.75"
                  strokeLinejoin="round"
                />
                <circle cx="12" cy="13" r="3.5" stroke="currentColor" strokeWidth="1.75" />
              </svg>
            </span>
            <span className="festival-log-fab-label">Snap moment</span>
          </button>
          )}
        </div>
      ) : (
        <div className="festival-log-tag">
          <p className="festival-log-tag-hint">
            {festivalDay
              ? `Tag this moment — ${getFestivalDayLabel(festivalDay)}`
              : `Tag this moment — schedule not live for today, pick an artist or ${GENERAL_FROLLOCKS_LABEL}`}
          </p>

          {brandingError && (
            <p className="festival-log-branding-error">
              Label preview unavailable on this device. We&apos;ll still try to add it when you post.
            </p>
          )}

          {photoPreview && (
            <img
              src={photoPreview}
              alt="Captured moment preview"
              className={`festival-log-preview ${previewLoading ? 'loading' : ''}`}
            />
          )}

          <label className="festival-log-field">
            Caption (optional)
            <textarea
              value={caption}
              onChange={(e) => setCaption(e.target.value)}
              placeholder="What a set! / campsite vibes / etc."
              rows={2}
            />
          </label>

          <div className="festival-log-picker-header">
            <h3>Who&apos;s on stage?</h3>
            <button
              type="button"
              className="festival-log-toggle-all"
              onClick={() => setShowAllArtists((v) => !v)}
            >
              {showAllArtists ? 'Show likely now' : 'Browse all artists'}
            </button>
          </div>

          <div className="festival-log-artist-list">
            <button
              type="button"
              className={`festival-log-artist-option ${selectedArtistId === GENERAL_FROLLOCKS_ID ? 'selected' : ''}`}
              onClick={() => setSelectedArtistId(GENERAL_FROLLOCKS_ID)}
            >
              <span className="festival-log-artist-name">{GENERAL_FROLLOCKS_LABEL}</span>
              <span className="festival-log-artist-meta">Not at a stage / vibes / crew</span>
            </button>

            {pickerArtists.map((artist) => (
              <button
                key={artist.id}
                type="button"
                className={`festival-log-artist-option ${selectedArtistId === artist.id ? 'selected' : ''}`}
                onClick={() => setSelectedArtistId(artist.id)}
              >
                <span className="festival-log-artist-name">{artist.name}</span>
                <span className="festival-log-artist-meta">
                  {artist.stage}
                  {artist.performanceDay ? ` · ${artist.performanceDay.split(',')[0]}` : ''}
                </span>
              </button>
            ))}
          </div>

          <div className="festival-log-tag-actions">
            <button type="button" className="festival-log-btn secondary" onClick={resetCapture}>
              Cancel
            </button>
            <button
              type="button"
              className="festival-log-btn primary"
              onClick={handleSave}
              disabled={saving || !photoBlob}
            >
              {saving ? 'Saving...' : 'Post to Festival Log'}
            </button>
          </div>
        </div>
      )}
    </PageLayout>
  )
}
