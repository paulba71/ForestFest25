import { Link } from 'react-router-dom'
import './HomePage.css'

const NAV_ITEMS = [
  { to: '/lineup', label: 'View Lineup', icon: '♫', primary: true },
  { to: '/schedule', label: 'My Schedule', icon: '📅' },
  { to: '/timetable', label: 'Timetable', icon: '▦' },
  { to: '/log', label: 'Festival Log', icon: '📷' },
  { to: '/map', label: 'Event Map', icon: '🗺' },
  { to: '/weather', label: 'Weather', icon: '☀' },
  { to: '/checklist', label: 'Packing Checklist', icon: '☑' },
  { to: '/settings', label: 'Settings', icon: '⚙' },
]

export function HomePage() {
  return (
    <div className="home-page">
      <div className="home-content">
        <img
          src="/images/festival-header.png"
          alt="Forest Fest"
          className="home-banner"
        />

        <div className="home-details">
          <h1 className="home-title">Forest Fest 2026</h1>
          <p className="home-date">July 24–26, 2026</p>
          <p className="home-location">Emo Village, Co. Laois</p>
        </div>

        <nav className="home-nav">
          {NAV_ITEMS.map((item) => (
            <Link
              key={item.to}
              to={item.to}
              className={`home-nav-btn ${item.primary ? 'primary' : ''}`}
            >
              <span className="home-nav-icon">{item.icon}</span>
              {item.label}
            </Link>
          ))}
        </nav>
      </div>
    </div>
  )
}
