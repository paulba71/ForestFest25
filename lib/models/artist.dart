import 'package:json_annotation/json_annotation.dart';

part 'artist.g.dart';

@JsonSerializable()
class Artist {
  final String id;
  final String name;
  final Stage stage;
  final PerformanceDay performanceDay;
  final String performanceTime;
  final String performanceEndTime;

  Artist({
    required this.id,
    required this.name,
    required this.stage,
    required this.performanceDay,
    required this.performanceTime,
    required this.performanceEndTime,
  });

  factory Artist.fromJson(Map<String, dynamic> json) => _$ArtistFromJson(json);
  Map<String, dynamic> toJson() => _$ArtistToJson(this);

  // Computed properties
  String get duration {
    final start = _timeToMinutes(performanceTime);
    final end = _timeToMinutes(performanceEndTime);
    final durationMinutes = end - start;
    final hours = durationMinutes ~/ 60;
    final minutes = durationMinutes % 60;
    
    if (hours > 0) {
      return minutes > 0 ? '${hours}h ${minutes}m' : '${hours}h';
    } else {
      return '${minutes}m';
    }
  }

  int get sortableMinutes => _timeToMinutes(performanceTime);

  // Helper method to convert time string to minutes
  int _timeToMinutes(String timeString) {
    final parts = timeString.split(':');
    if (parts.length != 2) return 0;
    
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = int.tryParse(parts[1]) ?? 0;
    
    // Handle midnight crossing (00:00-05:00 treated as 24-29 hours)
    final adjustedHour = (hour >= 0 && hour <= 5) ? hour + 24 : hour;
    return adjustedHour * 60 + minute;
  }

  // Check if this artist overlaps with another
  bool overlaps(Artist other) {
    if (performanceDay != other.performanceDay) return false;
    
    final thisStart = _timeToMinutes(performanceTime);
    final thisEnd = _timeToMinutes(performanceEndTime);
    final otherStart = _timeToMinutes(other.performanceTime);
    final otherEnd = _timeToMinutes(other.performanceEndTime);
    
    return (thisStart < otherEnd && thisEnd > otherStart);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Artist &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Artist(id: $id, name: $name, stage: $stage)';
}

enum Stage {
  @JsonValue('forest')
  forest,
  @JsonValue('village')
  village,
  @JsonValue('forestFleadh')
  forestFleadh,
  @JsonValue('perfectDay')
  perfectDay,
  @JsonValue('ibizaRewind')
  ibizaRewind,
  @JsonValue('vip')
  vip,
}

enum PerformanceDay {
  @JsonValue('friday')
  friday,
  @JsonValue('saturday')
  saturday,
  @JsonValue('sunday')
  sunday,
}

// Extension to get display names
extension StageExtension on Stage {
  String get displayName {
    switch (this) {
      case Stage.forest:
        return 'Forest Stage';
      case Stage.village:
        return 'Village Stage';
      case Stage.forestFleadh:
        return 'Forest Fleadh Stage';
      case Stage.perfectDay:
        return 'Perfect Day Stage';
      case Stage.ibizaRewind:
        return 'Ibiza Rewind Tent';
      case Stage.vip:
        return 'VIP Stage';
    }
  }
}

extension PerformanceDayExtension on PerformanceDay {
  String get displayName {
    switch (this) {
      case PerformanceDay.friday:
        return 'Friday, July 25';
      case PerformanceDay.saturday:
        return 'Saturday, July 26';
      case PerformanceDay.sunday:
        return 'Sunday, July 27';
    }
  }
} 