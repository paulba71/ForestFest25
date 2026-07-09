import { useCallback, useEffect, useState } from 'react'
import type { ChecklistItem, ChecklistState } from '../types'
import { DEFAULT_CHECKLIST } from '../data/checklistDefaults'

const STORAGE_KEY = 'festivalChecklist'

export function useChecklist() {
  const [items, setItems] = useState<ChecklistItem[]>(() => {
    try {
      const saved = localStorage.getItem(STORAGE_KEY)
      if (saved) return JSON.parse(saved)
    } catch {
      /* fall through */
    }
    return DEFAULT_CHECKLIST.map((item) => ({ ...item, id: crypto.randomUUID() }))
  })

  useEffect(() => {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(items))
  }, [items])

  const updateState = useCallback((id: string, state: ChecklistState) => {
    setItems((prev) => prev.map((item) => (item.id === id ? { ...item, state } : item)))
  }, [])

  const cycleState = useCallback((id: string) => {
    setItems((prev) =>
      prev.map((item) => {
        if (item.id !== id) return item
        const next: ChecklistState =
          item.state === 'notPacked' ? 'packed' : item.state === 'packed' ? 'notNeeded' : 'notPacked'
        return { ...item, state: next }
      }),
    )
  }, [])

  const addItem = useCallback((name: string, category: string, description: string) => {
    setItems((prev) => [
      ...prev,
      { id: crypto.randomUUID(), name, category, description, state: 'notPacked' },
    ])
  }, [])

  const deleteItem = useCallback((id: string) => {
    setItems((prev) => prev.filter((item) => item.id !== id))
  }, [])

  const resetAll = useCallback(() => {
    setItems((prev) => prev.map((item) => ({ ...item, state: 'notPacked' as const })))
  }, [])

  const progress = (() => {
    const packed = items.filter((i) => i.state === 'packed').length
    const total = items.filter((i) => i.state !== 'notNeeded').length
    return { packed, total, percent: total > 0 ? Math.round((packed / total) * 100) : 0 }
  })()

  const byCategory = items.reduce<Record<string, ChecklistItem[]>>((acc, item) => {
    if (!acc[item.category]) acc[item.category] = []
    acc[item.category].push(item)
    return acc
  }, {})

  return { items, updateState, cycleState, addItem, deleteItem, resetAll, progress, byCategory }
}
