import 'package:hive/hive.dart';

part 'models.g.dart';

@HiveType(typeId: 0)
class Team extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String? logoPath; // Picked image local path (or null for auto-generated gradient initial)

  Team({
    required this.id,
    required this.name,
    this.logoPath,
  });
}

@HiveType(typeId: 1)
class PointSystem extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  Map<int, int> positionPoints; // Map of Position (e.g. 1st, 2nd...) to Points

  @HiveField(3)
  int finishPoints; // Points per kill

  @HiveField(4)
  List<String>? tiebreakerHierarchy; // E.g. ['wwcd', 'finishes', 'placementPoints']

  PointSystem({
    required this.id,
    required this.name,
    required this.positionPoints,
    required this.finishPoints,
    this.tiebreakerHierarchy,
  });

  List<String> get tiebreakerOrder => tiebreakerHierarchy ?? ['wwcd', 'finishes', 'placementPoints'];

  static PointSystem get bgmiDefault => PointSystem(
        id: 'bgmi_default',
        name: 'BGMI Default System',
        positionPoints: {
          1: 15,
          2: 12,
          3: 10,
          4: 8,
          5: 6,
          6: 4,
          7: 2,
          8: 1,
          9: 1,
          10: 1,
          11: 1,
          12: 1,
        },
        finishPoints: 1,
        tiebreakerHierarchy: ['wwcd', 'finishes', 'placementPoints'],
      );

  static PointSystem get bgisNew => PointSystem(
        id: 'bgis_new',
        name: 'BGIS / BMPS Official System',
        positionPoints: {
          1: 10,
          2: 6,
          3: 5,
          4: 4,
          5: 3,
          6: 2,
          7: 1,
          8: 1,
        },
        finishPoints: 1,
        tiebreakerHierarchy: ['wwcd', 'finishes', 'placementPoints'],
      );

  static PointSystem get pubgDefault => PointSystem(
        id: 'pubg_default',
        name: 'PUBG Official System',
        positionPoints: {
          1: 10,
          2: 6,
          3: 5,
          4: 4,
          5: 3,
          6: 2,
          7: 1,
          8: 1,
        },
        finishPoints: 1,
        tiebreakerHierarchy: ['wwcd', 'finishes', 'placementPoints'],
      );
}

@HiveType(typeId: 2)
class MatchResult extends HiveObject {
  @HiveField(0)
  final String teamId;

  @HiveField(1)
  int placement; // e.g. 1 to 24

  @HiveField(2)
  int finishes; // e.g. total finishes / kills

  @HiveField(3)
  int bonusPoints;

  @HiveField(4)
  int penaltyPoints;

  MatchResult({
    required this.teamId,
    required this.placement,
    required this.finishes,
    this.bonusPoints = 0,
    this.penaltyPoints = 0,
  });
}

@HiveType(typeId: 3)
class Tournament extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  int numberOfMatches;

  @HiveField(3)
  int numberOfTeams;

  @HiveField(4)
  List<Team> teams;

  @HiveField(5)
  List<Match> matches;

  @HiveField(6)
  PointSystem pointSystem;

  @HiveField(7)
  DateTime createdAt;

  Tournament({
    required this.id,
    required this.name,
    required this.numberOfMatches,
    required this.numberOfTeams,
    required this.teams,
    required this.matches,
    required this.pointSystem,
    required this.createdAt,
  });
}

@HiveType(typeId: 4)
class Match extends HiveObject {
  @HiveField(0)
  final int matchNumber; // 1-indexed

  @HiveField(1)
  final List<MatchResult> results;

  Match({
    required this.matchNumber,
    required this.results,
  });
}
