# Forest Fest Web

A cross-platform web companion for [Forest Fest 2026](https://forestfest.ie) — works on iOS, Android, and desktop browsers.

Converted from the native iOS SwiftUI app.

## Features

- **Lineup** — browse 134 performances across 6 stages with day/stage filters
- **My Schedule** — personal schedule from favorited artists with clash detection
- **Timetable** — scrollable grid view of the full festival schedule
- **Event Map** — embedded official site map
- **Weather** — 3-day forecast for Emo Village (via OpenWeatherMap)
- **Packing Checklist** — 50+ default items with progress tracking
- **Settings** — browser notifications, export favorites

## Quick Start

```bash
cd forest-fest-web
npm install
npm run dev
```

Open http://localhost:5173

## Deploy to Netlify

1. Set environment variable `OPENWEATHER_API_KEY` in the Netlify dashboard
2. Deploy the `forest-fest-web` directory (or set base directory in site settings)

```bash
npx netlify deploy --prod
```

## Weather API

The weather endpoint proxies OpenWeatherMap through a Netlify Function to keep the API key server-side. For local development, run `netlify dev` instead of `npm run dev` to test the weather function, or set `OPENWEATHER_API_KEY` and use Netlify CLI.

## Tech Stack

- React 19 + TypeScript
- Vite
- React Router
- localStorage for favorites, checklist, and settings
- Netlify Functions for weather API proxy
