import SwiftUI

struct WeatherView: View {
    @Environment(\.presentationMode) var presentationMode
    
    // Sample weather data for Forest Fest weekend (July 25-27, 2025)
    // In a real app, this would come from a weather API
    private let weatherData: [DayWeather] = [
        DayWeather(
            date: "Friday, July 25",
            dayOfWeek: "Friday",
            highTemp: 18,
            lowTemp: 12,
            condition: "Partly Cloudy",
            icon: "cloud.sun.fill",
            hourlyForecast: [
                HourlyWeather(time: "12:00", temp: 15, condition: "Cloudy", icon: "cloud.fill"),
                HourlyWeather(time: "13:00", temp: 16, condition: "Partly Cloudy", icon: "cloud.sun.fill"),
                HourlyWeather(time: "14:00", temp: 17, condition: "Partly Cloudy", icon: "cloud.sun.fill"),
                HourlyWeather(time: "15:00", temp: 17, condition: "Sunny", icon: "sun.max.fill"),
                HourlyWeather(time: "16:00", temp: 18, condition: "Sunny", icon: "sun.max.fill"),
                HourlyWeather(time: "17:00", temp: 17, condition: "Partly Cloudy", icon: "cloud.sun.fill"),
                HourlyWeather(time: "18:00", temp: 16, condition: "Partly Cloudy", icon: "cloud.sun.fill"),
                HourlyWeather(time: "19:00", temp: 15, condition: "Cloudy", icon: "cloud.fill"),
                HourlyWeather(time: "20:00", temp: 14, condition: "Cloudy", icon: "cloud.fill"),
                HourlyWeather(time: "21:00", temp: 13, condition: "Partly Cloudy", icon: "cloud.moon.fill"),
                HourlyWeather(time: "22:00", temp: 12, condition: "Clear", icon: "moon.fill"),
                HourlyWeather(time: "23:00", temp: 12, condition: "Clear", icon: "moon.fill"),
                HourlyWeather(time: "00:00", temp: 11, condition: "Clear", icon: "moon.fill"),
                HourlyWeather(time: "01:00", temp: 11, condition: "Clear", icon: "moon.fill"),
                HourlyWeather(time: "02:00", temp: 10, condition: "Clear", icon: "moon.fill")
            ]
        ),
        DayWeather(
            date: "Saturday, July 26",
            dayOfWeek: "Saturday",
            highTemp: 20,
            lowTemp: 13,
            condition: "Sunny",
            icon: "sun.max.fill",
            hourlyForecast: [
                HourlyWeather(time: "12:00", temp: 16, condition: "Sunny", icon: "sun.max.fill"),
                HourlyWeather(time: "13:00", temp: 17, condition: "Sunny", icon: "sun.max.fill"),
                HourlyWeather(time: "14:00", temp: 18, condition: "Sunny", icon: "sun.max.fill"),
                HourlyWeather(time: "15:00", temp: 19, condition: "Sunny", icon: "sun.max.fill"),
                HourlyWeather(time: "16:00", temp: 20, condition: "Sunny", icon: "sun.max.fill"),
                HourlyWeather(time: "17:00", temp: 19, condition: "Partly Cloudy", icon: "cloud.sun.fill"),
                HourlyWeather(time: "18:00", temp: 18, condition: "Partly Cloudy", icon: "cloud.sun.fill"),
                HourlyWeather(time: "19:00", temp: 17, condition: "Partly Cloudy", icon: "cloud.sun.fill"),
                HourlyWeather(time: "20:00", temp: 16, condition: "Partly Cloudy", icon: "cloud.sun.fill"),
                HourlyWeather(time: "21:00", temp: 15, condition: "Clear", icon: "moon.fill"),
                HourlyWeather(time: "22:00", temp: 14, condition: "Clear", icon: "moon.fill"),
                HourlyWeather(time: "23:00", temp: 13, condition: "Clear", icon: "moon.fill"),
                HourlyWeather(time: "00:00", temp: 13, condition: "Clear", icon: "moon.fill"),
                HourlyWeather(time: "01:00", temp: 13, condition: "Clear", icon: "moon.fill"),
                HourlyWeather(time: "02:00", temp: 12, condition: "Clear", icon: "moon.fill")
            ]
        ),
        DayWeather(
            date: "Sunday, July 27",
            dayOfWeek: "Sunday",
            highTemp: 19,
            lowTemp: 11,
            condition: "Light Rain",
            icon: "cloud.rain.fill",
            hourlyForecast: [
                HourlyWeather(time: "12:00", temp: 15, condition: "Light Rain", icon: "cloud.rain.fill"),
                HourlyWeather(time: "13:00", temp: 16, condition: "Light Rain", icon: "cloud.rain.fill"),
                HourlyWeather(time: "14:00", temp: 17, condition: "Partly Cloudy", icon: "cloud.sun.fill"),
                HourlyWeather(time: "15:00", temp: 18, condition: "Partly Cloudy", icon: "cloud.sun.fill"),
                HourlyWeather(time: "16:00", temp: 19, condition: "Partly Cloudy", icon: "cloud.sun.fill"),
                HourlyWeather(time: "17:00", temp: 18, condition: "Partly Cloudy", icon: "cloud.sun.fill"),
                HourlyWeather(time: "18:00", temp: 17, condition: "Cloudy", icon: "cloud.fill"),
                HourlyWeather(time: "19:00", temp: 16, condition: "Light Rain", icon: "cloud.rain.fill"),
                HourlyWeather(time: "20:00", temp: 15, condition: "Light Rain", icon: "cloud.rain.fill"),
                HourlyWeather(time: "21:00", temp: 14, condition: "Cloudy", icon: "cloud.fill"),
                HourlyWeather(time: "22:00", temp: 13, condition: "Partly Cloudy", icon: "cloud.moon.fill"),
                HourlyWeather(time: "23:00", temp: 12, condition: "Partly Cloudy", icon: "cloud.moon.fill"),
                HourlyWeather(time: "00:00", temp: 11, condition: "Clear", icon: "moon.fill"),
                HourlyWeather(time: "01:00", temp: 11, condition: "Clear", icon: "moon.fill"),
                HourlyWeather(time: "02:00", temp: 11, condition: "Clear", icon: "moon.fill")
            ]
        )
    ]
    
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
                    // Refresh weather data
                }) {
                    Image(systemName: "arrow.clockwise")
                        .foregroundColor(.white)
                        .imageScale(.large)
                }
            }
            .padding()
            .background(Color.black.opacity(0.2))
            
            ScrollView {
                VStack(spacing: 20) {
                    // Location Header
                    VStack(spacing: 8) {
                        Text("Emo Village, Co. Laois")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        Text("Forest Fest 2025")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding(.top)
                    
                    // Daily Forecast Summary
                    VStack(alignment: .leading, spacing: 16) {
                        Text("3-Day Forecast")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal)
                        
                        ForEach(weatherData, id: \.date) { day in
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
                        
                        ForEach(weatherData, id: \.date) { day in
                            HourlyForecastCard(dayWeather: day)
                        }
                    }
                    
                    // Weather Tips
                    WeatherTipsCard()
                    
                    Spacer(minLength: 20)
                }
                .padding()
            }
        }
        .background(Color(red: 0.13, green: 0.05, blue: 0.3))
        .navigationBarHidden(true)
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
                WeatherTip(icon: "umbrella.fill", text: "Pack a light rain jacket for Sunday")
                WeatherTip(icon: "sun.max.fill", text: "Don't forget sunscreen for Saturday")
                WeatherTip(icon: "thermometer", text: "Evenings can be cool - bring layers")
                WeatherTip(icon: "water.waves", text: "Stay hydrated throughout the day")
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

struct WeatherTip: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
                .frame(width: 20)
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.9))
        }
    }
}

#Preview {
    WeatherView()
} 