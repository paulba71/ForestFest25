# Weather API Setup Guide

## Getting Real Weather Data for Forest Fest 2025

The Forest Fest app now supports real weather data from OpenWeatherMap API specifically for the festival weekend (July 25-27, 2025).

### 1. Get Your Free API Key

1. Go to [OpenWeatherMap API](https://openweathermap.org/api)
2. Click "Sign Up" or "Sign In"
3. After signing in, go to "My API Keys"
4. Copy your API key (it looks like: `1234567890abcdef1234567890abcdef`)

### 2. Add Your API Key

1. Open `Forest Fest/WeatherService.swift`
2. Find this line:
   ```swift
   private let apiKey = "YOUR_API_KEY"
   ```
3. Replace `"YOUR_API_KEY"` with your actual API key:
   ```swift
   private let apiKey = "1234567890abcdef1234567890abcdef"
   ```

### 3. Test the Weather

1. Build and run the app
2. Navigate to the Weather section
3. Tap the refresh button
4. You should now see real weather data for Forest Fest weekend!

### What You'll Get

- **Real 3-day forecast** for Forest Fest weekend (July 25-27, 2025)
- **Actual temperatures** and conditions for Emo Village
- **Hourly breakdowns** based on real data
- **Automatic updates** when you refresh

### Festival Dates

The weather data is specifically for:
- **Friday, July 25, 2025**
- **Saturday, July 26, 2025** 
- **Sunday, July 27, 2025**

### Free Tier Limits

- 1,000 API calls per day (more than enough for testing)
- 5-day forecast data
- 3-hour intervals

### Fallback Mode

If you don't add an API key, the app will show sample data for the festival dates with a note that real weather data is unavailable.

### Location

The weather data is specifically for Emo Village, Co. Laois (coordinates: 53.0869, -7.3375) where Forest Fest takes place. 