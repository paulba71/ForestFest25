import SwiftUI

struct WeatherView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var weatherService = WeatherService()
    
    var body: some View {
        VStack(spacing: 0) {
            // Custom Navigation Bar
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.white)
                        .imageScale(.large)
                }
                
                Spacer()
                
                Text("Weather Forecast")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: {
                    weatherService.fetchWeatherData()
                }) {
                    Image(systemName: "arrow.clockwise")
                        .foregroundColor(.white)
                        .imageScale(.large)
                        .rotationEffect(.degrees(weatherService.isLoading ? 360 : 0))
                        .animation(weatherService.isLoading ? Animation.linear(duration: 1).repeatForever(autoreverses: false) : .default, value: weatherService.isLoading)
                }
                .disabled(weatherService.isLoading)
            }
            .padding()
            .background(Color.black.opacity(0.2))
            
            if weatherService.isLoading {
                // Loading View
                VStack(spacing: 20) {
                    Spacer()
                    
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)
                    
                    Text("Fetching weather data...")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Spacer()
                }
            } else if let errorMessage = weatherService.errorMessage {
                // Error View
                VStack(spacing: 20) {
                    Spacer()
                    
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.orange)
                    
                    Text("Weather Unavailable")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text(errorMessage)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Button("Try Again") {
                        weatherService.fetchWeatherData()
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(8)
                    
                    Spacer()
                }
            } else {
                // Weather Content
                ScrollView {
                    VStack(spacing: 20) {
                        // Location Header
                        VStack(spacing: 8) {
                            Text("Emo Village, Co. Laois")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            
                            Text("Forest Fest 2025 - July 25-27")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                            
                            Text("Last updated: \(weatherService.lastUpdated.map { DateFormatter.localizedString(from: $0, dateStyle: .short, timeStyle: .short) } ?? "Never")")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.6))
                                .padding(.top, 4)
                        }
                        .padding(.top)
                        
                        // Daily Forecast Summary
                        VStack(alignment: .leading, spacing: 16) {
                            Text("3-Day Forecast")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.horizontal)
                            
                            ForEach(weatherService.weatherData, id: \.date) { day in
                                DailySummaryCard(dayWeather: day)
                            }
                        }
                        
                        // Hourly Forecast Details
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Hourly Forecast")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.horizontal)
                            
                            ForEach(weatherService.weatherData, id: \.date) { day in
                                HourlyForecastCard(dayWeather: day)
                            }
                        }
                        
                        // Weather Tips
                        WeatherTipsCard(weatherData: weatherService.weatherData)
                        
                        Spacer(minLength: 20)
                    }
                    .padding()
                }
            }
        }
        .background(Color(red: 0.13, green: 0.05, blue: 0.3))
        .navigationBarHidden(true)
        .onAppear {
            if weatherService.weatherData.isEmpty {
                weatherService.fetchWeatherData()
            }
        }
    }
}

struct DayWeather {
    let date: String
    let dayOfWeek: String
    let highTemp: Int
    let lowTemp: Int
    let condition: String
    let icon: String
    let hourlyForecast: [HourlyWeather]
}

struct HourlyWeather {
    let time: String
    let temp: Int
    let condition: String
    let icon: String
}

struct DailySummaryCard: View {
    let dayWeather: DayWeather
    
    var body: some View {
        HStack(spacing: 16) {
            // Day and Date
            VStack(alignment: .leading, spacing: 4) {
                Text(dayWeather.dayOfWeek)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text(dayWeather.date.replacingOccurrences(of: dayWeather.dayOfWeek + ", ", with: ""))
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
            }
            .frame(width: 80, alignment: .leading)
            
            // Weather Icon
            Image(systemName: dayWeather.icon)
                .font(.title2)
                .foregroundColor(.white)
                .frame(width: 40)
            
            // Condition
            Text(dayWeather.condition)
                .font(.subheadline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Temperature Range
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(dayWeather.highTemp)°")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("\(dayWeather.lowTemp)°")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

struct HourlyForecastCard: View {
    let dayWeather: DayWeather
    @State private var isExpanded = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    Text(dayWeather.dayOfWeek)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.white.opacity(0.7))
                        .font(.caption)
                }
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(12)
            }
            .padding(.horizontal)
            
            // Hourly Details
            if isExpanded {
                VStack(spacing: 8) {
                    ForEach(dayWeather.hourlyForecast, id: \.time) { hour in
                        HStack(spacing: 16) {
                            Text(hour.time)
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                                .frame(width: 50, alignment: .leading)
                            
                            Image(systemName: hour.icon)
                                .font(.subheadline)
                                .foregroundColor(.white)
                                .frame(width: 30)
                            
                            Text(hour.condition)
                                .font(.subheadline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Text("\(hour.temp)°")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                    }
                }
                .padding(.vertical, 8)
                .background(Color.black.opacity(0.2))
                .cornerRadius(8)
                .padding(.horizontal)
                .padding(.top, 4)
            }
        }
    }
}

struct WeatherTipsCard: View {
    let weatherData: [DayWeather]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.yellow)
                    .font(.title3)
                
                Text("Festival Weather Tips")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(generateWeatherTips(), id: \.self) { tip in
                    WeatherTipView(tip: tip)
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    private func generateWeatherTips() -> [WeatherTip] {
        var tips: [WeatherTip] = []
        
        // Analyze weather data
        let allTemps = weatherData.flatMap { day in
            day.hourlyForecast.map { $0.temp }
        }
        let allConditions = weatherData.flatMap { day in
            day.hourlyForecast.map { $0.condition.lowercased() }
        }
        
        let maxTemp = allTemps.max() ?? 0
        let minTemp = allTemps.min() ?? 0
        let hasRain = allConditions.contains { $0.contains("rain") || $0.contains("drizzle") }
        let hasSunny = allConditions.contains { $0.contains("clear") || $0.contains("sun") }
        let hasCold = minTemp < 10
        let hasHot = maxTemp > 25
        let tempRange = maxTemp - minTemp
        
        // Temperature-based tips
        if hasHot {
            tips.append(WeatherTip(icon: "thermometer.sun.fill", text: "High temperatures expected - stay hydrated and seek shade"))
        }
        
        if hasCold {
            tips.append(WeatherTip(icon: "thermometer.snowflake", text: "Cold evenings ahead - bring warm layers"))
        }
        
        if tempRange > 8 {
            tips.append(WeatherTip(icon: "thermometer", text: "Large temperature swings - dress in layers"))
        }
        
        // Rain-based tips
        if hasRain {
            tips.append(WeatherTip(icon: "umbrella.fill", text: "Rain expected - pack waterproof gear"))
        }
        
        // Sun-based tips
        if hasSunny {
            tips.append(WeatherTip(icon: "sun.max.fill", text: "Sunny periods - don't forget sunscreen"))
        }
        
        // General festival tips
        tips.append(WeatherTip(icon: "water.waves", text: "Stay hydrated throughout the festival"))
        
        // Add specific day tips
        for day in weatherData {
            if day.condition.lowercased().contains("rain") {
                tips.append(WeatherTip(icon: "calendar.badge.exclamationmark", text: "\(day.dayOfWeek): Rain expected - plan indoor activities"))
            }
            
            if day.highTemp > 20 {
                tips.append(WeatherTip(icon: "calendar.badge.plus", text: "\(day.dayOfWeek): Warm weather - perfect for outdoor stages"))
            }
            
            // Check for evening temperature drops
            let eveningTemps = day.hourlyForecast.filter { hour in
                let hourInt = Int(hour.time.prefix(2)) ?? 12
                return hourInt >= 20 || hourInt <= 6
            }.map { $0.temp }
            
            if let eveningMin = eveningTemps.min(), eveningMin < 12 {
                tips.append(WeatherTip(icon: "moon.fill", text: "\(day.dayOfWeek): Cool evenings - bring a jacket"))
            }
        }
        
        // Weather pattern analysis
        let rainyDays = weatherData.filter { $0.condition.lowercased().contains("rain") }.count
        if rainyDays >= 2 {
            tips.append(WeatherTip(icon: "cloud.rain.fill", text: "Multiple rainy days - consider waterproof footwear"))
        }
        
        let sunnyDays = weatherData.filter { $0.condition.lowercased().contains("clear") || $0.condition.lowercased().contains("sun") }.count
        if sunnyDays >= 2 {
            tips.append(WeatherTip(icon: "sun.max.fill", text: "Mostly sunny weekend - perfect festival weather!"))
        }
        
        // Limit to 6 tips to avoid overwhelming
        return Array(tips.prefix(6))
    }
}

struct WeatherTip: Hashable {
    let icon: String
    let text: String
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(text)
    }
    
    static func == (lhs: WeatherTip, rhs: WeatherTip) -> Bool {
        return lhs.text == rhs.text
    }
}

struct WeatherTipView: View {
    let tip: WeatherTip
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: tip.icon)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
                .frame(width: 20)
            
            Text(tip.text)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.9))
        }
    }
}

#Preview {
    WeatherView()
} 