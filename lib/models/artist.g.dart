// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'artist.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Artist _$ArtistFromJson(Map<String, dynamic> json) => Artist(
      id: json['id'] as String,
      name: json['name'] as String,
      stage: $enumDecode(_$StageEnumMap, json['stage']),
      performanceDay: $enumDecode(_$PerformanceDayEnumMap, json['performanceDay']),
      performanceTime: json['performanceTime'] as String,
      performanceEndTime: json['performanceEndTime'] as String,
    );

Map<String, dynamic> _$ArtistToJson(Artist instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'stage': _$StageEnumMap[instance.stage]!,
      'performanceDay': _$PerformanceDayEnumMap[instance.performanceDay]!,
      'performanceTime': instance.performanceTime,
      'performanceEndTime': instance.performanceEndTime,
    };

const _$StageEnumMap = {
  Stage.forest: 'forest',
  Stage.village: 'village',
  Stage.forestFleadh: 'forestFleadh',
  Stage.perfectDay: 'perfectDay',
  Stage.ibizaRewind: 'ibizaRewind',
  Stage.vip: 'vip',
};

const _$PerformanceDayEnumMap = {
  PerformanceDay.friday: 'friday',
  PerformanceDay.saturday: 'saturday',
  PerformanceDay.sunday: 'sunday',
}; 