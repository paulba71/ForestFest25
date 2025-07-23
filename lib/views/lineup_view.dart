import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/artist.dart';
import '../models/artist_data.dart';
import '../providers/favorite_manager.dart';

class LineupView extends StatefulWidget {
  const LineupView({super.key});

  @override
  State<LineupView> createState() => _LineupViewState();
}

class _LineupViewState extends State<LineupView> {
  String _searchQuery = '';
  PerformanceDay? _selectedDay;
  Stage? _selectedStage;

  List<Artist> get _filteredArtists {
    List<Artist> artists = ArtistData.allArtists;

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      artists = artists.where((artist) =>
          artist.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }

    // Filter by day
    if (_selectedDay != null) {
      artists = artists.where((artist) => artist.performanceDay == _selectedDay).toList();
    }

    // Filter by stage
    if (_selectedStage != null) {
      artists = artists.where((artist) => artist.stage == _selectedStage).toList();
    }

    // Sort by day and time
    artists.sort((a, b) {
      final dayComparison = a.performanceDay.index.compareTo(b.performanceDay.index);
      if (dayComparison != 0) return dayComparison;
      return a.sortableMinutes.compareTo(b.sortableMinutes);
    });

    return artists;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lineup'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Consumer<FavoriteManager>(
            builder: (context, favoriteManager, child) {
              final favoriteCount = favoriteManager.favoritedArtists.length;
              return favoriteCount > 0
                  ? Container(
                      margin: const EdgeInsets.only(right: 16),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$favoriteCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: InputDecoration(
                    hintText: 'Search artists...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 16),
                
                // Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // Day Filters
                      ...PerformanceDay.values.map((day) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(day.displayName.split(', ').first),
                          selected: _selectedDay == day,
                          onSelected: (selected) {
                            setState(() {
                              _selectedDay = selected ? day : null;
                            });
                          },
                          backgroundColor: Colors.white.withOpacity(0.1),
                          selectedColor: Colors.purple.withOpacity(0.3),
                          labelStyle: TextStyle(
                            color: _selectedDay == day ? Colors.white : Colors.white70,
                          ),
                        ),
                      )),
                      
                      const SizedBox(width: 16),
                      
                      // Stage Filters
                      ...Stage.values.map((stage) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(stage.displayName.split(' ').first),
                          selected: _selectedStage == stage,
                          onSelected: (selected) {
                            setState(() {
                              _selectedStage = selected ? stage : null;
                            });
                          },
                          backgroundColor: Colors.white.withOpacity(0.1),
                          selectedColor: Colors.purple.withOpacity(0.3),
                          labelStyle: TextStyle(
                            color: _selectedStage == stage ? Colors.white : Colors.white70,
                          ),
                        ),
                      )),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Artists List
          Expanded(
            child: _filteredArtists.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.white54,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No artists found',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white54,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filteredArtists.length,
                    itemBuilder: (context, index) {
                      final artist = _filteredArtists[index];
                      return ArtistCard(artist: artist);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class ArtistCard extends StatelessWidget {
  final Artist artist;

  const ArtistCard({super.key, required this.artist});

  @override
  Widget build(BuildContext context) {
    return Consumer<FavoriteManager>(
      builder: (context, favoriteManager, child) {
        final isFavorited = favoriteManager.isFavorited(artist);
        final hasClashes = favoriteManager.hasClashes(artist);
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: hasClashes
                  ? Border.all(color: Colors.red, width: 2)
                  : null,
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: CircleAvatar(
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
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      artist.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  if (hasClashes)
                    const Icon(
                      Icons.warning,
                      color: Colors.red,
                      size: 20,
                    ),
                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: Colors.white.withOpacity(0.7),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        artist.stage.displayName,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 16,
                        color: Colors.white.withOpacity(0.7),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${artist.performanceDay.displayName} • ${artist.performanceTime} (${artist.duration})',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              trailing: IconButton(
                icon: Icon(
                  isFavorited ? Icons.favorite : Icons.favorite_border,
                  color: isFavorited ? Colors.red : Colors.white,
                  size: 28,
                ),
                onPressed: () {
                  favoriteManager.toggleFavorite(artist);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isFavorited
                            ? 'Removed from favorites'
                            : 'Added to favorites',
                      ),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
              ),
              onTap: () {
                _showArtistDetails(context, artist, favoriteManager);
              },
            ),
          ),
        );
      },
    );
  }

  void _showArtistDetails(BuildContext context, Artist artist, FavoriteManager favoriteManager) {
    final clashingArtists = favoriteManager.getClashingArtists(artist);
    
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
                IconButton(
                  icon: Icon(
                    favoriteManager.isFavorited(artist) ? Icons.favorite : Icons.favorite_border,
                    color: favoriteManager.isFavorited(artist) ? Colors.red : Colors.white,
                    size: 28,
                  ),
                  onPressed: () {
                    favoriteManager.toggleFavorite(artist);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Performance Details
            _buildDetailRow('Date', artist.performanceDay.displayName),
            _buildDetailRow('Time', '${artist.performanceTime} - ${artist.performanceEndTime}'),
            _buildDetailRow('Duration', artist.duration),
            
            if (clashingArtists.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withOpacity(0.5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.warning, color: Colors.red, size: 16),
                        SizedBox(width: 8),
                        Text(
                          'Schedule Conflict',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Conflicts with: ${clashingArtists.map((a) => a.name).join(', ')}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
            ],
            
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