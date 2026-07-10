import { useCallback, useEffect, useState } from 'react'
import type { FestivalLogEntry, FestivalLogEntryWithPhoto } from '../types/festivalLog'
import { compareLogEntries } from '../utils/festivalLogUtils'
import {
  clearAllLogEntries,
  deleteLogEntries,
  deleteLogEntry,
  getAllLogEntries,
  getLogPhoto,
  saveLogEntry,
  saveLogPhoto,
} from '../utils/festivalLogDb'

export function useFestivalLog() {
  const [entries, setEntries] = useState<FestivalLogEntryWithPhoto[]>([])
  const [loading, setLoading] = useState(true)

  const loadEntries = useCallback(async () => {
    setLoading(true)
    try {
      const stored = await getAllLogEntries()
      const sorted = stored.sort(compareLogEntries)
      const withPhotos: FestivalLogEntryWithPhoto[] = []

      for (const entry of sorted) {
        const blob = await getLogPhoto(entry.photoId)
        if (!blob) continue
        withPhotos.push({
          ...entry,
          photoUrl: URL.createObjectURL(blob),
        })
      }

      setEntries((prev) => {
        prev.forEach((e) => URL.revokeObjectURL(e.photoUrl))
        return withPhotos
      })
    } finally {
      setLoading(false)
    }
  }, [])

  useEffect(() => {
    loadEntries()
    return () => {
      setEntries((prev) => {
        prev.forEach((e) => URL.revokeObjectURL(e.photoUrl))
        return []
      })
    }
  }, [loadEntries])

  const addEntry = useCallback(
    async (entry: FestivalLogEntry, photoBlob: Blob) => {
      await saveLogPhoto(entry.photoId, photoBlob)
      await saveLogEntry(entry)
      await loadEntries()
    },
    [loadEntries],
  )

  const removeEntry = useCallback(
    async (id: string) => {
      await deleteLogEntry(id)
      await loadEntries()
    },
    [loadEntries],
  )

  const removeEntries = useCallback(
    async (ids: string[]) => {
      await deleteLogEntries(ids)
      await loadEntries()
    },
    [loadEntries],
  )

  const clearAll = useCallback(async () => {
    await clearAllLogEntries()
    await loadEntries()
  }, [loadEntries])

  return { entries, loading, addEntry, removeEntry, removeEntries, clearAll, reload: loadEntries }
}
