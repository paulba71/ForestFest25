import { BrowserRouter, Routes, Route } from 'react-router-dom'
import { FavoritesProvider } from './context/FavoritesContext'
import { HomePage } from './pages/HomePage'
import { LineupPage } from './pages/LineupPage'
import { SchedulePage } from './pages/SchedulePage'
import { TimetablePage } from './pages/TimetablePage'
import { MapPage } from './pages/MapPage'
import { WeatherPage } from './pages/WeatherPage'
import { ChecklistPage } from './pages/ChecklistPage'
import { SettingsPage } from './pages/SettingsPage'
import { FestivalLogPage } from './pages/FestivalLogPage'

export function App() {
  return (
    <FavoritesProvider>
      <BrowserRouter>
        <Routes>
          <Route path="/" element={<HomePage />} />
          <Route path="/lineup" element={<LineupPage />} />
          <Route path="/schedule" element={<SchedulePage />} />
          <Route path="/timetable" element={<TimetablePage />} />
          <Route path="/map" element={<MapPage />} />
          <Route path="/weather" element={<WeatherPage />} />
          <Route path="/checklist" element={<ChecklistPage />} />
          <Route path="/log" element={<FestivalLogPage />} />
          <Route path="/settings" element={<SettingsPage />} />
        </Routes>
      </BrowserRouter>
    </FavoritesProvider>
  )
}
