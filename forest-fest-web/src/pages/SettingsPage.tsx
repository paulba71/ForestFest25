import { useFavorites } from '../context/FavoritesContext'
import { useSettings } from '../hooks/useSettings'
import { PageLayout } from '../components/PageLayout'
import './SettingsPage.css'

const REMINDER_OPTIONS = [15, 30, 45, 60, 90, 120]

export function SettingsPage() {
  const { favoritedIds, clearAll } = useFavorites()
  const {
    notificationsEnabled,
    reminderTime,
    setReminderTime,
    enableNotifications,
    disableNotifications,
  } = useSettings()

  async function handleNotificationToggle() {
    if (notificationsEnabled) {
      disableNotifications()
    } else {
      await enableNotifications()
    }
  }

  function exportFavorites() {
    const data = JSON.stringify(favoritedIds, null, 2)
    const blob = new Blob([data], { type: 'application/json' })
    const url = URL.createObjectURL(blob)
    const a = document.createElement('a')
    a.href = url
    a.download = 'forest-fest-favorites.json'
    a.click()
    URL.revokeObjectURL(url)
  }

  return (
    <PageLayout title="Settings">
      <div className="settings-content">
        <section className="settings-section">
          <h2>Notifications</h2>
          <label className="settings-toggle">
            <span>Enable performance reminders</span>
            <input
              type="checkbox"
              checked={notificationsEnabled}
              onChange={handleNotificationToggle}
            />
          </label>
          {notificationsEnabled && (
            <div className="settings-field">
              <label htmlFor="reminder-time">Remind me before performances</label>
              <select
                id="reminder-time"
                value={reminderTime}
                onChange={(e) => setReminderTime(parseInt(e.target.value, 10))}
              >
                {REMINDER_OPTIONS.map((mins) => (
                  <option key={mins} value={mins}>
                    {mins} minutes
                  </option>
                ))}
              </select>
            </div>
          )}
          <p className="settings-hint">
            Browser notifications remind you before favorited performances and alert you to schedule conflicts.
          </p>
        </section>

        <section className="settings-section">
          <h2>Festival Log</h2>
          <p className="settings-hint">
            Moments are stored privately on this device. Use Export all on the Festival Log to
            share or download every branded photo at once. On iPhone, multi-photo share may offer
            Save Images; otherwise a ZIP downloads to Files.
          </p>
        </section>

        <section className="settings-section">
          <h2>App Info</h2>
          <dl className="settings-info">
            <dt>Version</dt>
            <dd>1.0.0</dd>
            <dt>Festival</dt>
            <dd>Forest Fest 2026</dd>
            <dt>Dates</dt>
            <dd>July 24–26, 2026</dd>
            <dt>Location</dt>
            <dd>Emo Village, Co. Laois</dd>
          </dl>
        </section>

        <section className="settings-section">
          <h2>Data</h2>
          <p className="settings-stat">{favoritedIds.length} favorited artist{favoritedIds.length === 1 ? '' : 's'}</p>
          <div className="settings-actions">
            <button type="button" className="settings-btn" onClick={exportFavorites}>
              Export Favorites
            </button>
            <button
              type="button"
              className="settings-btn danger"
              onClick={() => {
                if (confirm('Remove all favorites?')) clearAll()
              }}
            >
              Clear All Favorites
            </button>
          </div>
        </section>
      </div>
    </PageLayout>
  )
}
