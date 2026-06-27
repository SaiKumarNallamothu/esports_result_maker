import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../data/models.dart';
import '../data/hive_service.dart';

class TeamStats {
  final Team team;
  int matchesPlayed = 0;
  int placementPoints = 0;
  int finishes = 0;
  int bonusPoints = 0;
  int penaltyPoints = 0;
  int totalPoints = 0;
  int wwcdCount = 0;

  TeamStats({required this.team});
}

class TournamentViewModel extends ChangeNotifier {
  final HiveService _hiveService = HiveService();
  final _uuid = const Uuid();

  List<Tournament> _tournaments = [];
  List<PointSystem> _presets = [];
  Tournament? _activeTournament;

  List<Tournament> get tournaments => _tournaments;
  List<PointSystem> get presets => _presets;
  Tournament? get activeTournament => _activeTournament;

  void loadTournaments() {
    _tournaments = _hiveService.getAllTournaments();
    notifyListeners();
  }

  void loadPresets() {
    _presets = _hiveService.getAllPresets();
    notifyListeners();
  }

  void setActiveTournament(Tournament? tournament) {
    _activeTournament = tournament;
    notifyListeners();
  }

  // --- CRUD Operations ---

  Future<void> createTournament({
    required String name,
    required int numberOfMatches,
    required int numberOfTeams,
    required PointSystem pointSystem,
    String format = 'classic',
    int? numberOfGroups,
  }) async {
    final List<String> groupsList = [];
    if (format == 'group_fixtures' && numberOfGroups != null && numberOfGroups > 0) {
      for (int i = 0; i < numberOfGroups; i++) {
        groupsList.add(String.fromCharCode(65 + i)); // 'A', 'B', 'C', etc.
      }
    }

    final List<Team> teams = List.generate(
      numberOfTeams,
      (index) {
        String? teamGroup;
        if (groupsList.isNotEmpty) {
          final groupIndex = index % groupsList.length;
          teamGroup = groupsList[groupIndex];
        }
        return Team(
          id: _uuid.v4(),
          name: 'Team ${index + 1}',
          logoPath: null,
          group: teamGroup,
        );
      },
    );

    // Generate round robin pairs of groups
    final List<List<String>> uniquePairs = [];
    if (groupsList.isNotEmpty) {
      for (int i = 0; i < groupsList.length; i++) {
        for (int j = i + 1; j < groupsList.length; j++) {
          uniquePairs.add([groupsList[i], groupsList[j]]);
        }
      }
    }

    final List<Match> matches = List.generate(
      numberOfMatches,
      (index) {
        List<String>? playingGroups;
        if (format == 'group_fixtures' && uniquePairs.isNotEmpty) {
          final pairIndex = index % uniquePairs.length;
          playingGroups = uniquePairs[pairIndex];
        }
        return Match(
          matchNumber: index + 1,
          results: [],
          playingGroups: playingGroups,
        );
      },
    );

    final newTournament = Tournament(
      id: _uuid.v4(),
      name: name,
      numberOfMatches: numberOfMatches,
      numberOfTeams: numberOfTeams,
      teams: teams,
      matches: matches,
      pointSystem: pointSystem,
      createdAt: DateTime.now(),
      format: format,
      numberOfGroups: numberOfGroups,
    );

    await _hiveService.saveTournament(newTournament);
    _activeTournament = newTournament;
    loadTournaments();
  }

  Future<void> saveActiveTournament() async {
    if (_activeTournament != null) {
      await _hiveService.saveTournament(_activeTournament!);
      loadTournaments();
    }
  }

  Future<void> deleteTournament(String id) async {
    await _hiveService.deleteTournament(id);
    if (_activeTournament?.id == id) {
      _activeTournament = null;
    }
    loadTournaments();
  }

  Future<void> duplicateTournament(Tournament tournament) async {
    // Deep copy teams
    final copiedTeams = tournament.teams
        .map((t) => Team(id: _uuid.v4(), name: '${t.name} (Copy)', logoPath: t.logoPath, group: t.group))
        .toList();

    // Map old team IDs to new team IDs to map match results correctly
    final Map<String, String> teamIdMapping = {};
    for (int i = 0; i < tournament.teams.length; i++) {
      teamIdMapping[tournament.teams[i].id] = copiedTeams[i].id;
    }

    // Deep copy matches
    final copiedMatches = tournament.matches.map((m) {
      final copiedResults = m.results.map((r) {
        return MatchResult(
          teamId: teamIdMapping[r.teamId] ?? _uuid.v4(),
          placement: r.placement,
          finishes: r.finishes,
          bonusPoints: r.bonusPoints,
          penaltyPoints: r.penaltyPoints,
        );
      }).toList();
      return Match(
        matchNumber: m.matchNumber,
        results: copiedResults,
        playingGroups: m.playingGroups != null ? List<String>.from(m.playingGroups!) : null,
      );
    }).toList();

    final duplicated = Tournament(
      id: _uuid.v4(),
      name: '${tournament.name} (Copy)',
      numberOfMatches: tournament.numberOfMatches,
      numberOfTeams: tournament.numberOfTeams,
      teams: copiedTeams,
      matches: copiedMatches,
      pointSystem: tournament.pointSystem,
      createdAt: DateTime.now(),
      format: tournament.format,
      numberOfGroups: tournament.numberOfGroups,
    );

    await _hiveService.saveTournament(duplicated);
    loadTournaments();
  }

  // --- Team Management Actions ---

  void updateTeamName(String teamId, String newName) {
    if (_activeTournament == null) return;
    final index = _activeTournament!.teams.indexWhere((t) => t.id == teamId);
    if (index != -1) {
      _activeTournament!.teams[index].name = newName;
      saveActiveTournament();
      notifyListeners();
    }
  }

  void updateTeamLogo(String teamId, String? logoPath) {
    if (_activeTournament == null) return;
    final index = _activeTournament!.teams.indexWhere((t) => t.id == teamId);
    if (index != -1) {
      _activeTournament!.teams[index].logoPath = logoPath;
      saveActiveTournament();
      notifyListeners();
    }
  }

  void reorderTeams(int oldIndex, int newIndex) {
    if (_activeTournament == null) return;
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final Team item = _activeTournament!.teams.removeAt(oldIndex);
    _activeTournament!.teams.insert(newIndex, item);
    saveActiveTournament();
    notifyListeners();
  }

  void updateTeamGroup(String teamId, String? newGroup) {
    if (_activeTournament == null) return;
    final index = _activeTournament!.teams.indexWhere((t) => t.id == teamId);
    if (index != -1) {
      _activeTournament!.teams[index].group = newGroup;
      saveActiveTournament();
      notifyListeners();
    }
  }

  // --- Match Result Actions ---

  void updateMatchResults(int matchNumber, List<MatchResult> results) {
    if (_activeTournament == null) return;
    final matchIndex = _activeTournament!.matches.indexWhere((m) => m.matchNumber == matchNumber);
    if (matchIndex != -1) {
      _activeTournament!.matches[matchIndex] = Match(
        matchNumber: matchNumber,
        results: results,
      );
      saveActiveTournament();
      notifyListeners();
    }
  }

  // --- Calculations & Leaderboard ---

  List<TeamStats> calculateLeaderboard({int? matchNumber}) {
    if (_activeTournament == null) return [];

    final tournament = _activeTournament!;
    final pointSystem = tournament.pointSystem;

    // Create entry map for fast access
    final Map<String, TeamStats> statsMap = {
      for (var team in tournament.teams) team.id: TeamStats(team: team),
    };

    // Aggregate stats from all matches
    for (var match in tournament.matches) {
      if (match.results.isEmpty) continue;
      if (matchNumber != null && match.matchNumber != matchNumber) continue;

      for (var result in match.results) {
        final stats = statsMap[result.teamId];
        if (stats != null) {
          stats.matchesPlayed++;
          stats.finishes += result.finishes;
          stats.bonusPoints += result.bonusPoints;
          stats.penaltyPoints += result.penaltyPoints;

          // Placement points calculation
          final placementPt = pointSystem.positionPoints[result.placement] ?? 0;
          stats.placementPoints += placementPt;

          // Chicken Dinner check
          if (result.placement == 1) {
            stats.wwcdCount++;
          }
        }
      }
    }

    // Compute total points
    for (var stats in statsMap.values) {
      stats.totalPoints = stats.placementPoints +
          (stats.finishes * pointSystem.finishPoints) +
          stats.bonusPoints -
          stats.penaltyPoints;
    }

    // Convert to list
    final List<TeamStats> leaderboard = statsMap.values.toList();

    // Sort with robust tiebreakers:
    // 1. Total Points (descending)
    // 2. Organizer specified tiebreaker hierarchy
    // 3. Team name (alphabetical ascending as fallback)
    leaderboard.sort((a, b) {
      if (b.totalPoints != a.totalPoints) {
        return b.totalPoints.compareTo(a.totalPoints);
      }
      for (final criteria in pointSystem.tiebreakerOrder) {
        if (criteria == 'wwcd') {
          if (b.wwcdCount != a.wwcdCount) {
            return b.wwcdCount.compareTo(a.wwcdCount);
          }
        } else if (criteria == 'finishes') {
          if (b.finishes != a.finishes) {
            return b.finishes.compareTo(a.finishes);
          }
        } else if (criteria == 'placementPoints') {
          if (b.placementPoints != a.placementPoints) {
            return b.placementPoints.compareTo(a.placementPoints);
          }
        }
      }
      return a.team.name.toLowerCase().compareTo(b.team.name.toLowerCase());
    });

    return leaderboard;
  }

  // --- Point System CRUD Presets ---

  Future<void> saveCustomPreset(String name, Map<int, int> positionPoints, int finishPoints, List<String> tiebreakerHierarchy) async {
    final system = PointSystem(
      id: _uuid.v4(),
      name: name,
      positionPoints: positionPoints,
      finishPoints: finishPoints,
      tiebreakerHierarchy: tiebreakerHierarchy,
    );
    await _hiveService.savePreset(system);
    loadPresets();
  }

  Future<void> deleteCustomPreset(String id) async {
    await _hiveService.deletePreset(id);
    loadPresets();
  }
}
