import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/artist.dart';
import '../models/artist_data.dart';

class FavoriteManager extends ChangeNotifier {
  static const String _favoritesKey = 'favoritedArtists';
  List<String> _favoritedArtistIDs = [];

  List<String> get favoritedArtistIDs => List.unmodifiable(_favoritedArtistIDs);

  List<Artist> get favoritedArtists {
    return ArtistData.allArtists
        .where((artist) => _favoritedArtistIDs.contains(artist.id))
        .toList()
      ..sort((a, b) => a.sortableMinutes.compareTo(b.sortableMinutes));
  }

  FavoriteManager() {
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    _favoritedArtistIDs = prefs.getStringList(_favoritesKey) ?? [];
    notifyListeners();
  }

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_favoritesKey, _favoritedArtistIDs);
  }

  void toggleFavorite(Artist artist) {
    if (isFavorited(artist)) {
      _favoritedArtistIDs.remove(artist.id);
    } else {
      _favoritedArtistIDs.add(artist.id);
    }
    _saveFavorites();
    notifyListeners();
  }

  bool isFavorited(Artist artist) {
    return _favoritedArtistIDs.contains(artist.id);
  }

  Future<void> clearAllFavorites() async {
    _favoritedArtistIDs.clear();
    await _saveFavorites();
    notifyListeners();
  }

  Future<void> exportFavorites() async {
    final favorites = favoritedArtists;
    final exportData = favorites.map((artist) => artist.toJson()).toList();
    final jsonString = jsonEncode(exportData);
    
    // In a real app, you'd save this to a file or share it
    print('Exported favorites: $jsonString');
  }

  Future<void> importFavorites(List<Map<String, dynamic>> data) async {
    final importedArtists = data
        .map((json) => Artist.fromJson(json))
        .where((artist) => ArtistData.allArtists.any((a) => a.id == artist.id))
        .map((artist) => artist.id)
        .toList();
    
    _favoritedArtistIDs = importedArtists;
    await _saveFavorites();
    notifyListeners();
  }

  // Check if an artist has clashes with other favorited artists
  bool hasClashes(Artist artist) {
    return favoritedArtists.any((otherArtist) =>
        otherArtist.id != artist.id && artist.overlaps(otherArtist));
  }

  List<Artist> getClashingArtists(Artist artist) {
    return favoritedArtists.where((otherArtist) =>
        otherArtist.id != artist.id && artist.overlaps(otherArtist)).toList();
  }
} 