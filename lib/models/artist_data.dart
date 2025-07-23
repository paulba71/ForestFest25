import 'artist.dart';

class ArtistData {
  static final List<Artist> allArtists = [
    // Friday Artists
    Artist(
      id: 'friday-1',
      name: 'The Valves',
      stage: Stage.village,
      performanceDay: PerformanceDay.friday,
      performanceTime: '16:00',
      performanceEndTime: '17:00',
    ),
    Artist(
      id: 'friday-2',
      name: 'Something Happens',
      stage: Stage.village,
      performanceDay: PerformanceDay.friday,
      performanceTime: '17:00',
      performanceEndTime: '18:00',
    ),
    Artist(
      id: 'friday-3',
      name: 'Harvest',
      stage: Stage.village,
      performanceDay: PerformanceDay.friday,
      performanceTime: '17:30',
      performanceEndTime: '18:00',
    ),
    Artist(
      id: 'friday-4',
      name: 'Madra Salach',
      stage: Stage.forestFleadh,
      performanceDay: PerformanceDay.friday,
      performanceTime: '16:20',
      performanceEndTime: '17:00',
    ),
    Artist(
      id: 'friday-5',
      name: 'Meadhbh Hayes',
      stage: Stage.forestFleadh,
      performanceDay: PerformanceDay.friday,
      performanceTime: '17:20',
      performanceEndTime: '18:00',
    ),
    Artist(
      id: 'friday-6',
      name: 'The Jury',
      stage: Stage.perfectDay,
      performanceDay: PerformanceDay.friday,
      performanceTime: '16:40',
      performanceEndTime: '17:25',
    ),
    Artist(
      id: 'friday-7',
      name: 'Danny Kaye & The Ibiza Rewind Band',
      stage: Stage.ibizaRewind,
      performanceDay: PerformanceDay.friday,
      performanceTime: '16:00',
      performanceEndTime: '17:00',
    ),
    Artist(
      id: 'friday-8',
      name: 'Alan Prosser',
      stage: Stage.ibizaRewind,
      performanceDay: PerformanceDay.friday,
      performanceTime: '17:00',
      performanceEndTime: '18:00',
    ),

    // Saturday Artists
    Artist(
      id: 'saturday-1',
      name: 'Aoife Destruction and The Nilz',
      stage: Stage.forest,
      performanceDay: PerformanceDay.saturday,
      performanceTime: '14:10',
      performanceEndTime: '14:50',
    ),
    Artist(
      id: 'saturday-2',
      name: 'The Coathanger Solution',
      stage: Stage.forest,
      performanceDay: PerformanceDay.saturday,
      performanceTime: '13:20',
      performanceEndTime: '14:05',
    ),
    Artist(
      id: 'saturday-3',
      name: 'These Charming Men',
      stage: Stage.forest,
      performanceDay: PerformanceDay.saturday,
      performanceTime: '14:30',
      performanceEndTime: '15:30',
    ),
    Artist(
      id: 'saturday-4',
      name: 'Chris Comhaill',
      stage: Stage.village,
      performanceDay: PerformanceDay.saturday,
      performanceTime: '13:15',
      performanceEndTime: '14:00',
    ),
    Artist(
      id: 'saturday-5',
      name: 'Cormac Looby',
      stage: Stage.village,
      performanceDay: PerformanceDay.saturday,
      performanceTime: '14:15',
      performanceEndTime: '15:00',
    ),
    Artist(
      id: 'saturday-6',
      name: 'Southern Freud',
      stage: Stage.forestFleadh,
      performanceDay: PerformanceDay.saturday,
      performanceTime: '13:25',
      performanceEndTime: '14:10',
    ),
    Artist(
      id: 'saturday-7',
      name: 'The Magic Numbers',
      stage: Stage.forestFleadh,
      performanceDay: PerformanceDay.saturday,
      performanceTime: '14:30',
      performanceEndTime: '15:30',
    ),
    Artist(
      id: 'saturday-8',
      name: 'Nick Lowe',
      stage: Stage.perfectDay,
      performanceDay: PerformanceDay.saturday,
      performanceTime: '13:00',
      performanceEndTime: '14:00',
    ),
    Artist(
      id: 'saturday-9',
      name: 'Alan Prosser',
      stage: Stage.ibizaRewind,
      performanceDay: PerformanceDay.saturday,
      performanceTime: '17:00',
      performanceEndTime: '18:00',
    ),

    // Sunday Artists
    Artist(
      id: 'sunday-1',
      name: 'Franz Ferdinand',
      stage: Stage.forest,
      performanceDay: PerformanceDay.sunday,
      performanceTime: '21:00',
      performanceEndTime: '22:30',
    ),
    Artist(
      id: 'sunday-2',
      name: 'The Stranglers',
      stage: Stage.forest,
      performanceDay: PerformanceDay.sunday,
      performanceTime: '19:00',
      performanceEndTime: '20:00',
    ),
    Artist(
      id: 'sunday-3',
      name: 'Billy Bragg',
      stage: Stage.village,
      performanceDay: PerformanceDay.sunday,
      performanceTime: '20:00',
      performanceEndTime: '21:00',
    ),
    Artist(
      id: 'sunday-4',
      name: 'Sharon Shannon',
      stage: Stage.forestFleadh,
      performanceDay: PerformanceDay.sunday,
      performanceTime: '18:00',
      performanceEndTime: '19:00',
    ),
    Artist(
      id: 'sunday-5',
      name: 'Orbital',
      stage: Stage.perfectDay,
      performanceDay: PerformanceDay.sunday,
      performanceTime: '22:00',
      performanceEndTime: '23:30',
    ),
  ];

  static List<Artist> getArtistsForDay(PerformanceDay day) {
    return allArtists.where((artist) => artist.performanceDay == day).toList();
  }

  static List<Artist> getArtistsForStage(Stage stage) {
    return allArtists.where((artist) => artist.stage == stage).toList();
  }

  static List<Artist> getArtistsForStageAndDay(Stage stage, PerformanceDay day) {
    return allArtists.where((artist) => 
      artist.stage == stage && artist.performanceDay == day
    ).toList();
  }
} 