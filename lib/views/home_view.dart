import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'lineup_view.dart';
import 'my_schedule_view.dart';
import 'timetable_view.dart';
import 'weather_view.dart';
import 'event_map_view.dart';
import 'settings_view.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF210B5C),
              Color(0xFF4A148C),
              Color(0xFF7B1FA2),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  
                  // Festival Logo/Header
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.forest,
                          size: 60,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'FOREST FEST',
                          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Music & Arts Weekend',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'July 25-27, 2025',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Emo Village, Co. Laois',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Navigation Buttons
                  Column(
                    children: [
                      _buildNavigationButton(
                        context,
                        icon: Icons.music_note,
                        title: 'View Lineup',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const LineupView()),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      _buildNavigationButton(
                        context,
                        icon: Icons.calendar_today,
                        title: 'My Schedule',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const MyScheduleView()),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      _buildNavigationButton(
                        context,
                        icon: Icons.table_chart,
                        title: 'Timetable',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const TimetableView()),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      _buildNavigationButton(
                        context,
                        icon: Icons.map,
                        title: 'Event Map',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const EventMapView()),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      _buildNavigationButton(
                        context,
                        icon: Icons.cloud_sun,
                        title: 'Weather',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const WeatherView()),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      _buildNavigationButton(
                        context,
                        icon: Icons.settings,
                        title: 'Settings',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SettingsView()),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Get Tickets Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _launchURL('https://forestfest.ie/tickets'),
                          icon: const Icon(Icons.ticket),
                          label: const Text(
                            'Get Tickets',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Social Media Links
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildSocialButton(
                        icon: Icons.facebook,
                        onTap: () => _launchURL('https://facebook.com/forestfest'),
                      ),
                      const SizedBox(width: 20),
                      _buildSocialButton(
                        icon: Icons.music_note,
                        onTap: () => _launchURL('https://spotify.com'),
                      ),
                      const SizedBox(width: 20),
                      _buildSocialButton(
                        icon: Icons.camera_alt,
                        onTap: () => _launchURL('https://instagram.com/forestfest'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 24),
        label: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white.withOpacity(0.2),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(25),
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }
} 