import 'package:flutter/material.dart';

class WeatherView extends StatefulWidget {
  const WeatherView({super.key});

  @override
  State<WeatherView> createState() => _WeatherViewState();
}

class _WeatherViewState extends State<WeatherView> {
  int _selectedDayIndex = 0;

  // Sample weather data for Forest Fest 2025
  final List<DayWeather> _weatherData = [
    DayWeather(
      dayOfWeek: 'Friday',
      date: 'Friday, July 25',
      highTemp: 22,
      lowTemp: 14,
      condition: 'Partly Cloudy',
      icon: 'cloud_sun',
      hourlyForecast: [
        HourlyWeather(time: '12:00', temp: 18, condition: 'Partly Cloudy', icon: 'cloud_sun'),
        HourlyWeather(time: '13:00', temp: 19, condition: 'Partly Cloudy', icon: 'cloud_sun'),
        HourlyWeather(time: '14:00', temp: 20, condition: 'Sunny', icon: 'wb_sunny'),
        HourlyWeather(time: '15:00', temp: 21, condition: 'Sunny', icon: 'wb_sunny'),
        HourlyWeather(time: '16:00', temp: 22, condition: 'Partly Cloudy', icon: 'cloud_sun'),
        HourlyWeather(time: '17:00', temp: 21, condition: 'Partly Cloudy', icon: 'cloud_sun'),
        HourlyWeather(time: '18:00', temp: 20, condition: 'Partly Cloudy', icon: 'cloud_sun'),
        HourlyWeather(time: '19:00', temp: 19, condition: 'Partly Cloudy', icon: 'cloud_sun'),
        HourlyWeather(time: '20:00', temp: 18, condition: 'Partly Cloudy', icon: 'cloud_sun'),
        HourlyWeather(time: '21:00', temp: 17, condition: 'Partly Cloudy', icon: 'cloud_sun'),
        HourlyWeather(time: '22:00', temp: 16, condition: 'Partly Cloudy', icon: 'cloud_sun'),
        HourlyWeather(time: '23:00', temp: 15, condition: 'Partly Cloudy', icon: 'cloud_sun'),
      ],
    ),
    DayWeather(
      dayOfWeek: 'Saturday',
      date: 'Saturday, July 26',
      highTemp: 24,
      lowTemp: 16,
      condition: 'Sunny',
      icon: 'wb_sunny',
      hourlyForecast: [
        HourlyWeather(time: '12:00', temp: 20, condition: 'Sunny', icon: 'wb_sunny'),
        HourlyWeather(time: '13:00', temp: 21, condition: 'Sunny', icon: 'wb_sunny'),
        HourlyWeather(time: '14:00', temp: 22, condition: 'Sunny', icon: 'wb_sunny'),
        HourlyWeather(time: '15:00', temp: 23, condition: 'Sunny', icon: 'wb_sunny'),
        HourlyWeather(time: '16:00', temp: 24, condition: 'Sunny', icon: 'wb_sunny'),
        HourlyWeather(time: '17:00', temp: 23, condition: 'Sunny', icon: 'wb_sunny'),
        HourlyWeather(time: '18:00', temp: 22, condition: 'Partly Cloudy', icon: 'cloud_sun'),
        HourlyWeather(time: '19:00', temp: 21, condition: 'Partly Cloudy', icon: 'cloud_sun'),
        HourlyWeather(time: '20:00', temp: 20, condition: 'Partly Cloudy', icon: 'cloud_sun'),
        HourlyWeather(time: '21:00', temp: 19, condition: 'Partly Cloudy', icon: 'cloud_sun'),
        HourlyWeather(time: '22:00', temp: 18, condition: 'Partly Cloudy', icon: 'cloud_sun'),
        HourlyWeather(time: '23:00', temp: 17, condition: 'Partly Cloudy', icon: 'cloud_sun'),
      ],
    ),
    DayWeather(
      dayOfWeek: 'Sunday',
      date: 'Sunday, July 27',
      highTemp: 20,
      lowTemp: 13,
      condition: 'Light Rain',
      icon: 'rainy',
      hourlyForecast: [
        HourlyWeather(time: '12:00', temp: 17, condition: 'Light Rain', icon: 'rainy'),
        HourlyWeather(time: '13:00', temp: 18, condition: 'Light Rain', icon: 'rainy'),
        HourlyWeather(time: '14:00', temp: 19, condition: 'Light Rain', icon: 'rainy'),
        HourlyWeather(time: '15:00', temp: 20, condition: 'Partly Cloudy', icon: 'cloud_sun'),
        HourlyWeather(time: '16:00', temp: 19, condition: 'Partly Cloudy', icon: 'cloud_sun'),
        HourlyWeather(time: '17:00', temp: 18, condition: 'Partly Cloudy', icon: 'cloud_sun'),
        HourlyWeather(time: '18:00', temp: 17, condition: 'Partly Cloudy', icon: 'cloud_sun'),
        HourlyWeather(time: '19:00', temp: 16, condition: 'Partly Cloudy', icon: 'cloud_sun'),
        HourlyWeather(time: '20:00', temp: 15, condition: 'Partly Cloudy', icon: 'cloud_sun'),
        HourlyWeather(time: '21:00', temp: 14, condition: 'Partly Cloudy', icon: 'cloud_sun'),
        HourlyWeather(time: '22:00', temp: 13, condition: 'Partly Cloudy', icon: 'cloud_sun'),
        HourlyWeather(time: '23:00', temp: 13, condition: 'Partly Cloudy', icon: 'cloud_sun'),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Location Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Icon(
                    Icons.location_on,
                    color: Colors.white,
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Emo Village, Co. Laois',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Forest Fest 2025',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),

            // Daily Summary Cards
            Container(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _weatherData.length,
                itemBuilder: (context, index) {
                  final dayWeather = _weatherData[index];
                  final isSelected = _selectedDayIndex == index;
                  
                  return GestureDetector(
                    onTap: () => setState(() => _selectedDayIndex = index),
                    child: Container(
                      width: 200,
                      margin: const EdgeInsets.only(right: 12),
                      child: DailySummaryCard(
                        dayWeather: dayWeather,
                        isSelected: isSelected,
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            // Selected Day Details
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _getWeatherIcon(_weatherData[_selectedDayIndex].icon),
                        color: Colors.white,
                        size: 32,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _weatherData[_selectedDayIndex].dayOfWeek,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              _weatherData[_selectedDayIndex].condition,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${_weatherData[_selectedDayIndex].highTemp}°',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '${_weatherData[_selectedDayIndex].lowTemp}°',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Hourly Forecast
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Hourly Forecast',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ..._weatherData[_selectedDayIndex].hourlyForecast.map((hourly) => 
                    HourlyForecastItem(hourlyWeather: hourly)
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Festival Weather Tips
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Festival Weather Tips',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildWeatherTip(
                    icon: Icons.wb_sunny,
                    title: 'Sun Protection',
                    description: 'Bring sunscreen, hat, and sunglasses for sunny days',
                  ),
                  _buildWeatherTip(
                    icon: Icons.water_drop,
                    title: 'Stay Hydrated',
                    description: 'Drink plenty of water, especially during warm weather',
                  ),
                  _buildWeatherTip(
                    icon: Icons.umbrella,
                    title: 'Rain Preparedness',
                    description: 'Pack a rain jacket or poncho for potential showers',
                  ),
                  _buildWeatherTip(
                    icon: Icons.nights_stay,
                    title: 'Evening Layers',
                    description: 'Bring warm layers for cooler evening temperatures',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  IconData _getWeatherIcon(String iconName) {
    switch (iconName) {
      case 'wb_sunny':
        return Icons.wb_sunny;
      case 'cloud_sun':
        return Icons.cloud_sun;
      case 'rainy':
        return Icons.rainy;
      case 'cloud':
        return Icons.cloud;
      default:
        return Icons.wb_sunny;
    }
  }

  Widget _buildWeatherTip({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DailySummaryCard extends StatelessWidget {
  final DayWeather dayWeather;
  final bool isSelected;

  const DailySummaryCard({
    super.key,
    required this.dayWeather,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isSelected ? Colors.purple.withOpacity(0.3) : Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: isSelected ? Border.all(color: Colors.purple, width: 2) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            dayWeather.dayOfWeek,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                _getWeatherIcon(dayWeather.icon),
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  dayWeather.condition,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '${dayWeather.highTemp}°',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${dayWeather.lowTemp}°',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getWeatherIcon(String iconName) {
    switch (iconName) {
      case 'wb_sunny':
        return Icons.wb_sunny;
      case 'cloud_sun':
        return Icons.cloud_sun;
      case 'rainy':
        return Icons.rainy;
      case 'cloud':
        return Icons.cloud;
      default:
        return Icons.wb_sunny;
    }
  }
}

class HourlyForecastItem extends StatelessWidget {
  final HourlyWeather hourlyWeather;

  const HourlyForecastItem({
    super.key,
    required this.hourlyWeather,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(
              hourlyWeather.time,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
          Icon(
            _getWeatherIcon(hourlyWeather.icon),
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              hourlyWeather.condition,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
              ),
            ),
          ),
          Text(
            '${hourlyWeather.temp}°',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getWeatherIcon(String iconName) {
    switch (iconName) {
      case 'wb_sunny':
        return Icons.wb_sunny;
      case 'cloud_sun':
        return Icons.cloud_sun;
      case 'rainy':
        return Icons.rainy;
      case 'cloud':
        return Icons.cloud;
      default:
        return Icons.wb_sunny;
    }
  }
}

class DayWeather {
  final String dayOfWeek;
  final String date;
  final int highTemp;
  final int lowTemp;
  final String condition;
  final String icon;
  final List<HourlyWeather> hourlyForecast;

  DayWeather({
    required this.dayOfWeek,
    required this.date,
    required this.highTemp,
    required this.lowTemp,
    required this.condition,
    required this.icon,
    required this.hourlyForecast,
  });
}

class HourlyWeather {
  final String time;
  final int temp;
  final String condition;
  final String icon;

  HourlyWeather({
    required this.time,
    required this.temp,
    required this.condition,
    required this.icon,
  });
} 