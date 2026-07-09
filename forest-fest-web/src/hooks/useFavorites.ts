import { useCallback, useEffect, useState } from 'react'
import type { Artist } from '../types'
import artistsData from '../data/artists.json'

const STORAGE_KEY = 'favoritedArtists'

export function useFavorites() {
  const [favoritedIds, setFavoritedIds] = useState<string[]>(() => {
    try {
      const saved = localStorage.getItem(STORAGE_KEY)
      return saved ? JSON.parse(saved) : []
    } catch {
      return []
    }
  })

  useEffect(() => {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(favoritedIds))
  }, [favoritedIds])

  const toggleFavorite = useCallback((artist: Artist) => {
    setFavoritedIds((prev) =>
      prev.includes(artist.id)
        ? prev.filter((id) => id !== artist.id)
        : [...prev, artist.id],
    )
  }, [])

  const isFavorited = useCallback(
    (artist: Artist) => favoritedIds.includes(artist.id),
    [favoritedIds],
  )

  const clearAll = useCallback(() => setFavoritedIds([]), [])

  const favoritedArtists = (artistsData as Artist[]).filter((a) =>
    favoritedIds.includes(a.id),
  )

  return { favoritedIds, favoritedArtists, toggleFavorite, isFavorited, clearAll }
}
