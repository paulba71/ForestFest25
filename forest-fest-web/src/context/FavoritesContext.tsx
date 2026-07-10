import { createContext, useContext, type ReactNode } from 'react'
import { useFavorites as useFavoritesHook } from '../hooks/useFavorites'

type FavoritesContextType = ReturnType<typeof useFavoritesHook>

const FavoritesContext = createContext<FavoritesContextType | null>(null)

export function FavoritesProvider({ children }: { children: ReactNode }) {
  const value = useFavoritesHook()
  return <FavoritesContext.Provider value={value}>{children}</FavoritesContext.Provider>
}

export function useFavorites() {
  const ctx = useContext(FavoritesContext)
  if (!ctx) throw new Error('useFavorites must be used within FavoritesProvider')
  return ctx
}
