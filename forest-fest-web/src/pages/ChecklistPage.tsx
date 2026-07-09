import { useState } from 'react'
import type { ChecklistState } from '../types'
import { useChecklist } from '../hooks/useChecklist'
import { PageLayout } from '../components/PageLayout'
import './ChecklistPage.css'

const FILTERS: { key: ChecklistState | 'all'; label: string }[] = [
  { key: 'all', label: 'All' },
  { key: 'notPacked', label: 'Not Packed' },
  { key: 'packed', label: 'Packed' },
  { key: 'notNeeded', label: 'Not Needed' },
]

const STATE_ICONS: Record<ChecklistState, string> = {
  notPacked: '○',
  packed: '✓',
  notNeeded: '−',
}

export function ChecklistPage() {
  const { cycleState, addItem, resetAll, progress, byCategory } = useChecklist()
  const [filter, setFilter] = useState<ChecklistState | 'all'>('all')
  const [showAdd, setShowAdd] = useState(false)
  const [newName, setNewName] = useState('')
  const [newDesc, setNewDesc] = useState('')

  const filteredCategories = Object.entries(byCategory)
    .sort(([a], [b]) => a.localeCompare(b))
    .map(([category, catItems]) => [
      category,
      catItems.filter((item) => filter === 'all' || item.state === filter),
    ] as const)
    .filter(([, catItems]) => catItems.length > 0)

  function handleAdd(e: React.FormEvent) {
    e.preventDefault()
    if (!newName.trim()) return
    addItem(newName.trim(), 'Custom', newDesc.trim() || 'Custom item')
    setNewName('')
    setNewDesc('')
    setShowAdd(false)
  }

  return (
    <PageLayout title="Packing Checklist">
      <div className="checklist-progress">
        <div className="checklist-progress-ring">
          <svg viewBox="0 0 36 36">
            <path
              className="checklist-ring-bg"
              d="M18 2.0845 a 15.9155 15.9155 0 0 1 0 31.831 a 15.9155 15.9155 0 0 1 0 -31.831"
            />
            <path
              className="checklist-ring-fill"
              strokeDasharray={`${progress.percent}, 100`}
              d="M18 2.0845 a 15.9155 15.9155 0 0 1 0 31.831 a 15.9155 15.9155 0 0 1 0 -31.831"
            />
          </svg>
          <span className="checklist-progress-text">{progress.percent}%</span>
        </div>
        <div className="checklist-progress-label">
          {progress.packed} of {progress.total} packed
        </div>
      </div>

      <div className="checklist-filters">
        {FILTERS.map((f) => (
          <button
            key={f.key}
            type="button"
            className={`checklist-filter ${filter === f.key ? 'active' : ''}`}
            onClick={() => setFilter(f.key)}
          >
            {f.label}
          </button>
        ))}
      </div>

      <div className="checklist-actions">
        <button type="button" className="checklist-add-btn" onClick={() => setShowAdd(true)}>
          + Add Item
        </button>
        <button type="button" className="checklist-reset-btn" onClick={resetAll}>
          Reset All
        </button>
      </div>

      {showAdd && (
        <form className="checklist-add-form" onSubmit={handleAdd}>
          <input
            type="text"
            placeholder="Item name"
            value={newName}
            onChange={(e) => setNewName(e.target.value)}
            required
          />
          <input
            type="text"
            placeholder="Description (optional)"
            value={newDesc}
            onChange={(e) => setNewDesc(e.target.value)}
          />
          <div className="checklist-add-form-btns">
            <button type="button" onClick={() => setShowAdd(false)}>Cancel</button>
            <button type="submit">Add</button>
          </div>
        </form>
      )}

      <div className="checklist-categories">
        {filteredCategories.map(([category, catItems]) => (
          <section key={category} className="checklist-category">
            <h3>{category}</h3>
            {catItems.map((item) => (
              <div
                key={item.id}
                className={`checklist-item ${item.state}`}
                onClick={() => cycleState(item.id)}
              >
                <span className="checklist-item-icon">{STATE_ICONS[item.state]}</span>
                <div className="checklist-item-info">
                  <span className="checklist-item-name">{item.name}</span>
                  <span className="checklist-item-desc">{item.description}</span>
                </div>
              </div>
            ))}
          </section>
        ))}
      </div>
    </PageLayout>
  )
}
