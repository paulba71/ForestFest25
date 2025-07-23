import Foundation
import Combine

class WeatherService: ObservableObject {
    @Published var weatherData: [DayWeather] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var lastUpdated: Date?
    
    private var cancellables = Set<AnyCancellable>()
    
    // Using OpenWeatherMap API (free tier)
    // Get your free API key from: https://openweathermap.org/api
    private let apiKey = "f44ab8b9afbc01cd00b37dd0025cb3a8"
    private let baseURL = "https://api.openweathermap.org/data/2.5"
    
    // Emo, Co. Laois coordinates
    private let latitude = 53.0869
    private let longitude = -7.3375
    
    // Forest Fest 2025 dates
    private let festivalDates = [
        "2025-07-25", // Friday
        "2025-07-26", // Saturday  
        "2025-07-27"  // Sunday
    ]
    
    init() {
        // Always try to fetch real weather data
        fetchWeatherData()
    }
    
    func fetchWeatherData() {
        isLoading = true
        errorMessage = nil
        
        // Always fetch real weather data
        fetchFromAPI()
    }
    
    private func fetchFromAPI() {
        let urlString = "\(baseURL)/forecast?lat=\(latitude)&lon=\(longitude)&appid=\(apiKey)&units=metric"
        
        guard let url = URL(string: urlString) else {
            errorMessage = "Invalid URL"
            isLoading = false
            return
        }
        
        URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: WeatherResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    self.isLoading = false
                    if case .failure(let error) = completion {
                        self.errorMessage = "Weather data unavailable: \(error.localizedDescription)"
                    }
                },
                receiveValue: { response in
                    self.processWeatherResponse(response)
                    self.lastUpdated = Date()
                }
            )
            .store(in: &cancellables)
    }
    
    private func processWeatherResponse(_ response: WeatherResponse) {
        print("🌤️ Weather API Response received with \(response.list.count) forecast points")
        
        // Group forecast data by day
        var dailyData: [String: [WeatherItem]] = [:]
        
        for item in response.list {
            let date = Date(timeIntervalSince1970: item.dt)
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let dayKey = formatter.string(from: date)
            
            if dailyData[dayKey] == nil {
                dailyData[dayKey] = []
            }
            dailyData[dayKey]?.append(item)
        }
        
        print("📅 Grouped data by day: \(dailyData.keys.sorted())")
        
        // Convert to our DayWeather format for Forest Fest dates
        weatherData = festivalDates.compactMap { festivalDate in
            guard let dayItems = dailyData[festivalDate], !dayItems.isEmpty else { 
                print("❌ No data for festival date: \(festivalDate)")
                return nil 
            }
            
            print("✅ Found \(dayItems.count) forecast points for \(festivalDate)")
            
            // Calculate daily stats
            let temps = dayItems.map { $0.main.temp }
            let highTemp = Int(round(temps.max() ?? 0))
            let lowTemp = Int(round(temps.min() ?? 0))
            
            // Get most common weather condition for the day
            let conditions = dayItems.map { $0.weather.first?.main ?? "Clear" }
            let mostCommonCondition = getPrimaryCondition(from: conditions)
            
            print("🌡️ \(festivalDate): High \(highTemp)°C, Low \(lowTemp)°C, Condition: \(mostCommonCondition)")
            
            // Format date strings
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            guard let date = formatter.date(from: festivalDate) else { return nil }
            
            formatter.dateFormat = "EEEE, MMMM d"
            let dateString = formatter.string(from: date)
            
            formatter.dateFormat = "EEEE"
            let dayOfWeek = formatter.string(from: date)
            
            // Generate hourly forecast from 3-hour intervals
            let hourlyForecast = generateHourlyForecast(from: dayItems)
            
            return DayWeather(
                date: dateString,
                dayOfWeek: dayOfWeek,
                highTemp: highTemp,
                lowTemp: lowTemp,
                condition: mostCommonCondition,
                icon: iconForCondition(mostCommonCondition),
                hourlyForecast: hourlyForecast
            )
        }
        
        // If we don't have data for festival dates, show appropriate message
        if weatherData.isEmpty {
            errorMessage = "Weather forecast not available for Forest Fest dates (July 25-27, 2025).\n\nThe free weather API only provides 5-day forecasts. For festival planning, check closer to the event date or use a premium weather service."
        }
    }
    
    private func generateHourlyForecast(from dayItems: [WeatherItem]) -> [HourlyWeather] {
        print("🕐 Generating hourly forecast from \(dayItems.count) weather items")
        
        // Use the actual API data times, sorted chronologically
        let hourlyData = dayItems.sorted { item1, item2 in
            item1.dt < item2.dt
        }.map { item in
            let date = Date(timeIntervalSince1970: item.dt)
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            let timeString = formatter.string(from: date)
            
            let condition = item.weather.first?.main ?? "Clear"
            
            print("  \(timeString): \(condition) at \(Int(round(item.main.temp)))°C")
            
            return HourlyWeather(
                time: timeString,
                temp: Int(round(item.main.temp)),
                condition: condition,
                icon: iconForCondition(condition)
            )
        }
        
        print("✅ Generated \(hourlyData.count) hourly forecast entries")
        return hourlyData
    }
    
    private func iconForCondition(_ condition: String) -> String {
        let lowerCondition = condition.lowercased()
        
        // More specific condition mapping to prevent fluctuations
        switch lowerCondition {
        case let c where c.contains("clear"):
            return "sun.max.fill"
        case let c where c.contains("clouds") && !c.contains("rain") && !c.contains("snow"):
            return "cloud.fill"
        case let c where c.contains("rain") && !c.contains("drizzle"):
            return "cloud.rain.fill"
        case let c where c.contains("drizzle"):
            return "cloud.drizzle.fill"
        case let c where c.contains("snow"):
            return "cloud.snow.fill"
        case let c where c.contains("thunderstorm"):
            return "cloud.bolt.fill"
        case let c where c.contains("mist") || c.contains("fog"):
            return "cloud.fog.fill"
        case let c where c.contains("haze") || c.contains("smoke"):
            return "cloud.fog.fill"
        default:
            // Default fallback based on common patterns
            if lowerCondition.contains("cloud") {
                return "cloud.fill"
            } else if lowerCondition.contains("rain") {
                return "cloud.rain.fill"
            } else {
                return "cloud.sun.fill"
            }
        }
    }
    
    private func getPrimaryCondition(from conditions: [String]) -> String {
        // Count occurrences of each condition
        let conditionCounts = conditions.reduce(into: [:]) { counts, condition in
            counts[condition, default: 0] += 1
        }
        
        print("📊 Condition counts: \(conditionCounts)")
        
        // Find the maximum count
        guard let maxCount = conditionCounts.values.max() else { return "Clear" }
        
        // Get all conditions with the maximum count
        let mostFrequentConditions = conditionCounts.filter { $0.value == maxCount }.keys
        
        // If there's only one most frequent condition, return it
        if mostFrequentConditions.count == 1 {
            return mostFrequentConditions.first!
        }
        
        // If there are ties, prioritize by significance (Rain > Clouds > Clear)
        let priorityOrder = ["Rain", "Drizzle", "Thunderstorm", "Snow", "Clouds", "Clear"]
        
        for priorityCondition in priorityOrder {
            if mostFrequentConditions.contains(priorityCondition) {
                print("🎯 Chose \(priorityCondition) from tie: \(mostFrequentConditions)")
                return priorityCondition
            }
        }
        
        // Fallback to the first condition if none match priority order
        return mostFrequentConditions.first ?? "Clear"
    }
}

// API Response models
struct WeatherResponse: Codable {
    let list: [WeatherItem]
}

struct WeatherItem: Codable {
    let dt: TimeInterval
    let main: MainWeather
    let weather: [WeatherCondition]
}

struct MainWeather: Codable {
    let temp: Double
    let temp_min: Double
    let temp_max: Double
}

struct WeatherCondition: Codable {
    let main: String
    let description: String
    let icon: String
}

// Helper extension
extension Array where Element: Hashable {
    func mostFrequent() -> Element? {
        let counts = self.reduce(into: [:]) { counts, element in
            counts[element, default: 0] += 1
        }
        return counts.max(by: { $0.value < $1.value })?.key
    }
} 