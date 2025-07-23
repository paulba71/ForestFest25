import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/artist.dart';
import '../models/artist_data.dart';
import '../providers/favorite_manager.dart';

class TimetableView extends StatefulWidget {
  const TimetableView({super.key});

  @override
  State<TimetableView> createState() => _TimetableViewState();
}

class _TimetableViewState extends State<TimetableView> {
  PerformanceDay _selectedDay = PerformanceDay.friday;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Timetable'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Day Selector
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: PerformanceDay.values.map((day) {
                final isSelected = _selectedDay == day;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ElevatedButton(
                      onPressed: () => setState(() => _selectedDay = day),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isSelected
                            ? Colors.purple
                            : Colors.white.withOpacity(0.1),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        day.displayName.split(', ').first,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          
          // Timetable Grid
          Expanded(
            child: TimetableGrid(selectedDay: _selectedDay),
          ),
        ],
      ),
    );
  }
}

class TimetableGrid extends StatelessWidget {
  final PerformanceDay selectedDay;

  const TimetableGrid({super.key, required this.selectedDay});

  @override
  Widget build(BuildContext context) {
    final artists = ArtistData.getArtistsForDay(selectedDay);
    final stages = Stage.values;
    
    // Get time range for the day
    final times = _generateTimeSlots(artists);
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Header row with stage names
              Row(
                children: [
                  // Time column header
                  SizedBox(
                    width: 60,
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Text(
                          'Time',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Stage headers
                  ...stages.map((stage) => Container(
                    width: 120,
                    margin: const EdgeInsets.only(left: 8),
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          stage.displayName.split(' ').first,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  )),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Time slots and events
              ...times.map((time) => _buildTimeRow(context, time, stages, artists)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeRow(BuildContext context, String time, List<Stage> stages, List<Artist> artists) {
    return Row(
      children: [
        // Time label
        SizedBox(
          width: 60,
          child: Text(
            time,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ),
        
        // Stage columns
        ...stages.map((stage) {
          final stageArtists = artists.where((artist) => 
            artist.stage == stage && 
            _isArtistPlayingAtTime(artist, time)
          ).toList();
          
          return Container(
            width: 120,
            height: 60,
            margin: const EdgeInsets.only(left: 8, bottom: 4),
            child: stageArtists.isNotEmpty
                ? _buildEventCard(context, stageArtists.first)
                : Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
          );
        }),
      ],
    );
  }

  Widget _buildEventCard(BuildContext context, Artist artist) {
    return Consumer<FavoriteManager>(
      builder: (context, favoriteManager, child) {
        final isFavorited = favoriteManager.isFavorited(artist);
        final hasClashes = favoriteManager.hasClashes(artist);
        
        return GestureDetector(
          onTap: () => _showArtistDetails(context, artist),
          child: Container(
            decoration: BoxDecoration(
              color: isFavorited 
                  ? Colors.red.withOpacity(0.8)
                  : Colors.purple.withOpacity(0.7),
              borderRadius: BorderRadius.circular(6),
              border: hasClashes
                  ? Border.all(color: Colors.red, width: 2)
                  : null,
            ),
            padding: const EdgeInsets.all(4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        artist.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isFavorited)
                      const Icon(
                        Icons.favorite,
                        color: Colors.white,
                        size: 12,
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${artist.performanceTime} - ${artist.performanceEndTime}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                  ),
                ),
                if (hasClashes)
                  const Icon(
                    Icons.warning,
                    color: Colors.red,
                    size: 10,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<String> _generateTimeSlots(List<Artist> artists) {
    if (artists.isEmpty) return [];
    
    // Find min and max times
    int minMinutes = artists.map((a) => a.sortableMinutes).reduce((a, b) => a < b ? a : b);
    int maxMinutes = artists.map((a) => _timeToMinutes(a.performanceEndTime)).reduce((a, b) => a > b ? a : b);
    
    // Round to nearest 30 minutes
    minMinutes = (minMinutes ~/ 30) * 30;
    maxMinutes = ((maxMinutes + 29) ~/ 30) * 30;
    
    List<String> times = [];
    for (int minutes = minMinutes; minutes <= maxMinutes; minutes += 30) {
      times.add(_minutesToTimeString(minutes));
    }
    
    return times;
  }

  bool _isArtistPlayingAtTime(Artist artist, String time) {
    final timeMinutes = _timeToMinutes(time);
    final startMinutes = artist.sortableMinutes;
    final endMinutes = _timeToMinutes(artist.performanceEndTime);
    
    return timeMinutes >= startMinutes && timeMinutes < endMinutes;
  }

  int _timeToMinutes(String timeString) {
    final parts = timeString.split(':');
    if (parts.length != 2) return 0;
    
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = int.tryParse(parts[1]) ?? 0;
    
    // Handle midnight crossing (00:00-05:00 treated as 24-29 hours)
    final adjustedHour = (hour >= 0 && hour <= 5) ? hour + 24 : hour;
    return adjustedHour * 60 + minute;
  }

  String _minutesToTimeString(int minutes) {
    final hour = (minutes ~/ 60) % 24;
    final minute = minutes % 60;
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  void _showArtistDetails(BuildContext context, Artist artist) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF210B5C),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.purple.withOpacity(0.3),
                  child: Text(
                    artist.name.split(' ').map((e) => e[0]).join(''),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        artist.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        artist.stage.displayName,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Consumer<FavoriteManager>(
                  builder: (context, favoriteManager, child) {
                    return IconButton(
                      icon: Icon(
                        favoriteManager.isFavorited(artist) ? Icons.favorite : Icons.favorite_border,
                        color: favoriteManager.isFavorited(artist) ? Colors.red : Colors.white,
                        size: 28,
                      ),
                      onPressed: () {
                        favoriteManager.toggleFavorite(artist);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Performance Details
            _buildDetailRow('Date', artist.performanceDay.displayName),
            _buildDetailRow('Time', '${artist.performanceTime} - ${artist.performanceEndTime}'),
            _buildDetailRow('Duration', artist.duration),
            
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
} 